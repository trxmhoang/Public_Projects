//iverilog -o run tb_axi_reg.v ../rtl/axi_lite.v ../rtl/reg_file.v
module tb_axi_reg;
    parameter ADDR_WIDTH = 4;
    reg clk, rst_n;
    reg [ADDR_WIDTH-1:0] awaddr, araddr;
    reg awvalid;
    wire awready;

    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg wvalid;
    wire wready;

    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    reg arvalid;
    wire arready;

    wire [31:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    wire wr_en, rd_en;
    wire start, irq;
    integer pass, fail, i;
    integer strb_c, resp_c;
    integer xav, xwv, xrv;

    localparam ADDR_CTRL = 0;
    localparam ADDR_STATUS = 4;
    localparam ADDR_ERR = 8;

    axi_lite #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) dut_lite (
        .clk (clk),
        .rst_n (rst_n),

        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),

        .wdata(wdata), 
        .wstrb(wstrb),
        .wvalid(wvalid),
        .wready(wready),

        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready),

        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),

        .rresp(rresp),
        .rvalid(rvalid),
        .rready(rready),

        .wr_en(wr_en),
        .rd_en(rd_en)
    );

    reg_file #(
        .ADDR_WIDTH (ADDR_WIDTH)
    ) dut_reg (
        .clk (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),

        .awaddr (awaddr),
        .wdata (wdata),
        .wstrb (wstrb),

        .araddr (araddr),
        .rdata (rdata),

        .start (start),
        .irq (irq),
        .status (2'd3),
        .err_code (2'd2)
    );

    task divi;
        $display ("%0s", {80{"-"}});
    endtask

    task msg (input [600:0] txt);
        begin
            divi();
            $display ("%0s", txt);
            divi();
        end
    endtask 

    task wr (input [ADDR_WIDTH-1:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            awaddr = addr;
            awvalid = 1& !xav;
            wdata = data;
            wvalid = 1  & !xwv;
            bready = 1;
            #1 wr_p (addr, data);

            if (xav || xwv) begin
                @(posedge clk);
                #1;
                wr_sig_c (0);

                @(posedge clk);
                #1;
                awaddr = 0;
                awvalid = 0;
                wdata = 0;
                wvalid = 0;
                wr_sig_c(1);
                if (resp_c) wr_c (2'b11);
                else wr_c (2'b00);

                @(posedge clk);
                #1 bready = 0;

            end else begin
                wait (awready && wready);
                @(posedge clk);
                #1;
                awaddr = 0;
                awvalid = 0;
                wdata = 0;
                wvalid = 0;
                if (resp_c) wr_c (2'b11);
                else wr_c (2'b00);

                wait (bvalid);
                @(posedge clk);
                #1 bready = 0;
            end
        end
    endtask

    task rd (input [ADDR_WIDTH-1:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            #1;
            araddr = addr;
            arvalid = 1 & !xrv;
            rready = 1;
            #1;
            rd_p (addr);
            

            if (xrv) begin
                @(posedge clk);
                #1;
                rd_sig_c (0);

                @(posedge clk);
                #1;
                araddr = 0;
                arvalid = 0;
                rd_sig_c (1);

                @(posedge clk);
                #1 rready = 0;

            end else begin
                wait (arready);
                @(posedge clk);
                #1;
                araddr = 0;
                arvalid = 0;
                if (resp_c) rd_c (data, 2'b11);
                else rd_c (data, 2'b00);

                wait (rvalid);
                @(posedge clk);
                #1 rready = 0;
            end
        end
    endtask

    //write print
    task wr_p (input [ADDR_WIDTH-1:0] addr, input [31:0] data);
        if (strb_c) 
            $display ("WRITE -- Time = %0t | AWADDR = 12'h%0h, WDATA = 32'h%8h, WSTRB = 4'b%4b", $time, addr, data, wstrb);
        else
            $display ("WRITE -- Time = %0t | AWADDR = 12'h%0h, WDATA = 32'h%8h", $time, addr, data);
    endtask

    task wr_c (input [1:0] resp);
        begin
            $display ("[OUTPUT] Time = %0t | BRESP = 2'b%2b", $time, bresp);
            $display ("[EXPECT] Time = %0t | BRESP = 2'b%2b", $time, resp);
            
            if (bresp === resp) begin
                $display ("======> PASSED");
                pass = pass + 1;
            end else begin
                $display ("======> FAILED");
                fail = fail + 1;
            end
        end
    endtask

    task rd_p (input [ADDR_WIDTH-1:0] addr);
        $display ("READ  -- Time = %0t | ARADDR = 12'h%0h", $time, addr);
    endtask

    task rd_c (input [31:0] data, input [1:0] resp);
        begin
            $display ("[OUTPUT] Time = %0t | RDATA = 32'h%8h, RRESP = 2'b%2b", $time, rdata, rresp);
            $display ("[EXPECT] Time = %0t | RDATA = 32'h%8h, RRESP = 2'b%2b", $time, data, resp);
            
            if ((rdata === data) && (rresp === resp)) begin
                $display ("======> PASSED");
                pass = pass + 1;
            end else begin
                $display ("======> FAILED");
                fail = fail + 1;
            end
        end
    endtask

    task irq_c (input exp);
        begin
            $display ("[IRQ]    Time = %0t | Output = %b, Expect = %b", $time, irq, exp);
            if (irq === exp) begin
                $display ("======> PASSED");
                pass = pass + 1;
            end else begin
                $display ("======> FAILED");
                fail = fail + 1;
            end
        end
    endtask

    task wr_sig_c (input x);
        begin
            if (x == 0) begin
                $display ("[OUTPUT] Time = %0t | WR_EN = %b", $time, wr_en);
                $display ("[EXPECT] Time = %0t | WR_EN = %b", $time, 1'b0);
                if (wr_en === 1'b0) begin
                    $display ("======> PASSED");
                    pass = pass + 1;
                end else begin
                    $display ("======> FAILED");
                    fail = fail + 1;
                end
            end else begin
                $display ("[OUTPUT] Time = %0t | BVALID = %b, BRESP = 2'b%2b", $time, bvalid, bresp);
                $display ("[EXPECT] Time = %0t | BVALID = %b, BRESP = 2'b%2b", $time, 1'b0, 2'b00);
                if (bvalid === 1'b0 && bresp === 2'b00) begin
                    $display ("======> PASSED");
                    pass = pass + 1;
                end else begin
                    $display ("======> FAILED");
                    fail = fail + 1;
                end
            end
        end
    endtask

    task rd_sig_c (input x);
        begin
            if (x == 0) begin
                $display ("[OUTPUT] Time = %0t | RD_EN = %b", $time, rd_en);
                $display ("[EXPECT] Time = %0t | RD_EN = %b", $time, 1'b0);
                if (rd_en === 1'b0) begin
                    $display ("======> PASSED");
                    pass = pass + 1;
                end else begin
                    $display ("======> FAILED");
                    fail = fail + 1;
                end
            end else begin
                $display ("[OUTPUT] Time = %0t | RVALID = %b, RRESP = 2'b%2b", $time, rvalid, rresp);
                $display ("[EXPECT] Time = %0t | RVALID = %b, RRESP = 2'b%2b", $time, 1'b0, 2'b00);
                if (rvalid === 1'b0 && rresp === 2'b00) begin
                    $display ("======> PASSED");
                    pass = pass + 1;
                end else begin
                    $display ("======> FAILED");
                    fail = fail + 1;
                end
            end
        end
    endtask

    task rd_all (input [31:0] data0, input [31:0] data1, input [31:0] data2);
        begin
            rd (ADDR_CTRL, data0);
            rd (ADDR_STATUS, data1);
            rd (ADDR_ERR, data2);
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        awaddr = 0;
        awvalid = 0;
        wdata = 0;
        wvalid = 0;
        bready = 0;
        wstrb = 4'hF;
        strb_c = 0;
        resp_c = 0;
        
        araddr = 0;
        arvalid = 0;
        rready = 0;

        xav = 0;
        xwv = 0;
        xrv = 0;

        pass = 0;
        fail = 0;
        #10;

        @(posedge clk);
        rst_n = 1;

        msg ("TEST 1: INITIAL VALUES CHECK");
        rd_all (0, 3, 2);
        irq_c (0);

        msg ("TEST 2: READ/WRITE CHECK");
        msg ("\t1. CONTROL REGISTER");
        wr (ADDR_CTRL, 32'h0000_0000);
        rd (ADDR_CTRL, 32'h0);
        irq_c (0);
        wr (ADDR_CTRL, 32'hFFFF_FFFF);
        rd (ADDR_CTRL, 32'h3);
        irq_c (1);
        wr (ADDR_CTRL, 32'haaaa_aaaa);
        rd (ADDR_CTRL, 32'h2);
        irq_c (1);
        wr (ADDR_CTRL, 32'h5555_5555);
        rd (ADDR_CTRL, 32'h1);
        irq_c (0);
        wr (ADDR_CTRL, 32'ha5a5_a5a5);
        rd (ADDR_CTRL, 32'h1);
        irq_c (0);
        wr (ADDR_CTRL, 32'h5a5a_5a5a);
        rd (ADDR_CTRL, 32'h2);
        irq_c (1);

        msg ("TEST 3: RESET CHECK");
        $display ("Reseting...");
        @(posedge clk);
        #1 rst_n = 0;
        $display ("Releasing reset...");
        @(posedge clk);
        #1 rst_n = 1;
        rd_all (0, 3, 2);

        msg ("TEST 4: RESERVED ADDRESSES CHECK");
        for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
            if (i == 0 || i == 4 || i == 8) begin
                resp_c = 0;
                #1;
                wr (i, 32'hFFFF_FFFF);
                if (i == 0) rd (i, 32'h3);
                else if (i == 4) rd (i, 32'h3);
                else rd (i, 32'h2);
            end else begin
                resp_c = 1;
                #1;
                wr (i, 32'hFFFF_FFFF);
                rd (i, 32'h0);
            end
        end

        msg ("TEST 5: NO AWVALID/WVALID CHECK");
        resp_c = 0;
        $display ("Reseting...");
        @(posedge clk);
        #1 rst_n = 0;
        $display ("Releasing reset...");
        @(posedge clk);
        #1 rst_n = 1;

        msg ("\t1. NO AWVALID");
        xav = 1;
        wr (ADDR_CTRL, 32'h9876_1245);
        wr (ADDR_STATUS, 32'h9ABC_DEF0);
        wr (ADDR_ERR, 32'hFEDC_BA98);
        rd (ADDR_CTRL, 32'h0);
        rd (ADDR_STATUS, 32'h3);
        rd (ADDR_ERR, 32'h2);
        xav = 0;

        msg ("\t2. NO WVALID");
        xwv = 1;
        wr (ADDR_CTRL, 32'h9876_1245);
        wr (ADDR_STATUS, 32'h9ABC_DEF0);
        wr (ADDR_ERR, 32'hFEDC_BA98);
        rd (ADDR_CTRL, 32'h0);
        rd (ADDR_STATUS, 32'h3);
        rd (ADDR_ERR, 32'h2);

        msg ("\t3. NO WVALID & AWVALID");
        xav = 1;
        wr (ADDR_CTRL, 32'h9876_1245);
        wr (ADDR_STATUS, 32'h9ABC_DEF0);
        wr (ADDR_ERR, 32'hFEDC_BA98);
        rd (ADDR_CTRL, 32'h0);
        rd (ADDR_STATUS, 32'h3);
        rd (ADDR_ERR, 32'h2);
        xav = 0;
        xwv = 0;

        msg ("TEST 8: NO ARVALID");
        $display ("Reseting...");
        @(posedge clk);
        #1 rst_n = 0;
        $display ("Releasing reset...");
        @(posedge clk);
        #1 rst_n = 1;

        xrv = 1;
        wr (ADDR_CTRL, 32'h9876_1245);
        wr (ADDR_STATUS, 32'h9ABC_DEF0);
        wr (ADDR_ERR, 32'hFEDC_BA98);
        rd (ADDR_CTRL, 32'h0);
        rd (ADDR_STATUS, 32'h0);
        rd (ADDR_ERR, 32'h0);
        xrv = 0;
        rd (ADDR_CTRL, 32'h1);
        irq_c (0);
        rd (ADDR_STATUS, 32'h3);
        rd (ADDR_ERR, 32'h2);

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
        
        #10 $finish;
    end
endmodule