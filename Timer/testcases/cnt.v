task run_test();
    begin
        //CASE 1
        test_bench.msg ("CASE 1");

        test_bench.wr (test_bench.tdr0, 32'hffff_ff00);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h4);
        test_bench.rd (test_bench.tdr1, 32'h1);

        //CASE 2
        test_bench.msg ("CASE 2");
        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'hffff_ff00);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h3);
        test_bench.rd (test_bench.tdr1, 32'h1);

        //CASE 3
        test_bench.msg ("CASE 3");
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'hffff_ff00);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h4);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        //CASE 4
        test_bench.msg ("CASE 4");
        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);
        test_bench.wr (test_bench.tdr1, 32'hFFFF_FFFF);
        test_bench.wr (test_bench.tdr0, 32'hFFFF_FFFD);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h8);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        //CASE 5
        test_bench.msg ("CASE 5");
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 clocks cycle have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0103);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tdr0, 32'hffff_ff00);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h3);
        test_bench.rd (test_bench.tdr1, 32'h1);

        //CASE 6
        test_bench.msg ("CASE 6");
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("300 clock cycles have passed");
        repeat (300) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_012f);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tdr0, 32'h1234_5678);
        test_bench.wr (test_bench.tdr1, 32'h8765_4321);
        test_bench.rd (test_bench.tdr0, 32'h1234_5678);
        test_bench.rd (test_bench.tdr1, 32'h8765_4321);        
    end
endtask
