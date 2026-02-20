task run_test();
    begin
        test_bench.divi();
        $display ("dbg_mode is OFF");
        test_bench.dbg_mode = 0;
        
        //CASE 1
        test_bench.msg ("CASE 1");

        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0103);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0113);
        test_bench.rd (test_bench.tdr1, 32'h0); 

        //CASE 2
        test_bench.msg ("CASE 2");
        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcr, 32'h1);
        
        $display ("450 clock cycles have passed");
        repeat (450) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_01cc);
        test_bench.rd (test_bench.tdr1, 32'h0);
    end
endtask
