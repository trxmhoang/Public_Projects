//iverilog -o run tb_kernel.v ../rtl/kernel.v
module tb_kernel;
    reg clk, rst_n;
    reg [7:0] top, mid, bot;
    reg valid_in;
    reg top_edge, bot_edge;
    reg left_edge, right_edge;
    wire [7:0] pixel_out;
    wire valid_out;
    integer pass, fail;

    kernel dut (
        .clk (clk),
        .rst_n (rst_n),
        .top (top),
        .mid (mid),
        .bot (bot),
        .valid_in (valid_in),

        .top_edge (top_edge),
        .bot_edge (bot_edge),
        .left_edge (left_edge),
        .right_edge (right_edge),

        .pixel_out (pixel_out),
        .valid_out (valid_out)        
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

    task set_col (input [7:0] top_val, input [7:0] mid_val, input [7:0] bot_val);
        begin
            @(posedge clk);
            #1;
            valid_in = 1;
            {top, mid, bot} = {top_val, mid_val, bot_val};
        end
    endtask

    task check (input [3:0] edges, input [7:0] exp);
        begin
            @(posedge clk);
            #1;
            valid_in = 0;
            {top_edge, bot_edge, left_edge, right_edge} = edges;
            #1;

            $display ("Time = %5t | Edges: %b | Exp: %d | Output: %d", $time, edges, exp, pixel_out);

            if (pixel_out !== exp) begin
                $display ("[FAIL] Output value is different from expected value, check your algorithm!");
                fail = fail + 1;
                //$finish;
            end else begin
                pass = pass + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        {top, bot, mid} = 0;
        valid_in = 0;
        {top_edge, bot_edge, left_edge, right_edge} = 0;
        pass = 0;
        fail = 0;
        #10;

        msg ("TEST BEGIN");
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        msg ("\tCase 1:");
        $display ("[16, 16, 16],\n[16, 16, 16],\n[16, 16, 16]");
        set_col (16, 16, 16);
        set_col (16, 16, 16);
        set_col (16, 16, 16);
        check (4'b0000, 16);
        check (4'b0001, 12);
        check (4'b1010, 9);

        msg ("\tCase 2:");
        $display ("[55,  30,  25],\n[25, 255, 230],\n[10,  50, 130]");
        set_col (55, 30, 25);
        set_col (25, 255, 230);
        set_col (10, 50, 130);
        check (4'b0000, 119);
        check (4'b0001, 104);
        check (4'b0110, 74);
        check (4'b1001, 98);
        check (4'b0101, 74);
        check (4'b1010, 107);

        msg ("\tCase 3:");
        $display ("[255,  44,  77],\n[ 80, 240, 179],\n[165, 231,  79]");
        set_col (255, 44, 77);
        set_col (80, 240, 179);
        set_col (165, 231, 79);
        check (4'b0000, 163);
        check (4'b0001, 119);
        check (4'b0110, 109);
        check (4'b1001, 93);
        check (4'b0101, 91);
        check (4'b1010, 116);

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