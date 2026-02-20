module top #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,
    input wire rst_n,
    input wire start, 
    output wire done,

    input wire [TOTAL_PIXEL_BIT-1:0] rd_addr,
    output wire [7:0] rd_data
);

    // Interface with input RAM
    wire [TOTAL_PIXEL_BIT-1:0] int_rd_addr;
    wire [7:0] int_rd_data;
 
    // Interface with output RAM
    wire int_wr_en;
    wire [TOTAL_PIXEL_BIT-1:0] int_wr_addr;
    wire [7:0] int_wr_data;

    histogram #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut_hist (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),

        .rd_addr(int_rd_addr),
        .rd_data(int_rd_data),

        .wr_en(int_wr_en),
        .wr_addr(int_wr_addr),
        .wr_data(int_wr_data)
    );

    ram_in #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut_in (
        .clk(clk),
        .rd_addr(int_rd_addr),
        .rd_data(int_rd_data)
    );

    ram_out #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut_out (
        .clk(clk),
        .wr_en(int_wr_en),
        .wr_addr(int_wr_addr),
        .wr_data(int_wr_data),

        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );
endmodule