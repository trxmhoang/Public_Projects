module test_bench;
    reg  clk, rst_n;
    reg  psel, pwrite, penable;
    reg  [11:0] paddr;
    reg  [31:0] pwdata;
    wire [31:0] prdata;
    reg  [3:0] pstrb;
    wire pready;
    wire pslverr;
    wire int;
    reg  dbg_mode;

    parameter tcr   = 12'h00;
    parameter tdr0  = 12'h04;
    parameter tdr1  = 12'h08;
    parameter tcmp0 = 12'h0C;
    parameter tcmp1 = 12'h10;
    parameter tier  = 12'h14;
    parameter tisr  = 12'h18;
    parameter thcsr = 12'h1C;
     
    integer pass, fail;
    reg     exp_err, strb, xsel, xen;

    `include "run_test.v"
    timer_top dut (.sys_clk (clk), .sys_rst_n (rst_n), .tim_psel (psel), .tim_pwrite (pwrite), .tim_penable (penable), 
                   .tim_paddr (paddr), .tim_pwdata (pwdata), .tim_prdata (prdata), .tim_pstrb (pstrb), .tim_pready (pready),
                   .tim_pslverr (pslverr), .tim_int (int), .dbg_mode (dbg_mode));
    
    task wr (input [11:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            wr_p(addr, data);
            paddr   = addr;
            pwdata  = data;
            pwrite  = 1;
            psel    = 1 & !xsel;
            penable = 0;
            

            @(posedge clk);
            #1 penable = 1 & !xen;
            
            if (xsel || xen) begin
                #1 pr_p(0, 2);
                @(posedge clk);
                #1;
                pr_p(0, 2);
                if (addr == tcr) err_p(exp_err);
            end else begin
                #1 pr_p(0, 0);
                wait (pready === 1);
                #1;
                if (addr == tcr) err_p(exp_err);    
            end
             
            @(posedge clk);
            #1;
            psel    = 0;
            penable = 0;
            pwrite  = 0;
            paddr   = 0;
            pwdata  = 0;
            #1 pr_p(0, 1);
        end
    endtask

    task rd (input [11:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            rd_p(addr, data);
            paddr   = addr;
            pwdata  = 0;
            pwrite  = 0;
            psel    = 1 & !xsel;
            penable = 0;

            @(posedge clk);
            #1 penable = 1 & !xen;

            if (xsel || xen) begin
                #1 pr_p(0, 2);
                @(posedge clk);
                #1;
                pr_p(0, 2);
                if (addr == tcr) err_p(exp_err);
            end else begin
                #1 pr_p(0, 0);
                wait (pready === 1);
                #1;
                rd_c(addr, data);
            end

            @(posedge clk);
            #1;
            psel    = 0;
            penable = 0;
            paddr   = 0;
            #1 pr_p(0, 1);
        end
    endtask
/*
    task wr_xsel (input [11:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            wr_p(addr, data);
            paddr   = addr;
            pwdata  = data;
            pwrite  = 1;
            psel    = 0;
            penable = 0;

            @(posedge clk);
            #1 penable = 1;
            #1 pr_p(0, 0);
        
            @(posedge clk);
            #1;
            pr_p(0, 2);
            if (addr == tcr) err_p(exp_err);

            @(posedge clk);
            #1;
            psel    = 0;
            penable = 0;
            pwrite  = 0;
            paddr   = 0;
            pwdata  = 0;
            #1 pr_p(0, 1);
        end
    endtask

    task wr_xen (input [11:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            wr_p(addr, data);
            paddr   = addr;
            pwdata  = data;
            pwrite  = 1;
            psel    = 1;
            penable = 0;

            @(posedge clk);
            #1 penable = 0;
            #1 pr_p(0, 0);

            @(posedge clk);
            #1;
            pr_p(0, 2);
            if (addr == tcr) err_p(exp_err);

            @(posedge clk);
            #1;
            psel    = 0;
            penable = 0;
            pwrite  = 0;
            paddr   = 0;
            pwdata  = 0;
            #1 pr_p(0, 1);
        end
    endtask
*/
    task divi;
        $display ("--------------------------------------------------------------------------");
    endtask

    task br;
        $display ("==========================================================================");
    endtask

    task rd_p (input [11:0] addr, input [31:0] data);
        begin
            divi();
            $display ("t = %10d | [READ]  addr = 12'h%3h, exp rdata = 32'h%8h", $time, addr, data);
            divi();
        end
    endtask

    task rd_c (input [11:0] addr, input [31:0] data);
        begin 
           if(prdata === data)
                begin
                    $display ("t = %10d | [PASS]  output rdata = 32'h%8h", $time, prdata);
                    pass = pass + 1;
                end
            else
                begin
                    $display ("t = %10d | [FAIL]  output rdata = 32'h%8h", $time, prdata);
                    fail = fail + 1;
                end
        end
    endtask

    task wr_p (input [11:0] addr, input [31:0] data);
        begin
            divi();
            if(strb)
                $display ("t = %10d | [WRITE] addr = 12'h%3h, wdata = 32'h%8h, strb = 4'h%1h", $time, addr, data, pstrb);
            else    
                $display ("t = %10d | [WRITE] addr = 12'h%3h, wdata = 32'h%8h", $time, addr, data);
            divi();
         end
    endtask
    
    task err_p (input err);
        begin
            if (pslverr === err) begin
                if (pslverr === 1)
                    $display ("t = %10d | [PASS]  pslverr is ON", $time);
                else
                    $display ("t = %10d | [PASS]  pslverr is OFF", $time);
                pass = pass + 1;
            end else begin
                if (pslverr === 1)
                    $display ("t = %10d | [FAIL]  pslverr is expected to be OFF", $time);
                else
                    $display ("t = %10d | [FAIL]  pslverr is expected to be ON", $time);
                fail = fail + 1;
            end
        end
    endtask

    task int_p (input exp_int);
        begin
            if (int === exp_int) begin
                if (int === 1) 
                    $display ("t = %10d | [PASS]  Timer interrupt is ON", $time);
                else 
                    $display ("t = %10d | [PASS]  Timer interrupt is OFF", $time);
                pass = pass + 1;
            end else begin
                if (int === 1) 
                    $display ("t = %10d | [FAIL]  Timer is expected to be OFF", $time);
                else 
                    $display ("t = %10d | [FAIL]  Timer is expected to be ON", $time);
                fail = fail + 1;
            end
        end
    endtask

    task pr_p (input exp_pr, input [1:0] mode);
        begin
            case (mode)
                2'd0: $display ("pready state when penable is first asserted:");
                2'd1: $display ("pready state when transfer ended:");
                2'd2: $display ("pready state when penable or psel is not asserted:");
                default: ; //print nothing
            endcase

            if (pready === exp_pr) begin
                if (pready === 1)
                    $display ("t = %10d | [PASS]  pready is ON", $time);
                else
                    $display ("t = %10d | [PASS]  pready is OFF", $time);
                pass = pass + 1;
            end else begin
                if (pready === 1)
                    $display ("t = %10d | [FAIL]  pready is expected to be OFF", $time);
                else
                    $display ("t = %10d | [FAIL]  pready is expected to be ON", $time);
                fail = fail + 1;
            end
        end
    endtask

    task msg (input [399:0] txt);
        begin
            br();
            $display ("\t\t\t%0s", txt);
            br();
        end
    endtask

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n    = 0;
        psel     = 0;
        pwrite   = 0;
        penable  = 0;
        paddr    = 0;
        pwdata   = 0;
        pstrb    = 0;
        dbg_mode = 0;
        exp_err  = 0;
        strb     = 0;
        xsel     = 0;
        xen      = 0;
        pass     = 0;
        fail     = 0;
        #10;

        @(posedge clk);
        rst_n = 1;
        dbg_mode = 1;
        pstrb = 4'hF;

        #100;
        run_test();
        
        br();
        $display ("\tSUMMARY:");
        $display ("Total test cases run: %0d", pass + fail);
        $display ("Passed              : %0d", pass);
        $display ("Failed              : %0d", fail);
        
        if (fail == 0)
            $display ("Test_result PASSED");
        else
            $display ("Test_result FAILED");
        br();

        #100;
        $finish;
    end
endmodule
