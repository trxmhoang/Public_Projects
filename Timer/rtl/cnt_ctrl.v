module cnt_ctrl (
    input  wire clk,
    input  wire rst_n,
    input  wire timer_en,
    input  wire div_en,
    input  wire [3:0] div_val,
    input  wire dbg_mode,
    input  wire halt_req,
    output reg  halt_ack,
    output wire cnt_en
);

//halt_ack
wire   halt_en;
assign halt_en = dbg_mode & halt_req;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        halt_ack <= 1'b0;
    else
        halt_ack <= halt_en;
end

//int_cnt
wire int_cnt_en, int_cnt_rst;
reg  [7:0] int_cnt;
wire [7:0] limit, int_cnt_next;

assign int_cnt_en = timer_en & div_en & div_val != 0;
assign limit = (1 << div_val) - 1;
assign int_cnt_rst = ~timer_en | ~div_en | int_cnt == limit;
assign int_cnt_next = int_cnt_rst ? 8'b0 :
                      int_cnt_en  ? (int_cnt + 8'd1) : int_cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        int_cnt <= 8'b0;
    else if (halt_en)
        int_cnt <= int_cnt;
    else
        int_cnt <= int_cnt_next;
end

assign cnt_en = (timer_en & ~div_en & ~halt_en) | 
                (timer_en & div_en & div_val == 0 & ~halt_en) |
                (timer_en & div_en & div_val != 0 & int_cnt == limit & ~halt_en);
endmodule
