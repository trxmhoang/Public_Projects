module gaussian #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H),
    parameter TIME_LIMIT = 2_000_000
)(
    input wire clk,
    input wire rst_n,
    
    input wire start,
    output reg [1:0] status, // 0: idle, 1: busy, 2: done, 3: error
    output reg [1:0] err_code, // 0: none, 1: timeout, 2: early_tlast, 3: late_tlast

    input wire [7:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output reg s_axis_tready,
    input wire s_axis_tlast,

    output reg [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg m_axis_tlast
);

    localparam X_BIT = (W > 1) ? $clog2(W) : 1;
    localparam Y_BIT = (H > 1) ? $clog2(H) : 1;

    localparam IDLE = 2'd0;
    localparam BUSY = 2'd1;
    localparam DONE = 2'd2;
    localparam ERROR = 2'd3;

    localparam ERR_NONE        = 2'd0;
    localparam ERR_TIMEOUT     = 2'd1;
    localparam ERR_EARLY_TLAST = 2'd2;
    localparam ERR_LATE_TLAST  = 2'd3;

    reg [31:0] watchdog_timer;
    reg [1:0] state;
    reg [TOTAL_PIXEL_BIT:0] pixel_cnt;

    reg [X_BIT-1:0] x_cnt;
    reg [Y_BIT-1:0] y_cnt;
    reg first_done;

    wire [7:0] top, mid, bot;
    wire valid_in = s_axis_tvalid && s_axis_tready;
    wire valid_out;
    wire [7:0] pixel_out;

    reg [W+5:0] valid_pipe, tlast_pipe;
    reg [1:0] top_edge_pipe, bot_edge_pipe;
    reg [1:0] left_edge_pipe, right_edge_pipe;

    line_buffer #(
        .W (W)
    ) u_buffer (
        .clk (clk),
        .rst_n (rst_n),
        .pixel_in (s_axis_tdata),
        .valid_in (valid_in),

        .top (top),
        .mid (mid),
        .bot (bot)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt <= 0;
            y_cnt <= 0;
            first_done <= 0;
        end else if (state == IDLE) begin
            x_cnt <= 0;
            y_cnt <= 0;
            first_done <= 0;
        end else if (valid_in) begin
            if (x_cnt < W - 1) begin
                x_cnt <= x_cnt + 1;
            end else begin
                x_cnt <= 0;

                if (y_cnt < H - 1) begin
                    y_cnt <= y_cnt + 1;
                end else begin
                    y_cnt <= 0;
                    first_done <= 1;
                end
            end
        end
    end

    wire raw_top_edge   = (y_cnt == 1);
    wire raw_bot_edge   = (y_cnt == 0);
    wire raw_left_edge  = (x_cnt == 0);
    wire raw_right_edge = (x_cnt == W-1);
    wire raw_tlast = (x_cnt == W-1 && y_cnt == H-1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top_edge_pipe <= 0;
            bot_edge_pipe <= 0;
            left_edge_pipe <= 0;
            right_edge_pipe <= 0;
            valid_pipe <= 0;
            tlast_pipe <= 0;
        end else if (state == IDLE) begin
            top_edge_pipe <= 0;
            bot_edge_pipe <= 0;
            left_edge_pipe <= 0;
            right_edge_pipe <= 0;
            valid_pipe <= 0;
            tlast_pipe <= 0;
        end else begin
            if (valid_in) begin
                top_edge_pipe <= {top_edge_pipe[0], raw_top_edge};
                bot_edge_pipe <= {bot_edge_pipe[0], raw_bot_edge};
                left_edge_pipe <= {left_edge_pipe[0], raw_left_edge};
                right_edge_pipe <= {right_edge_pipe[0], raw_right_edge};
            end else begin
                top_edge_pipe <= {top_edge_pipe[0], 1'b0};
                bot_edge_pipe <= {bot_edge_pipe[0], 1'b0};
                left_edge_pipe <= {left_edge_pipe[0], 1'b0};
                right_edge_pipe <= {right_edge_pipe[0], 1'b0};
            end

            valid_pipe <= {valid_pipe[W+4:0], valid_in};

            if (raw_tlast && valid_in) begin
                tlast_pipe <= {tlast_pipe[W+4:0], 1'b1};
            end else begin
                tlast_pipe <= {tlast_pipe[W+4:0], 1'b0};
            end
        end
    end
    
    kernel u_kernel (
        .clk (clk),
        .rst_n (rst_n),
        
        .top (top),
        .mid (mid),
        .bot (bot),
        .valid_in (valid_in),

        .top_edge (top_edge_pipe[1]),
        .bot_edge (bot_edge_pipe[1]),
        .left_edge (left_edge_pipe[1]),
        .right_edge (right_edge_pipe[1]),

        .pixel_out (pixel_out),
        .valid_out (valid_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            status <= IDLE;
            err_code <= ERR_NONE;
            watchdog_timer <= 0;
            pixel_cnt <= 0;
            s_axis_tready <= 0;
        end else begin
            if (state == BUSY) begin
                if (valid_in || (m_axis_tvalid && m_axis_tready)) begin
                    watchdog_timer <= 0;
                end else if (watchdog_timer < TIME_LIMIT) begin
                    watchdog_timer <= watchdog_timer + 1;
                end else begin
                    state <= ERROR;
                    err_code <= ERR_TIMEOUT;
                end
            end else begin
                watchdog_timer <= 0;
            end

            case (state)
                IDLE: begin
                    status <= IDLE;
                    err_code <= ERR_NONE;
                    s_axis_tready <= 0;
                    pixel_cnt <= 0;

                    if (start) begin
                        state <= BUSY;
                        s_axis_tready <= 1;
                    end
                end

                BUSY: begin
                    status <= BUSY;

                    if (valid_in) begin
                        pixel_cnt <= pixel_cnt + 1;

                        if (s_axis_tlast) begin
                            if (pixel_cnt < TOTAL_PIXEL - 2) begin
                                state <= ERROR;
                                err_code <= ERR_EARLY_TLAST;
                                s_axis_tready <= 0;
                            end
                        end else begin
                            if (pixel_cnt > TOTAL_PIXEL - 1) begin
                                state <= ERROR;
                                err_code <= ERR_LATE_TLAST;
                                s_axis_tready <= 0;
                            end
                        end
                    end

                    if (m_axis_tvalid && m_axis_tready && m_axis_tlast) begin
                        state <= DONE;
                        s_axis_tready <= 0;
                    end
                end

                DONE: begin
                    status <= DONE;
                    s_axis_tready <= 0;
                    if (!start) begin
                        state <= IDLE;
                    end
                end

                ERROR: begin
                    status <= ERROR;
                    s_axis_tready <= 0;
                    if (!start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            m_axis_tdata <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
        end else if (state == IDLE || state == ERROR) begin
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
        end else begin
            if (valid_pipe[W+1]) begin
                m_axis_tdata <= pixel_out;
                m_axis_tvalid <= 1;
                m_axis_tlast <= tlast_pipe[W+1];
            end else begin
                m_axis_tvalid <= 0;
                m_axis_tlast <= 0;
            end
        end
    end
endmodule
/* 
- Triển khai thêm status + error detect & irq khi nào xong cho cpu
- Replicate Padding thay vì Zero Padding
- Resource: valid_pipe quá dài, tốn nhiều flip flops, nếu W lớn cần thay thanh ghi dịch này bằng một FIFO nhỏ hoặc dùng BRAM để tiết kiệm LUT/FF của FPGA 
- ERR_SIZE_MISMATCH (Lỗi kích thước - Optional): Nếu bạn làm bộ đếm dòng/cột chặt chẽ, bạn có thể báo lỗi nếu hết 1 dòng mà chưa đủ W pixel (dù cái này thường gộp vào Early/Late TLast).
*/