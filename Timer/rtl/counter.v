module counter (
    input  wire clk,
    input  wire rst_n,
    input  wire cnt_en,
    input  wire tdr0_wr_en,
    input  wire tdr1_wr_en,
    input  wire cnt_clr,
    input  wire [31:0] mask,
    input  wire [31:0] wdata_mask,
    output wire [63:0] cnt
);

reg  [31:0] tdr0, tdr1;
wire [31:0] tdr0_next, tdr1_next;
wire [63:0] cnt_next;

assign cnt_next = cnt + 64'd1;
assign tdr0_next = cnt_clr    ? 32'h0 : 
                   tdr0_wr_en ? ((tdr0 & ~mask) | wdata_mask) :
                   cnt_en     ? cnt_next[31:0] : tdr0;
assign tdr1_next = cnt_clr    ? 32'h0 :
                   tdr1_wr_en ? ((tdr1 & ~mask) | wdata_mask) :
                   cnt_en     ? cnt_next[63:32] : tdr1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tdr0 <= 32'h0;
    else
        tdr0 <= tdr0_next;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tdr1 <= 32'h0;
    else
        tdr1 <= tdr1_next;
end

assign cnt = {tdr1[31:0], tdr0[31:0]};
endmodule

