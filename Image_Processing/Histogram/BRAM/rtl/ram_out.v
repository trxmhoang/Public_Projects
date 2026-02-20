module ram_out #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,

    // Write Port
    input wire wr_en,
    input wire [TOTAL_PIXEL_BIT-1:0] wr_addr,
    input wire [7:0] wr_data,

    // Read Port
    input wire [TOTAL_PIXEL_BIT-1:0] rd_addr,
    output reg [7:0] rd_data
);

    (* ram_style = "block" *)
    reg [7:0] ram_mem [0:TOTAL_PIXEL-1];

    // Write Logic
    always @(posedge clk) begin
        if (wr_en) begin
            ram_mem[wr_addr] <= wr_data;
        end
    end

    // Read Logic
    always @(posedge clk) begin
        rd_data <= ram_mem[rd_addr];
    end
endmodule

// để so sánh với output của python thì viết testbench để test hoặc viết script python