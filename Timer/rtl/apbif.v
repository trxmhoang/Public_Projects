module apbif (
    input  wire clk,
    input  wire rst_n,
    input  wire psel,
    input  wire pwrite,
    input  wire penable,
    output wire pready,
    output wire wr_en,
    output wire rd_en
);

assign wr_en =  pwrite & psel & penable & pready;
assign rd_en = ~pwrite & psel & penable & pready;

reg  int_pready;
wire int_pready_next;
assign int_pready_next = (psel & penable) ? 
                         (int_pready)     ? int_pready : 1'b1 
                         : 1'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        int_pready <= 1'b0;
    else
        int_pready <= int_pready_next;
end

assign pready = (psel & penable) ? int_pready : 1'b0;
endmodule
