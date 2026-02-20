module kernel (
    input wire clk,
    input wire rst_n,

    input wire [7:0] top,
    input wire [7:0] mid,
    input wire [7:0] bot,
    input wire valid_in,

    input wire top_edge,
    input wire bot_edge,
    input wire left_edge,
    input wire right_edge,

    output wire [7:0] pixel_out,
    output reg valid_out
);
    reg [7:0] p11, p12, p13;
    reg [7:0] p21, p22, p23;
    reg [7:0] p31, p32, p33;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {p11, p12, p13} <= 0;
            {p21, p22, p23} <= 0;
            {p31, p32, p33} <= 0;
        end else if (valid_in) begin
            {p11, p12, p13} <= {p12, p13, top};
            {p21, p22, p23} <= {p22, p23, mid};
            {p31, p32, p33} <= {p32, p33, bot};
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

    reg [7:0] m11, m12, m13;
    reg [7:0] m21, m22, m23;
    reg [7:0] m31, m32, m33;

    always @(*) begin
        {m11, m12, m13} = {p11, p12, p13};
        {m21, m22, m23} = {p21, p22, p23};
        {m31, m32, m33} = {p31, p32, p33};

        if (top_edge) begin
            {m11, m12, m13} = 0;
        end

        if (bot_edge) begin
            {m31, m32, m33} = 0;
        end

        if (left_edge) begin
            {m11, m21, m31} = 0;
        end

        if (right_edge) begin
            {m13, m23, m33} = 0;
        end
    end

    /*
    Weight = [1, 2, 1],
             [2, 4, 2],
             [1, 2, 1]
    */
    wire [11:0] sum = (m11 + (m12 << 1) + m13) +
                      ((m21 << 1) + (m22 << 2) + (m23 << 1)) +
                      (m31 + (m32 << 1) + m33);
    wire [11:0] sum_rounded = sum + 8;
    assign pixel_out = sum_rounded[11:4]; // >> 4 (divided by 16)
endmodule
// Think if img so small that padding 1 time is not enough, need more padding such as 1x1 or 2x2