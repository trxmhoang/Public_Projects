module line_buffer #(
    parameter W = 64
)(
    input wire clk,
    input wire rst_n,
    input wire [7:0] pixel_in,
    input wire valid_in,

    output wire [7:0] top,
    output wire [7:0] mid,
    output wire [7:0] bot
);
    (*ram_style = "distributed"*)
    reg [7:0] top_ram [0:W-1];
    reg [7:0] mid_ram [0:W-1];
    reg [$clog2(W)-1:0] ptr;

    wire [7:0] mid_next = valid_in ? pixel_in : mid_ram[ptr];
    wire [7:0] top_next = valid_in ? mid_ram[ptr] : top_ram[ptr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ptr <= 0;
            for (integer i = 0; i < W; i = i + 1) begin
                top_ram[i] <= 0;
                mid_ram[i] <= 0;
            end
            // Find a soloution to automatically manage this?
        end else begin
            top_ram[ptr] <= top_next;
            mid_ram[ptr] <= mid_next;
            
            if (ptr < W - 1) begin
                ptr <= ptr + 1;
            end else begin
                ptr <= 0;
            end
        end
    end

    assign top = top_ram[ptr];
    assign mid = mid_ram[ptr];
    assign bot = pixel_in;
endmodule