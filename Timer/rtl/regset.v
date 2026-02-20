module regset (
    input  wire clk, 
    input  wire rst_n,
    input  wire wr_en,
    input  wire rd_en,
    input  wire [3:0] pstrb,
    input  wire [11:0] addr,
    input  wire [31:0] wdata,
    input  wire halt_ack,
    input  wire [63:0] cnt,
    output wire [31:0] rdata,
    output wire pslverr,
    output wire tim_int,
    output reg  timer_en,
    output reg  div_en,
    output reg  [3:0] div_val,
    output reg  halt_req,
    output wire tdr0_wr_en,
    output wire tdr1_wr_en,
    output wire cnt_clr,
    output wire [31:0] mask,
    output wire [31:0] wdata_mask
);

parameter ADDR_TCR   = 12'h00;
parameter ADDR_TDR0  = 12'h04;
parameter ADDR_TDR1  = 12'h08;
parameter ADDR_TCMP0 = 12'h0C;
parameter ADDR_TCMP1 = 12'h10;
parameter ADDR_TIER  = 12'h14;
parameter ADDR_TISR  = 12'h18;
parameter ADDR_THCSR = 12'h1C;

//PSTRB
assign mask = {{8{pstrb[3]}}, {8{pstrb[2]}}, {8{pstrb[1]}}, {8{pstrb[0]}}};
assign wdata_mask = wdata & mask;

//TCR
wire tcr_sel;
assign tcr_sel = (addr == ADDR_TCR) & wr_en;

wire timer_en_next, div_en_next;
wire timer_en_sel, div_en_sel, div_val_sel;
wire [3:0] div_val_next;

assign timer_en_sel = tcr_sel & pstrb[0] & ~pslverr;
assign timer_en_next = timer_en_sel ? wdata[0] : timer_en;
assign div_en_sel = tcr_sel & ~timer_en & pstrb[0] & ~pslverr;
assign div_en_next = div_en_sel ? wdata[1] : div_en;
assign div_val_sel = tcr_sel & (wdata[11:8] < 9) & ~timer_en & pstrb[1] & ~pslverr;
assign div_val_next = div_val_sel ? wdata[11:8] : div_val;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        timer_en <= 1'b0;
    else 
        timer_en <= timer_en_next;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        div_en <= 1'b0;
    else
        div_en <= div_en_next;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        div_val <= 4'b0001;
    else
        div_val <= div_val_next;
end

assign cnt_clr = timer_en & ~timer_en_next;

//TDR0 & TDR1
assign tdr0_wr_en = (addr == ADDR_TDR0) & wr_en;
assign tdr1_wr_en = (addr == ADDR_TDR1) & wr_en;

//TCMP0 & TCMP1
reg  [31:0] tcmp0, tcmp1;
wire [31:0] tcmp0_next, tcmp1_next;
wire tcmp0_sel, tcmp1_sel;

assign tcmp0_sel = (addr == ADDR_TCMP0) & wr_en;
assign tcmp1_sel = (addr == ADDR_TCMP1) & wr_en;
assign tcmp0_next = tcmp0_sel ? ((tcmp0 & ~mask) | wdata_mask) : tcmp0;
assign tcmp1_next = tcmp1_sel ? ((tcmp1 & ~mask) | wdata_mask) : tcmp1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tcmp0 <= 32'hffff_ffff;
    else 
        tcmp0 <= tcmp0_next;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tcmp1 <= 32'hffff_ffff;
    else 
        tcmp1 <= tcmp1_next;
end

//PSLVERR
assign pslverr = tcr_sel & (((wdata[11:8] > 8) & pstrb[1]) | (timer_en & (((wdata[1] != div_en) & pstrb[0]) | ((wdata[11:8] != div_val) & pstrb[1]))));

//INTERRUPT
reg  int_en, int_st;
wire int_en_next, int_st_next;
wire tier_sel, tisr_sel, int_set, int_clr;

assign tier_sel = (addr == ADDR_TIER) & wr_en & pstrb[0];
assign int_en_next = tier_sel ? wdata[0] : int_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        int_en <= 1'b0;
    else 
        int_en <= int_en_next;
end

assign tisr_sel = (addr == ADDR_TISR) & wr_en & pstrb[0];
assign int_set = (cnt == {tcmp1[31:0], tcmp0[31:0]});
assign int_clr = tisr_sel & (wdata[0] == 1'b1) & int_st;
assign int_st_next = int_clr ? 1'b0 : 
                     int_set ? 1'b1 : int_st;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        int_st <= 1'b0;
    else 
        int_st <= int_st_next;
end

assign tim_int = int_en & int_st;

//HALT
wire   thcsr_sel, halt_req_next;
assign thcsr_sel = (addr == ADDR_THCSR) & wr_en & pstrb[0];
assign halt_req_next = thcsr_sel ? wdata[0] : halt_req;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        halt_req <= 1'b0;
    else 
        halt_req <= halt_req_next;
end

//READ 
reg [31:0] rd_next;
always @(*) begin
    case (addr)
        ADDR_TCR  : rd_next = {20'h0, div_val[3:0], 6'h0, div_en, timer_en};
        ADDR_TDR0 : rd_next = cnt[31:0];
        ADDR_TDR1 : rd_next = cnt[63:32];
        ADDR_TCMP0: rd_next = tcmp0;
        ADDR_TCMP1: rd_next = tcmp1;
        ADDR_TIER : rd_next = {31'h0, int_en};
        ADDR_TISR : rd_next = {31'h0, int_st};
        ADDR_THCSR: rd_next = {30'h0, halt_ack, halt_req};
        default   : rd_next = 32'h0;
    endcase
end

assign rdata = rd_en ? rd_next : 32'h0;
endmodule
