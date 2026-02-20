module top #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H),
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst_n,

    input wire [ADDR_WIDTH-1:0] awaddr,
    input wire awvalid,
    output wire awready,

    input wire [31:0] wdata, 
    input wire [3:0] wstrb,
    input wire wvalid,
    output wire wready,

    output wire [1:0] bresp,
    output wire bvalid,
    input wire bready,

    input wire [ADDR_WIDTH-1:0] araddr,
    input wire arvalid,
    output wire arready,

    output wire [31:0] rdata,
    output wire [1:0] rresp,
    output wire rvalid,
    input wire rready,

    output wire irq,

    input [7:0] s_axis_tdata,
    input s_axis_tvalid,
    output s_axis_tready,
    input s_axis_tlast,

    output [7:0] m_axis_tdata,
    output m_axis_tvalid,
    input m_axis_tready,
    output m_axis_tlast
);

    wire wr_en, rd_en;
    wire start;
    wire [1:0] status, err_code;

    axi_lite #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_lite (
        .clk (clk),
        .rst_n (rst_n),

        .awaddr (awaddr),
        .awvalid (awvalid),
        .awready (awready),

        .wdata (wdata),
        .wstrb (wstrb),
        .wvalid (wvalid),
        .wready (wready),

        .bresp (bresp),
        .bvalid (bvalid),
        .bready (bready),

        .araddr (araddr),
        .arvalid (arvalid),
        .arready (arready),

        .rresp (rresp),
        .rvalid (rvalid),
        .rready (rready),

        .wr_en (wr_en),
        .rd_en (rd_en)
    );

    reg_file #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_reg (
        .clk (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),

        .awaddr (awaddr),
        .wdata (wdata),
        .wstrb (wstrb),

        .araddr (araddr),
        .rdata (rdata),

        .start (start),
        .irq (irq),
        .status (status),
        .err_code (err_code)
    );

    histogram #(
        .W (W),
        .H (H),
        .TOTAL_PIXEL (TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT (TOTAL_PIXEL_BIT)
    ) u_hist (
        .clk (clk),
        .rst_n (rst_n),
        .start (start),
        .status (status),
        .err_code (err_code),

        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast (s_axis_tlast),

        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast (m_axis_tlast)
    );
endmodule