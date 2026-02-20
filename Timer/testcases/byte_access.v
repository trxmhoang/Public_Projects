task run_test();
    begin
        strb = 1;
        //TCR
        test_bench.msg ("TCR");
        
        test_bench.exp_err = 0;
        test_bench.pstrb = 4'hf;
        test_bench.wr (test_bench.tcr, 32'h2222_2222);
        test_bench.rd (test_bench.tcr, 32'h0000_0202);

        test_bench.pstrb = 4'h7;
        test_bench.wr (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tcr, 32'h0);

        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tcr, 32'hffff_f5ff);
        test_bench.rd (test_bench.tcr, 32'h0000_0500);

        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tcr, 32'hffff_ffff);
        test_bench.rd (test_bench.tcr, 32'h0000_0503);

        test_bench.pstrb = 4'h0;
        test_bench.wr (test_bench.tcr, 32'h0000_0003);
        test_bench.rd (test_bench.tcr, 32'h0000_0503);
        
        test_bench.exp_err = 1;
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tcr, 32'hffff_f605);
        test_bench.rd (test_bench.tcr, 32'h0000_0503);
        
        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tcr, 32'hffff_f803);
        test_bench.rd (test_bench.tcr, 32'h0000_0503);
        
        //TDR0
        test_bench.msg ("TDR0");
        
        @(posedge clk);
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;

        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tdr0, 32'h1111_1111);
        test_bench.rd (test_bench.tdr0, 32'h0000_0011);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tdr0, 32'h2222_2222);
        test_bench.rd (test_bench.tdr0, 32'h0000_2211);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tdr0, 32'h3333_3333);
        test_bench.rd (test_bench.tdr0, 32'h0033_2211);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tdr0, 32'h4444_4444);
        test_bench.rd (test_bench.tdr0, 32'h4433_2211);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tdr0, 32'h5555_5555);
        test_bench.rd (test_bench.tdr0, 32'h4433_5555);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tdr0, 32'h6666_6666);
        test_bench.rd (test_bench.tdr0, 32'h6666_5555);

        //TDR1
        test_bench.msg ("TDR1");
        
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tdr1, 32'h1111_1111);
        test_bench.rd (test_bench.tdr1, 32'h0000_0011);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tdr1, 32'h2222_2222);
        test_bench.rd (test_bench.tdr1, 32'h0000_2211);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tdr1, 32'h3333_3333);
        test_bench.rd (test_bench.tdr1, 32'h0033_2211);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tdr1, 32'h4444_4444);
        test_bench.rd (test_bench.tdr1, 32'h4433_2211);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tdr1, 32'h5555_5555);
        test_bench.rd (test_bench.tdr1, 32'h4433_5555);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tdr1, 32'h6666_6666);
        test_bench.rd (test_bench.tdr1, 32'h6666_5555);

        //TCMP0
        test_bench.msg ("TCMP0");
        
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tcmp0, 32'h1111_1111);
        test_bench.rd (test_bench.tcmp0, 32'hffff_ff11);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tcmp0, 32'h2222_2222);
        test_bench.rd (test_bench.tcmp0, 32'hffff_2211);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tcmp0, 32'h3333_3333);
        test_bench.rd (test_bench.tcmp0, 32'hff33_2211);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tcmp0, 32'h4444_4444);
        test_bench.rd (test_bench.tcmp0, 32'h4433_2211);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tcmp0, 32'h5555_5555);
        test_bench.rd (test_bench.tcmp0, 32'h4433_5555);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tcmp0, 32'h6666_6666);
        test_bench.rd (test_bench.tcmp0, 32'h6666_5555);

        //TCMP1
        test_bench.msg ("TCMP1");
        
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tcmp1, 32'h1111_1111);
        test_bench.rd (test_bench.tcmp1, 32'hffff_ff11);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tcmp1, 32'h2222_2222);
        test_bench.rd (test_bench.tcmp1, 32'hffff_2211);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tcmp1, 32'h3333_3333);
        test_bench.rd (test_bench.tcmp1, 32'hff33_2211);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tcmp1, 32'h4444_4444);
        test_bench.rd (test_bench.tcmp1, 32'h4433_2211);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tcmp1, 32'h5555_5555);
        test_bench.rd (test_bench.tcmp1, 32'h4433_5555);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tcmp1, 32'h6666_6666);
        test_bench.rd (test_bench.tcmp1, 32'h6666_5555);

        //TIER
        test_bench.msg ("TIER");
        
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tier, 32'h1111_1111);
        test_bench.rd (test_bench.tier, 32'h1);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tier, 32'h2222_2222);
        test_bench.rd (test_bench.tier, 32'h1);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tier, 32'h3333_3333);
        test_bench.rd (test_bench.tier, 32'h1);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tier, 32'h4444_4444);
        test_bench.rd (test_bench.tier, 32'h1);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tier, 32'h6666_6666);
        test_bench.rd (test_bench.tier, 32'h0);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tier, 32'h7777_7777);
        test_bench.rd (test_bench.tier, 32'h0);

        //TISR
        test_bench.msg ("TISR");
        
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h1);
 
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h1);
   
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h1);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.rd (test_bench.tisr, 32'h1);
        
        //set tcmp to not match with cnt
        test_bench.pstrb = 4'hf;
        test_bench.wr (test_bench.tcmp0, 32'h0);
        test_bench.wr (test_bench.tcmp1, 32'h0);

        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);

        //set tcmp to match with cnt
        test_bench.pstrb = 4'hf;
        test_bench.wr (test_bench.tcmp0, 32'h6666_5555);
        test_bench.wr (test_bench.tcmp1, 32'h6666_5555);
        test_bench.rd (test_bench.tisr, 32'h1);
        
        //set tcmp to not match with cnt
        test_bench.wr (test_bench.tcmp0, 32'h0);
        test_bench.wr (test_bench.tcmp1, 32'h0);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.tisr, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);

        //THCSR
        test_bench.msg ("THCSR");
        
        test_bench.pstrb = 4'h1;
        test_bench.wr (test_bench.thcsr, 32'h1111_1111);
        test_bench.rd (test_bench.thcsr, 32'h3);
 
        test_bench.pstrb = 4'h2;
        test_bench.wr (test_bench.thcsr, 32'h2222_2222);
        test_bench.rd (test_bench.thcsr, 32'h3);
   
        test_bench.pstrb = 4'h4;
        test_bench.wr (test_bench.thcsr, 32'h3333_3333);
        test_bench.rd (test_bench.thcsr, 32'h3);
 
        test_bench.pstrb = 4'h8;
        test_bench.wr (test_bench.thcsr, 32'h4444_4444);
        test_bench.rd (test_bench.thcsr, 32'h3);

        test_bench.pstrb = 4'h3;
        test_bench.wr (test_bench.thcsr, 32'h6666_6666);
        test_bench.rd (test_bench.thcsr, 32'h0);
 
        test_bench.pstrb = 4'hc;
        test_bench.wr (test_bench.thcsr, 32'h7777_7777);
        test_bench.rd (test_bench.thcsr, 32'h0);
    end
endtask
