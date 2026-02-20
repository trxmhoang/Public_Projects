module divider #(
    parameter W = 64,
    parameter H = 64,
    parameter TOTAL_PIXEL = W * H,
    parameter TOTAL_PIXEL_BIT = $clog2(W * H)
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg done,

    input wire [31:0] dividend,
    input wire [TOTAL_PIXEL_BIT:0] divisor,
    output reg [31:0] quotient,
    output reg [31:0] remainder
);

    reg [5:0] count; // count for 32 iterations
    reg busy;
    reg [31:0] temp_dividend;
    reg [31:0] temp_remainder;

    wire [32:0] divisor_extend = {1'b0, {(32-(TOTAL_PIXEL_BIT + 1)){1'b0}}, divisor};
    wire [32:0] sub = {1'b0, temp_remainder[30:0], temp_dividend[31]} - divisor_extend;

    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 0;
            done <= 0;
            count <= 0;

            quotient <= 0;
            remainder <= 0;
            temp_dividend <= 0;
            temp_remainder <= 0;
        end else begin
            if (start) begin
                count <= 32;
                busy <= 1;
                done <= 0;

                temp_dividend <= dividend;
                temp_remainder <= 0;
            end else if (busy) begin
                //{temp_remainder, temp_dividend} =  {temp_remainder[30:0], temp_dividend, 1'b0};
                if (!sub[32]) begin
                    temp_remainder <= sub[31:0];
                    temp_dividend <= {temp_dividend[30:0], 1'b1};
                end else begin
                    temp_remainder <= {temp_remainder[30:0], temp_dividend[31]};
                    temp_dividend <= {temp_dividend[30:0], 1'b0};
                end

                if (count == 1) begin
                    busy <= 0;
                    done <= 1;

                   if (!sub[32]) begin
                        quotient <= {temp_dividend[30:0], 1'b1};
                        remainder <= sub[31:0];
                    end else begin
                        quotient <= {temp_dividend[30:0], 1'b0};
                        remainder <= {temp_remainder[30:0], dividend[31]};
                    end
                end else begin
                    count <= count - 1;
                end
            end else begin
                done <= 0;
            end
        end
    end
endmodule