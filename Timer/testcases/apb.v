task run_test();
    begin
        test_bench.msg ("PSEL IS OFF, PENABLE IS ON");
        test_bench.msg ("WRITE ERROR");
        test_bench.xsel = 1;  
        test_bench.wr (test_bench.tcr, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcmp0, 32'h0);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tier, 32'hffff_ffff);        
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.wr (test_bench.thcsr, 32'hffff_ffff);
        
        test_bench.xsel = 0;
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.rd (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);

        test_bench.msg ("READ ERROR");
        test_bench.xsel = 1;  
        test_bench.rd (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'h0);
        test_bench.rd (test_bench.tcmp1, 32'h0);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);
        test_bench.xsel = 0;

        test_bench.msg ("PSEL IS ON, PENABLE IS OFF");
        test_bench.msg ("WRITE ERROR");
        test_bench.xen = 1;
        test_bench.wr (test_bench.tcr, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr0, 32'hffff_ffff);
        test_bench.wr (test_bench.tdr1, 32'hffff_ffff);
        test_bench.wr (test_bench.tcmp0, 32'h0);
        test_bench.wr (test_bench.tcmp1, 32'h0);
        test_bench.wr (test_bench.tier, 32'hffff_ffff);        
        test_bench.wr (test_bench.tisr, 32'hffff_ffff);
        test_bench.wr (test_bench.thcsr, 32'hffff_ffff);

        test_bench.xen = 0;
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.rd (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);
        
        test_bench.msg ("READ ERROR");
        test_bench.xen = 1;  
        test_bench.rd (test_bench.tcr, 32'h0);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'h0);
        test_bench.rd (test_bench.tcmp1, 32'h0);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);
        test_bench.xen = 0;

        test_bench.msg ("OUT-OF-RANGE DIV_VAL");
     
        test_bench.exp_err = 1;
        test_bench.wr (test_bench.tcr, 32'h0000_0900);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0A00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0B00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0C00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0D00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0E00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.wr (test_bench.tcr, 32'h0000_0F00);
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.exp_err = 0;
        test_bench.wr (test_bench.tcr, 32'h0000_0800);
        test_bench.rd (test_bench.tcr, 32'h0000_0800);
        
        test_bench.msg ("WW-RR");
        
        //write to tdr0
        @(posedge clk);
        #1;
        test_bench.paddr = test_bench.tdr0;
        test_bench.pwdata = 32'h5555_5555;
        test_bench.pwrite = 1;
        test_bench.psel = 1;
        test_bench.penable = 0;
        #1 test_bench.wr_p (test_bench.paddr, test_bench.pwdata);
        
        @(posedge clk);
        #1;
        test_bench.penable = 1;
        test_bench.pr_p(0, 0);

        wait (test_bench.pready === 1);
        
        //write to tdr1
        @(posedge clk);
        #1;
        test_bench.paddr = test_bench.tdr1;
        test_bench.pwdata = 32'h6666_6666;
        #1 test_bench.wr_p (test_bench.paddr, test_bench.pwdata);
        
        wait (test_bench.pready === 1);
        
        //read from tdr0
        @(posedge clk);
        #1;
        test_bench.pwrite = 0;
        test_bench.paddr = test_bench.tdr0;
        #1 test_bench.rd_p (test_bench.paddr, 32'h5555_5555);
        
        wait (test_bench.pready === 1);
        #1 test_bench.rd_c (test_bench.paddr, 32'h5555_5555);
        
        //read from tdr1
        @(posedge clk);
        #1 test_bench.paddr = test_bench.tdr1;
        #1 test_bench.rd_p (test_bench.paddr, 32'h6666_6666);
        
        wait (test_bench.pready === 1);
        #1 test_bench.rd_c (test_bench.paddr, 32'h6666_6666);
        
        //transfer ended
        @(posedge clk);
        #1;
        test_bench.psel = 0;
        test_bench.penable = 0;
        test_bench.paddr = 0;
        test_bench.pwdata = 0;
        #1 test_bench.pr_p(0, 1);

        test_bench.msg ("WR-WR");
       
        //write to tdr0
        @(posedge clk);
        #1;
        test_bench.paddr = test_bench.tdr0;
        test_bench.pwdata = 32'h7777_7777;
        test_bench.pwrite = 1;
        test_bench.psel = 1;
        test_bench.penable = 0;
        #1 test_bench.wr_p (test_bench.paddr, test_bench.pwdata);
        
        @(posedge clk);
        #1;
        test_bench.penable = 1;
        test_bench.pr_p(0, 0);

        wait (test_bench.pready === 1);
        
        //read from tdr0
        @(posedge clk);
        #1;
        test_bench.pwrite = 0;
        test_bench.paddr = test_bench.tdr0;
        #1 test_bench.rd_p (test_bench.paddr, 32'h7777_7777);
        
        wait (test_bench.pready === 1);
        #1 test_bench.rd_c (test_bench.paddr, 32'h7777_7777);
        
        //write to tdr1
        @(posedge clk);
        #1;
        pwrite = 1;
        test_bench.paddr = test_bench.tdr1;
        test_bench.pwdata = 32'h8888_8888;
        #1 test_bench.wr_p (test_bench.paddr, test_bench.pwdata);
        
        wait (test_bench.pready === 1);
        
        //read from tdr1
        @(posedge clk);
        #1;
        pwrite = 0;
        test_bench.paddr = test_bench.tdr1;
        #1 test_bench.rd_p (test_bench.paddr, 32'h8888_8888);
        
        wait (test_bench.pready === 1);
        #1 test_bench.rd_c (test_bench.paddr, 32'h8888_8888);
        
        //transfer ended
        @(posedge clk);
        #1;
        test_bench.psel = 0;
        test_bench.penable = 0;
        test_bench.paddr = 0;
        test_bench.pwdata = 0;
        #1 test_bench.pr_p(0, 1);
    end
endtask
