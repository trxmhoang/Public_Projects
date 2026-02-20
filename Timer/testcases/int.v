task run_test();
    begin
        test_bench.msg ("INTERRUPT PENDING");
        //CASE 1
        test_bench.msg ("CASE 1");
        
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.wr (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);
        
        //CASE 2
        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcmp0, 32'hff);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("252 clock cycles have passed");
        repeat (252) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'hff);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(0);
        
        //CASE 3
        test_bench.msg ("CASE 3");

        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(0);
        test_bench.wr (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);
        
        //CASE 4
        test_bench.msg ("CASE 4");
        
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.wr (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h1);

        @(posedge clk);
        test_bench.rst_n = 0;
        @(posedge clk);
        test_bench.rst_n = 1;

        test_bench.msg ("INTERRUPT ENABLE");
        //CASE 5
        test_bench.msg ("CASE 5");

        test_bench.wr (test_bench.tcmp0, 32'hff);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'h0);
        test_bench.wr (test_bench.tdr1, 32'h0);
        test_bench.wr (test_bench.tier, 32'h1);
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("252 clock cycles have passed");
        repeat (252) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'hff);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(1);
        
        //CASE 6
        test_bench.msg ("CASE 6");
      
        test_bench.wr (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.int_p(0);
        
        //CASE 7
        test_bench.msg ("CASE 7");
      
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.wr (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tier, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(1);
     
        //CASE 8
        test_bench.msg ("CASE 8");   
        test_bench.wr (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(0);
        test_bench.wr (test_bench.tisr, 32'h1);
        
        test_bench.msg ("FUNCTIONALITY");
        //CASE 9
        test_bench.msg ("CASE 9");
        test_bench.wr (test_bench.tdr0, 32'h0);
        test_bench.wr (test_bench.tdr1, 32'h0);
        test_bench.wr (test_bench.tcmp0, 32'h5);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tier, 32'h1);
        test_bench.wr (test_bench.tcr, 32'h1);
        
        $display ("5 clock cycles have passed");
        repeat (5) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h8);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(1);

        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(1);
        
        //CASE 10
        test_bench.msg ("CASE 10");

        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tier, 32'h0);
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.int_p(0);

        test_bench.wr (test_bench.tcmp0, 32'h5);
        test_bench.wr (test_bench.tcmp1, 32'h7);
        test_bench.wr (test_bench.tdr0, 32'h5);
        test_bench.wr (test_bench.tdr1, 32'h7);

        test_bench.wr (test_bench.tier, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.int_p(1);

        $display ("Reset is ON");
        @(posedge clk);
        rst_n = 0;
        $display ("Reset is OFF");
        @(posedge clk);
        rst_n = 1;
        
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.int_p(0);
        
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcmp0, 32'hff);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'h0);
        test_bench.wr (test_bench.tdr1, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);

        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0103);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tier, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0113);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.int_p(1);
    end
endtask
