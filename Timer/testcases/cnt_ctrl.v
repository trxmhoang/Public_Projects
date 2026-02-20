task run_test();
    begin
        $display ("dbg_mode is ON");
        //DIV_EN = 0  
        test_bench.msg ("DIV_EN = 0");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("50 clock cycles have passed");
        repeat (50) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h36);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h39);
        test_bench.rd (test_bench.tdr1, 32'h0);  
        
        test_bench.msg ("CASE 2");
      
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'd500);
        test_bench.wr (test_bench.tdr1, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h1);

        $display ("120 clock cycles have passed");
        repeat (120) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'd624);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'd627);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        //DIV_EN = 1, DIV_VAL = 0
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 0");
        test_bench.msg ("CASE 1");
       
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tcr, 32'h3);

        $display ("629 clock cycles have passed");
        repeat (629) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'd633);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'd636);
        test_bench.rd (test_bench.tdr1, 32'h0);
       
        test_bench.msg ("CASE 2"); 
       
        test_bench.wr (test_bench.tcr, 32'h2);
        test_bench.wr (test_bench.tdr0, 32'hffff_ff56);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcr, 32'h3);
        
        $display ("20 clock cycles have passed");
        repeat (20) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.wr (test_bench.tdr0, 32'hffff_ff6E);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'hffff_ff71);
        test_bench.rd (test_bench.tdr1, 32'hffff_ffff);

        //DIV_EN = 1, DIV_VAL = 1
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 1");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h2);
        test_bench.wr (test_bench.tcr, 32'h0000_0103);
        
        $display ("615 clock cycles have passed"); 
        repeat (615) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h135);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h137);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0102);
        test_bench.wr (test_bench.tdr0, 32'habcd_ef98);
        test_bench.wr (test_bench.tdr1, 32'hef98_ffff);
        test_bench.wr (test_bench.tcr, 32'h0000_0103);
        
        $display ("65 clock cycles have passed");
        repeat (65) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'habcd_efba);
        test_bench.rd (test_bench.tdr1, 32'hef98_ffff);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'habcd_efbc);
        test_bench.rd (test_bench.tdr1, 32'hef98_ffff);

        //DIV_EN = 1, DIV_VAL = 2
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 2");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h0000_0102);
        test_bench.wr (test_bench.tcr, 32'h0000_0203);
        
        $display ("80 clock cycles have passed");
        repeat (80) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h15);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h15);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0202);
        test_bench.wr (test_bench.tdr0, 32'h9876_5432);
        test_bench.wr (test_bench.tdr1, 32'h1234_5678);
        test_bench.wr (test_bench.tcr, 32'h0000_0203);
        
        $display ("780 clock cycles have passed");
        repeat (780) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h9876_54f6);
        test_bench.rd (test_bench.tdr1, 32'h1234_5678);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("3 clock cycles have passed");
        repeat (3) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h9876_54f7);
        test_bench.rd (test_bench.tdr1, 32'h1234_5678);
        
        //DIV_EN = 1, DIV_VAL = 3
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 3");
        test_bench.msg ("CASE 1");
     
        test_bench.wr (test_bench.tcr, 32'h0000_0202);
        test_bench.wr (test_bench.tcr, 32'h0000_0303);
        
        $display ("950 clock cycles have passed");
        repeat (950) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h77);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("10 clock cycles have passed");
        repeat (10) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h78);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0302);
        test_bench.wr (test_bench.tdr0, 32'h5555_aaaa);
        test_bench.wr (test_bench.tdr1, 32'haaaa_5555);
        test_bench.wr (test_bench.tcr, 32'h0000_0303);
        
        $display ("33 clock cycles have passed");
        repeat (33) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h5555_aaae);
        test_bench.rd (test_bench.tdr1, 32'haaaa_5555);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("22 clock cycles have passed");
        repeat (22) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h5555_aab1);
        test_bench.rd (test_bench.tdr1, 32'haaaa_5555);

        //DIV_EN = 1, DIV_VAL = 4
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 4");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h0000_0302);
        test_bench.wr (test_bench.tcr, 32'h0000_0403);
        
        $display ("324 clock cycles have passed");
        repeat (324) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h14);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("10 clock cycles have passed");
        repeat (10) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h15);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0402);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'h7fff_ffff);
        test_bench.wr (test_bench.tcr, 32'h0000_0403);
        
        $display ("920 clock cycles have passed");
        repeat (920) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0038);
        test_bench.rd (test_bench.tdr1, 32'h8000_0000);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("25 clock cycles have passed");
        repeat (25) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_003a);
        test_bench.rd (test_bench.tdr1, 32'h8000_0000);

        //DIV_EN = 1, DIV_VAL = 5
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 5");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h0000_0402);
        test_bench.wr (test_bench.tcr, 32'h0000_0503);
        
        $display ("867 clock cycles have passed");
        repeat (867) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h1b);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("55 clock cycles have passed");
        repeat (55) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h1d);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");
        test_bench.wr (test_bench.tcr, 32'h0000_0502);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'h000_0067);
        test_bench.wr (test_bench.tcr, 32'h0000_0503);
        
        $display ("78 clock cycles have passed");
        repeat (78) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0001);
        test_bench.rd (test_bench.tdr1, 32'h0000_0068);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("159 clock cycles have passed");
        repeat (159) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0006);
        test_bench.rd (test_bench.tdr1, 32'h0000_0068);
        
        //DIV_EN = 1, DIV_VAL = 6
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 6");
        test_bench.msg ("CASE 1");
        
        test_bench.wr (test_bench.tcr, 32'h0000_0502);
        test_bench.wr (test_bench.tcr, 32'h0000_0603);
        
        $display ("777 clock cycles have passed");
        repeat (777) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'hc);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("222 clock cycles have passed");
        repeat (222) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'hf);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");
        test_bench.wr (test_bench.tcr, 32'h0000_0602);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'h000_0067);
        test_bench.wr (test_bench.tcr, 32'h0000_0603);
        
        $display ("78 clock cycles have passed");
        repeat (78) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0000);
        test_bench.rd (test_bench.tdr1, 32'h0000_0068);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("159 clock cycles have passed");
        repeat (159) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0002);
        test_bench.rd (test_bench.tdr1, 32'h0000_0068);
        
        //DIV_EN = 1, DIV_VAL = 7
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 7");
        test_bench.msg ("CASE 1");
     
        test_bench.wr (test_bench.tcr, 32'h0000_0602);
        test_bench.wr (test_bench.tcr, 32'h0000_0703);
        
        $display ("568 clock cycles have passed");
        repeat (568) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h4);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("256 clock cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h6);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0702);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ff5f);
        test_bench.wr (test_bench.tcr, 32'h0000_0703);
        
        $display ("779 clock cycles have passed");
        repeat (779) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0000_0005);
        test_bench.rd (test_bench.tdr1, 32'hffff_ff60);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("239 clock cycles have passed");
        repeat (239) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0007);
        test_bench.rd (test_bench.tdr1, 32'hffff_ff60);
        
        //DIV_EN = 1, DIV_VAL = 8
        test_bench.msg ("DIV_EN = 1, DIV_VAL = 8");
        test_bench.msg ("CASE 1");
      
        test_bench.wr (test_bench.tcr, 32'h0000_0702);
        test_bench.wr (test_bench.tcr, 32'h0000_0803);
        
        $display ("999 clock cycles have passed");
        repeat (999) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h3);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("333 clock cycles have passed");
        repeat (333) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h5);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.msg ("CASE 2");

        test_bench.wr (test_bench.tcr, 32'h0000_0802);
        test_bench.wr (test_bench.tdr0, 32'h0000_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcr, 32'h0000_0803);
        
        $display ("300 clock cycles have passed");
        repeat (300) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h0001_0000);
        test_bench.rd (test_bench.tdr1, 32'hffff_ffff);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("777 clock cycles have passed");
        repeat (777) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0001_0003);
        test_bench.rd (test_bench.tdr1, 32'hffff_ffff);
        
        //DIV_EN = 0, DIV_VAL = 2
        test_bench.msg ("DIV_EN = 0, DIV_VAL = 2");
        
        test_bench.wr (test_bench.tcr, 32'h0000_0802);
        test_bench.wr (test_bench.tcr, 32'h0000_0201);
        
        $display ("20 clock cycles have passed");
        repeat (20) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h18);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("9 clock cycles have passed");
        repeat (9) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h24);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        //DIV_EN = 0, DIV_VAL = 8
        test_bench.msg ("DIV_EN = 0, DIV_VAL = 8");
        
        test_bench.exp_err = 1;
        test_bench.wr (test_bench.tcr, 32'h0000_0802);
        test_bench.rd (test_bench.tcr, 32'h0000_0201);
        test_bench.exp_err = 0;
        test_bench.wr (test_bench.tcr, 32'h0000_0200);
        test_bench.wr (test_bench.tcr, 32'h0000_0801);
        
        $display ("20 clock cycles have passed");
        repeat (20) @(posedge clk);
        test_bench.wr (test_bench.thcsr, 32'h1);
        test_bench.rd (test_bench.tdr0, 32'h18);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'h0);
        $display ("9 clock cycles have passed");
        repeat (9) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h24);
        test_bench.rd (test_bench.tdr1, 32'h0);
    end
endtask
