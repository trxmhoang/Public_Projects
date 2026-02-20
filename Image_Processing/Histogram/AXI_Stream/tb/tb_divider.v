//iverilog -o run tb_divider.v ../rtl/divider.v
module tb_divider;
    parameter W = 64;
    parameter H = 64;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);

    reg clk, start;
    wire done;
    reg [31:0] dividend;
    reg [TOTAL_PIXEL_BIT-1:0] divisor;
    wire [31:0] quotient, remainder;
    reg [31:0] exp_quot, exp_rem;

    integer i, pass, fail;

    divider #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut (
        .clk(clk),
        .start(start),
        .done(done),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(quotient),
        .remainder(remainder)
    );

    task br;
        $display ("%0s", {110{"="}});
    endtask

    task msg (input [255:0] txt);
        begin
            br();
            $display ("%0s", txt);
            br();
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        start = 0;
        dividend = 0;
        divisor = 1;
        pass = 0;
        fail = 0;
        #10;

        msg ("TEST BEGIN");
        for (i = 0; i < 50; i = i + 1) begin
            dividend = $urandom_range(16711680, TOTAL_PIXEL);
            divisor = $urandom_range(TOTAL_PIXEL, 1);
            #1;
            exp_quot = dividend/divisor;
            exp_rem = dividend%divisor;
            
            @(posedge clk);
            #1 start = 1;
            @(posedge clk);
            #1 start = 0;

            wait(done == 1);
            #1;

            if (quotient == exp_quot && remainder == exp_rem) begin
                $display ("[PASS] t = %5t | %8d / %8d | Quot = %8d (exp = %8d), Rem = %8d (exp = %8d)", $time, dividend, divisor, quotient, exp_quot, remainder, exp_rem);
                pass = pass + 1;
            end else begin
                $display ("[FAIL] t = %5t | %8d / %8d | Quot = %8d (exp = %8d), Rem = %8d (exp = %8d)", $time, dividend, divisor, quotient, exp_quot, remainder, exp_rem);
                fail = fail + 1;
            end

            @(posedge clk);
            #1;
        end

        msg ("SUMMARY");
        $display ("TOTAL TESTS : %0d", pass + fail);
        $display ("TOTAL PASSED: %0d", pass);
        $display ("TOTAL FAILED: %0d", fail);

        if (fail == 0) 
            $display ("======> ALL TESTS PASSED");
        else if (pass == 0)
            $display ("======> ALL TESTS FAILED");
        else
            $display ("======> SOME TESTS FAILED");

        msg ("TEST END");
        #100 $finish;
    end
endmodule