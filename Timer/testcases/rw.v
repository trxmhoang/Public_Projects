task run_test();
    begin
        //TCR
        test_bench.msg ("TCR");
        //1
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tcr, 32'h0);
        //2
        test_bench.exp_err = 1;
        test_bench.wr (test_bench.tcr, 32'hffff_ffff);
        test_bench.rd (test_bench.tcr, 32'h0);
        //3
        test_bench.exp_err = 0;
        test_bench.wr (test_bench.tcr, 32'hffff_0802);
        test_bench.rd (test_bench.tcr, 32'h0000_0802);
        //4
        test_bench.wr (test_bench.tcr, 32'h5555_5555);
        test_bench.rd (test_bench.tcr, 32'h0000_0501);
        //5
        test_bench.exp_err = 1;
        test_bench.wr (test_bench.tcr, 32'h5555_5553);
        test_bench.rd (test_bench.tcr, 32'h0000_0501);
        //6
        test_bench.wr (test_bench.tcr, 32'hcdef_5755);
        test_bench.rd (test_bench.tcr, 32'h0000_0501);
        //7
        test_bench.wr (test_bench.tcr, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tcr, 32'h0000_0501);
        //8
        test_bench.exp_err = 0;
        test_bench.wr (test_bench.tcr, 32'h0101_0510);
        test_bench.rd (test_bench.tcr, 32'h0000_0500);
        //9
        test_bench.wr (test_bench.tcr, 32'h1010_0603);
        test_bench.rd (test_bench.tcr, 32'h0000_0603);
        //10
        test_bench.exp_err = 1;
        test_bench.wr (test_bench.tcr, 32'habcd_0601);
        test_bench.rd (test_bench.tcr, 32'h0000_0603);
        //11
        test_bench.exp_err = 0;
        test_bench.wr (test_bench.tcr, 32'h5aa5_0602);
        test_bench.rd (test_bench.tcr, 32'h0000_0602);

        //TDR0
        test_bench.msg ("TDR0");
        $display ("\ttimer_en is OFF");
        
        test_bench.wr (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h0);

        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.rd (test_bench.tdr0, 32'hffff_ffff);

        test_bench.wr (test_bench.tdr0, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tdr0, 32'haaaa_aaaa);

        test_bench.wr (test_bench.tdr0, 32'h5555_5555);
        test_bench.rd (test_bench.tdr0, 32'h5555_5555);

        test_bench.wr (test_bench.tdr0, 32'habcd_ef98);
        test_bench.rd (test_bench.tdr0, 32'habcd_ef98);

        //TDR1
        test_bench.msg ("TDR1");
        test_bench.wr (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.rd (test_bench.tdr1, 32'hffff_ffff);

        test_bench.wr (test_bench.tdr1, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tdr1, 32'haaaa_aaaa);

        test_bench.wr (test_bench.tdr1, 32'h5555_5555);
        test_bench.rd (test_bench.tdr1, 32'h5555_5555);

        test_bench.wr (test_bench.tdr1, 32'habcd_ef98);
        test_bench.rd (test_bench.tdr1, 32'habcd_ef98);
     

        //TCMP0
        test_bench.msg ("TCMP0");
        test_bench.wr (test_bench.tcmp0, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'h0);

        test_bench.wr (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.rd (test_bench.tcmp0, 32'hffff_ffff);

        test_bench.wr (test_bench.tcmp0, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tcmp0, 32'haaaa_aaaa);

        test_bench.wr (test_bench.tcmp0, 32'h5555_5555);
        test_bench.rd (test_bench.tcmp0, 32'h5555_5555);

        test_bench.wr (test_bench.tcmp0, 32'habcd_ef98);
        test_bench.rd (test_bench.tcmp0, 32'habcd_ef98);
        
        //TCMP1
        test_bench.msg ("TCMP1");
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.rd (test_bench.tcmp1, 32'h0);

        test_bench.wr (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.rd (test_bench.tcmp1, 32'hffff_ffff);

        test_bench.wr (test_bench.tcmp1, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tcmp1, 32'haaaa_aaaa);

        test_bench.wr (test_bench.tcmp1, 32'h5555_5555);
        test_bench.rd (test_bench.tcmp1, 32'h5555_5555);

        test_bench.wr (test_bench.tcmp1, 32'habcd_ef98);
        test_bench.rd (test_bench.tcmp1, 32'habcd_ef98);
        
        //TIER
        test_bench.msg ("TIER");
        test_bench.wr (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tier, 32'h0);

        test_bench.wr (test_bench.tier, 32'hffff_ffff);
        test_bench.rd (test_bench.tier, 32'h1);

        test_bench.wr (test_bench.tier, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tier, 32'h0);

        test_bench.wr (test_bench.tier, 32'h5555_5555);
        test_bench.rd (test_bench.tier, 32'h1);

        test_bench.wr (test_bench.tier, 32'habcd_ef98);
        test_bench.rd (test_bench.tier, 32'h0);

        //TISR
        test_bench.msg ("TISR");
        test_bench.rd (test_bench.tisr, 32'h1);
        test_bench.wr (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.wr (test_bench.tcmp1, 32'hffff_ffff);

        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);

        test_bench.wr (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);

        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h0);

        test_bench.wr (test_bench.tisr, 32'haaaa_aaaa);
        test_bench.rd (test_bench.tisr, 32'h0);

        test_bench.wr (test_bench.tisr, 32'h5555_5555);
        test_bench.rd (test_bench.tisr, 32'h0);

        test_bench.wr (test_bench.tisr, 32'habcd_ef98);
        test_bench.rd (test_bench.tisr, 32'h0);

        //THCSR
        test_bench.msg ("THCSR");
        $display ("dbg_mode is ON");
        test_bench.wr (test_bench.thcsr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);

        test_bench.wr (test_bench.thcsr, 32'hffff_ffff);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'haaaa_aaaa);
        test_bench.rd (test_bench.thcsr, 32'h0);

        test_bench.wr (test_bench.thcsr, 32'h5555_5555);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.wr (test_bench.thcsr, 32'habcd_ef98);
        test_bench.rd (test_bench.thcsr, 32'h0);

        //RESET
        test_bench.msg ("RESET");
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.wr (test_bench.tdr0, 32'h0);
        test_bench.wr (test_bench.tdr1, 32'h0);

        test_bench.wr (test_bench.tcr, 32'h1);
        $display ("256 cycles have passed");
        repeat (256) @(posedge clk);
        test_bench.rd (test_bench.tdr0, 32'h0000_0103);
        test_bench.rd (test_bench.tdr1, 32'h0);
        
        $display ("Reset is ON");
        @(posedge clk);
        rst_n = 0;    
        $display ("Reset is OFF");
        @(posedge clk);
        rst_n = 1;

        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'hFFFF_FFFF);
        test_bench.rd (test_bench.tcmp1, 32'hFFFF_FFFF);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);    
    end
endtask
