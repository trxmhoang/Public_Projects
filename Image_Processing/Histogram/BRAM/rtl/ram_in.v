module ram_in #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,
    input wire [TOTAL_PIXEL_BIT-1:0] rd_addr,
    output reg [7:0] rd_data
);

    (* ram_style = "block" *)
    reg [7:0] ram_mem [0:TOTAL_PIXEL-1];

    initial begin
        $readmemh("img_in.mem", ram_mem);
    end

    always @(posedge clk) begin
        rd_data <= ram_mem[rd_addr];
    end
endmodule