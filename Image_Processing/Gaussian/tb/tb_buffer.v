//iverilog -o run tb_buffer.v ../rtl/line_buffer.v
module tb_buffer;
    parameter W = 9;
    parameter H = 6;

    reg clk, rst_n;
    reg [7:0] pixel_in;
    reg valid_in;
    wire [7:0] top, mid, bot;
    reg [7:0] exp_top, exp_mid, exp_bot;
    integer r, c, pass, fail;

    line_buffer #(
        .W(W)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),
        .pixel_in (pixel_in),
        .valid_in (valid_in),

        .top (top),
        .mid (mid),
        .bot (bot)
    );

    task divi;
        $display ("%0s", {80{"-"}});
    endtask

    task msg (input [255:0] txt);
        begin
            divi();
            $display ("%0s", txt);
            divi();
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        valid_in = 0;
        pixel_in = 0;
        pass = 0;
        fail = 0;
        #10;

        msg ("TEST BEGIN");
        repeat (W) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        $display ("Format: [Row-Col] | Pixel In | Top | Mid | Bot");

        for (r = 0; r < H; r = r + 1) begin
            $display ("----- Processing Row %0d -----", r);

            for (c = 0; c < W; c = c + 1) begin
                @(posedge clk);
                #1;
                valid_in = 1;
                pixel_in = (r * 16) + c;
                #1;
                // Encode (row, col) into 0xRC format: row in high nibble, col in low nibble

                $display ("Time = %4t | [%0d-%0d] | Pixel In: %h | Top: %h | Mid: %h | Bot: %h", $time, r, c, pixel_in, top, mid, bot);

                exp_bot = (r * 16) + c;
                exp_mid = (r >= 1) ? ((r-1) * 16 + c) : 0;
                exp_top = (r >= 2) ? ((r-2) * 16 + c) : 0;

                if (bot !== exp_bot) begin
                    $display ("[FAIL] Bot Wrong | Exp: %h | Got: %h", exp_bot, bot);
                    fail = fail + 1;
                    $finish;
                end else begin
                    pass = pass + 1;
                end

                if (mid !== exp_mid) begin
                    $display ("[FAIL] Mid Wrong | Exp: %h | Got: %h", exp_mid, mid);
                    fail = fail + 1;
                    $finish;
                end else begin
                    pass = pass + 1;
                end

                if (top !== exp_top) begin
                    $display ("[FAIL] Top Wrong | Exp: %h | Got: %h", exp_top, top);
                    fail = fail + 1;
                    $finish;
                end else begin
                    pass = pass + 1;
                end
            end
        end

        @(posedge clk);
        #1 valid_in = 0;
        #10;

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

        #10 $finish;
    end
endmodule