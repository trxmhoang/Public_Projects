module histogram #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg [1:0] status, // 0: idle, 1: busy, 2: done, 3: error
    output reg [1:0] err_code,

    // Input port - Slave Interface
    input wire [7:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output reg s_axis_tready,
    input wire s_axis_tlast,

    // Output port - Master interface
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tvalid,
    input wire m_axis_tready,
    output reg m_axis_tlast
);

    localparam IDLE = 3'd0;
    localparam CLR_HIST = 3'd1;
    localparam HIST = 3'd2;
    localparam CDF = 3'd3;
    localparam RECIPROCAL = 3'd4;
    localparam MAPPING = 3'd5;
    localparam DONE = 3'd6;
    localparam ERROR = 3'd7;

    localparam ERR_NONE = 2'd0;
    localparam ERR_TIMEOUT = 2'd1;
    localparam ERR_EARLY_TLAST = 2'd2;
    localparam ERR_LATE_TLAST = 2'd3;

    reg [31:0] watchdog_timer;
    localparam TIME_LIMIT = 32'd2_000_000;

    reg [2:0] state;
    (* ram_style = "distributed" *)
    reg [TOTAL_PIXEL_BIT:0] hist_mem [0:255];
    reg [7:0] img_mem [0:TOTAL_PIXEL-1]; // this is very heavy and can crash the fpga, is there any alternative?

    reg [TOTAL_PIXEL_BIT:0] pixel_cnt;
    reg [7:0] gray_cnt;
    reg [TOTAL_PIXEL_BIT:0] cdf_min;
    reg [TOTAL_PIXEL_BIT:0] cdf_acc;

    reg [1:0] int_state;
    reg [7:0] pixel_val;

    reg div_start;
    wire div_done;
    reg [31:0] div_num;
    reg [TOTAL_PIXEL_BIT:0] div_den;
    wire [31:0] div_quot;
    wire [31:0] div_rem;
    reg [31:0] K;

    reg [TOTAL_PIXEL_BIT:0] curr_hist;
    reg [TOTAL_PIXEL_BIT:0] rd_ptr, wr_ptr;
    reg pipe_valid;

    divider #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) u_div (
        .clk(clk),
        .rst_n(rst_n),
        .start(div_start),
        .done(div_done),
        .dividend(div_num),
        .divisor(div_den),
        .quotient(div_quot),
        .remainder(div_rem)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            status <= 0;
            watchdog_timer <= 0;
            err_code <= ERR_NONE;

            pixel_cnt <= 0;
            gray_cnt <= 0;
            div_start <= 0;
            pipe_valid <= 0;
            s_axis_tready <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
        end else begin
            if (state != IDLE && state != DONE && state != ERROR) begin
                if (watchdog_timer < TIME_LIMIT) begin
                    watchdog_timer <= watchdog_timer + 1;
                end else begin
                    state <= ERROR;
                    err_code <= ERR_TIMEOUT;
                    watchdog_timer <= 0;
                end
            end else begin
                watchdog_timer <= 0;
            end

            case (state)
                IDLE: begin
                    status <= 0;
                    err_code <= ERR_NONE;

                    if (start) begin
                        state <= CLR_HIST;
                        gray_cnt <= 0;
                    end
                end

                CLR_HIST: begin
                    status <= 1;
                    hist_mem[gray_cnt] <= 0;
                    if (gray_cnt < 255) begin
                        gray_cnt <= gray_cnt + 1;
                    end else begin
                        pixel_cnt <= 0;
                        int_state <= 0;
                        state <= HIST;
                    end
                end

                HIST: begin
                    status <= 1;
                    s_axis_tready <= 1;

                    if (s_axis_tvalid && s_axis_tready) begin
                        img_mem[pixel_cnt] <= s_axis_tdata;
                        hist_mem[s_axis_tdata] <= hist_mem[s_axis_tdata] + 1;

                        if (s_axis_tlast && (pixel_cnt < TOTAL_PIXEL - 1)) begin
                            state <= ERROR;
                            err_code <= ERR_EARLY_TLAST;    
                        end else if (!s_axis_tlast && (pixel_cnt >= TOTAL_PIXEL - 1)) begin
                            state <= ERROR;
                            err_code <= ERR_LATE_TLAST;
                        end else begin
                            if (pixel_cnt < TOTAL_PIXEL - 1) begin
                                pixel_cnt <= pixel_cnt + 1;
                            end else begin
                                s_axis_tready <= 0;
                                pixel_cnt <= 0;
                                gray_cnt <= 0;
                                cdf_min <= {(TOTAL_PIXEL_BIT+1){1'b1}};;
                                cdf_acc <= 0;
                                state <= CDF;
                            end
                        end
                    end
                end

                CDF: begin
                    status <= 1;
                    curr_hist = hist_mem[gray_cnt];

                    cdf_acc <= cdf_acc + curr_hist;
                    hist_mem[gray_cnt] <= cdf_acc + curr_hist;

                    if (curr_hist > 0 && cdf_min == {(TOTAL_PIXEL_BIT+1){1'b1}}) begin
                        cdf_min <= cdf_acc + curr_hist;
                    end

                    if (gray_cnt < 255) begin
                        gray_cnt <= gray_cnt + 1;
                    end else begin
                        state <= RECIPROCAL;
                    end
                end

                RECIPROCAL: begin
                    status <= 1;
                    case (int_state) 
                        0: begin
                            div_num <= 32'd16_711_680; // 255 << 16 (fix number for all cases)

                            if (TOTAL_PIXEL > cdf_min) begin
                                div_den <= TOTAL_PIXEL - cdf_min;
                            end else begin
                                div_den <= 1;
                            end

                            div_start <= 1;
                            int_state <= 1;
                        end
                        
                        1: begin
                            div_start <= 0;
                            int_state <= 2;
                        end

                        2: begin
                            if (div_done) begin
                                K <= div_quot;
                                pixel_cnt <= 0;
                                rd_ptr <= 0;
                                wr_ptr <= 0;
                                pipe_valid <= 0;
                                m_axis_tvalid <= 0;
                                m_axis_tlast <= 0;
                                int_state <= 0;
                                state <= MAPPING;
                            end
                        end
                    endcase
                end

                MAPPING: begin
                    if (m_axis_tready) begin
                        if (rd_ptr < TOTAL_PIXEL) begin
                            pixel_val <= img_mem[rd_ptr];
                            rd_ptr <= rd_ptr + 1;
                            pipe_valid <= 1;
                        end else begin
                            pipe_valid <= 0;
                        end

                        if (pipe_valid) begin
                            m_axis_tdata <= ((hist_mem[pixel_val] - cdf_min) * K + 32_768) >> 16;
                            m_axis_tvalid <= 1;

                            if (wr_ptr == TOTAL_PIXEL - 1) begin
                                m_axis_tlast <= 1;
                                state <= DONE;
                                pipe_valid <= 0;
                            end else begin
                                m_axis_tlast <= 0;
                                wr_ptr <= wr_ptr + 1;
                            end
                        end else begin
                            m_axis_tvalid <= 0;
                            m_axis_tlast <= 0;
                        end
                    end
                end

                DONE: begin
                    status <= 2;
                    m_axis_tvalid <= 0;
                    m_axis_tlast <= 0;

                    if (start == 0) begin
                        state <= IDLE;
                    end
                end

                ERROR: begin
                    status <= 3;

                    s_axis_tready <= 0;
                    m_axis_tvalid <= 0;
                    m_axis_tlast <= 0;
                    pipe_valid <= 0;

                    if (start == 0) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule