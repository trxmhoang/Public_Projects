module timer_top (
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire dbg_mode,
    input  wire tim_psel,
    input  wire tim_pwrite,
    input  wire tim_penable,
    input  wire [3:0] tim_pstrb,
    input  wire [11:0] tim_paddr,
    input  wire [31:0] tim_pwdata,
    output wire [31:0] tim_prdata,
    output wire tim_pready,
    output wire tim_pslverr,
    output wire tim_int
);

wire wr_en, rd_en;
wire timer_en, div_en, halt_req, halt_ack, cnt_en;
wire [3:0] div_val;
wire tdr0_wr_en, tdr1_wr_en, cnt_clr;
wire [31:0] mask, wdata_mask;
wire [63:0] cnt;

apbif    u_slave (.clk (sys_clk), .rst_n (sys_rst_n), .psel (tim_psel), .pwrite (tim_pwrite), .penable (tim_penable), .pready (tim_pready), .wr_en (wr_en), .rd_en (rd_en));

cnt_ctrl u_ctrl  (.clk (sys_clk), .rst_n (sys_rst_n), .timer_en (timer_en), .div_en (div_en), .div_val (div_val), 
                  .dbg_mode (dbg_mode), .halt_req (halt_req), .halt_ack (halt_ack), .cnt_en (cnt_en));

counter  u_cnt   (.clk (sys_clk), .rst_n (sys_rst_n), .cnt_en (cnt_en), .tdr0_wr_en (tdr0_wr_en), .tdr1_wr_en (tdr1_wr_en), 
                  .cnt_clr (cnt_clr), .mask (mask), .wdata_mask (wdata_mask), .cnt (cnt));

regset   u_reg   (.clk (sys_clk), .rst_n (sys_rst_n), .wr_en (wr_en), .rd_en (rd_en), .pstrb (tim_pstrb), .addr (tim_paddr), .wdata (tim_pwdata), 
                  .halt_ack (halt_ack), .cnt (cnt), .rdata (tim_prdata), .tim_int (tim_int), .timer_en (timer_en), .div_en (div_en), .div_val (div_val), 
                  .halt_req (halt_req), .tdr0_wr_en (tdr0_wr_en), .tdr1_wr_en (tdr1_wr_en), .cnt_clr (cnt_clr), .mask (mask), .wdata_mask (wdata_mask), .pslverr (tim_pslverr));
endmodule 
