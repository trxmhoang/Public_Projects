module histogram #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg done,

    // Interface with input RAM
    output reg [TOTAL_PIXEL_BIT-1:0] rd_addr,
    input wire [7:0] rd_data,

    // Interface with output RAM
    output reg wr_en,
    output reg [TOTAL_PIXEL_BIT-1:0] wr_addr,
    output reg [7:0] wr_data
);

    localparam IDLE = 3'd0;
    localparam CLR_HIST = 3'd1;
    localparam HIST = 3'd2;
    localparam CDF = 3'd3;
    localparam RECIPROCAL = 3'd4;
    localparam MAPPING = 3'd5;
    localparam DONE = 3'd6;

    reg [2:0] state;
    (* ram_style = "distributed" *)
    reg [TOTAL_PIXEL_BIT:0] hist_mem [0:255];

    reg [TOTAL_PIXEL_BIT:0] pixel_cnt;
    reg [7:0] gray_cnt;
    reg [TOTAL_PIXEL_BIT:0] cdf_min;
    reg [TOTAL_PIXEL_BIT:0] cdf_acc;

    reg [1:0] int_state;
    reg [7:0] pixel_val;

    reg div_start;
    wire div_done;
    reg [31:0] div_num;
    reg [TOTAL_PIXEL_BIT-1:0] div_den;
    wire [31:0] div_quot;
    wire [31:0] div_rem;
    reg [31:0] K;

    reg [TOTAL_PIXEL_BIT:0] curr_hist;
    reg [TOTAL_PIXEL_BIT-1:0] p1_addr, p2_addr, p3_addr;
    reg p1_valid, p2_valid, p3_valid;
    reg [31:0] mul_res;

    divider #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) u_div (
        .clk(clk),
        .rst_n (rst_n),
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
            done <= 0;
            rd_addr <= 0;
            wr_en <= 0;
            // sao chúng ta lại k reset cả wr_addr & wr_data ở đây?

            pixel_cnt <= 0; // sao k reset gray_cnt?
            div_start <= 0;
            p1_valid <= 0;
            p2_valid <= 0;
            // sao lại k reset cả p1_addr và p2_addr?
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        done <= 0;
                        state <= CLR_HIST;
                        gray_cnt <= 0;
                    end
                end

                CLR_HIST: begin
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
                    case (int_state)
                        0: begin
                            rd_addr <= pixel_cnt;
                            int_state <= 1; 
                        end

                        1: begin
                            // TRẠM DỪNG: Đợi 1 nhịp clock để RAM xuất dữ liệu
                            int_state <= 2;
                        end

                        2: begin
                            // Lúc này rd_data đã an toàn tuyệt đối
                            pixel_val <= rd_data;
                            int_state <= 3;
                        end

                        3: begin
                            hist_mem[pixel_val] <= hist_mem[pixel_val] + 1;

                            if (pixel_cnt < TOTAL_PIXEL - 1) begin 
                                pixel_cnt <= pixel_cnt + 1;
                                int_state <= 0;
                            end else begin
                                gray_cnt <= 0;
                                cdf_min <= 18'h3FFFF;
                                cdf_acc <= 0;
                                int_state <= 0;
                                state <= CDF;
                            end
                        end
                    endcase
                end

                CDF: begin
                    curr_hist = hist_mem[gray_cnt];

                    cdf_acc <= cdf_acc + curr_hist;
                    hist_mem[gray_cnt] <= cdf_acc + curr_hist;

                    if (curr_hist > 0 && cdf_min == 18'h3FFFF) begin
                        cdf_min <= cdf_acc + curr_hist;
                    end

                    if (gray_cnt < 255) begin
                        gray_cnt <= gray_cnt + 1;
                    end else begin
                        state <= RECIPROCAL;
                    end
                end

                RECIPROCAL: begin
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
                                p1_valid <= 0;
                                p2_valid <= 0;
                                int_state <= 0;
                                state <= MAPPING;
                            end
                        end
                    endcase
                end

                MAPPING: begin
                    // Stage 1: Read addr
                    if (pixel_cnt < TOTAL_PIXEL) begin
                        rd_addr <= pixel_cnt;
                        p1_addr <= pixel_cnt;
                        p1_valid <= 1;
                        pixel_cnt <= pixel_cnt + 1;
                    end else begin
                        p1_valid <= 0;
                    end

                    // Stage 2: Wait for RAM (Push addr & valid to stage 2)
                    p2_valid <= p1_valid;
                    p2_addr  <= p1_addr; 

                    // Stage 3: Calculate (Push addr & valid to stage 3) 
                    if (p2_valid) begin
                        mul_res <= (hist_mem[rd_data] - cdf_min) * K; 
                    end

                    p3_valid <= p2_valid;
                    p3_addr  <= p2_addr;

                    // Stage 4: Write to RAM (Write back)
                    if (p3_valid) begin
                        wr_en <= 1;
                        wr_addr <= p3_addr;
                        wr_data <= (mul_res + 32_768) >> 16; 
                        // res = (mul_res + 0.5) >> 16 = res[28:16] (floor/truncate)
                        // round(x) = floor(x + 0.5)
                        // 2^16 = 65,536 (100%) -> 0.5 of 2^16 = 32,765

                        if (p3_addr == TOTAL_PIXEL - 1) begin
                            state <= DONE;
                        end
                    end else begin
                        wr_en <= 0;
                    end
                end

                DONE: begin
                    wr_en <= 0;
                    done <= 1;
                    if (start == 0) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule