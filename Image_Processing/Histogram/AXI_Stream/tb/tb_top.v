//iverilog -o run tb_top.v ../rtl/top.v ../rtl/histogram.v ../rtl/divider.v ../rtl/axi_lite.v ../rtl/reg_file.v
module tb_top;
    parameter W = 16;
    parameter H = 16;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);
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
    wire irq;

    reg [7:0] s_axis_tdata;
    reg s_axis_tvalid, s_axis_tlast;
    wire s_axis_tready;

    wire [7:0] m_axis_tdata;
    wire m_axis_tvalid, m_axis_tlast;
    reg m_axis_tready;

    integer i, pass, fail, out_file;
    reg [31:0] rd_data;
    reg [7:0] input_mem [0:TOTAL_PIXEL-1];

    localparam ADDR_CTRL = 0;
    localparam ADDR_STATUS = 4;
    localparam ADDR_ERR = 8; 
    
    localparam IDLE = 0;
    localparam BUSY = 1;
    localparam DONE = 2;
    localparam ERROR = 3;

    top #(
        .W (W),
        .H (H),
        .TOTAL_PIXEL (TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT (TOTAL_PIXEL_BIT),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),

        .awaddr (awaddr),
        .awvalid (awvalid),
        .awready (awready),

        .wdata (wdata),
        .wstrb (wstrb),
        .wvalid (wvalid),
        .wready (wready),

        .bresp (bresp),
        .bvalid (bvalid),
        .bready (bready),
        
        .araddr (araddr),
        .arvalid (arvalid),
        .arready (arready),

        .rdata (rdata),
        .rresp (rresp),
        .rvalid (rvalid),
        .rready (rready),
        .irq (irq),

        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast (s_axis_tlast),

        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast (m_axis_tlast)
    );

    task divi;
        $display ("%0s", {80{"-"}});
    endtask

    task msg (input [511:0] txt);
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
            awvalid = 1;
            wdata = data;
            wvalid = 1;
            bready = 1;
            #1 $display ("Time = %10t | [AXI-LITE  ] AWADDR = 0x%0h, WDATA = 0x%0h", $time, addr, data);

            wait (awready && wready);
            @(posedge clk);
            #1;
            awvalid = 0;
            wvalid = 0;

            wait (bvalid);
            @(posedge clk);
            #1 bready = 0;
        end
    endtask

    task rd (input [ADDR_WIDTH-1:0] addr);
        begin
            @(posedge clk);
            #1;
            araddr = addr;
            arvalid = 1;
            rready = 1;

            wait (arready);
            @(posedge clk);
            #1 arvalid = 0;

            rd_data = rdata;
            $display ("Time = %10t | [AXI-LITE  ] ARADDR = 0x%0h, RDATA = 0x%0h", $time, addr, rdata);

            wait (rvalid);
            @(posedge clk);
            #1 rready = 0;
        end
    endtask

    task check (input [31:0] data);
        begin
            if (rd_data === data) begin
                $display ("=========> PASSED | Status = %0s", (rd_data == IDLE) ? "IDLE" : (rd_data == BUSY) ? "BUSY" : (rd_data == DONE) ? "DONE" : "ERROR");
                pass = pass + 1;
            end else begin
                $display ("=========> FAILED | Expected Status = %0s", (rd_data == IDLE) ? "IDLE" : (rd_data == BUSY) ? "BUSY" : (rd_data == DONE) ? "DONE" : "ERROR");
                fail = fail + 1;
            end
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
        wstrb = 4'hF;
        wvalid = 0;
        bready = 0;

        araddr = 0;
        arvalid = 0;
        rready = 0;
        
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;

        m_axis_tready = 0;
        pass = 0;
        fail = 0;
        #20;

        msg ("TEST BEGIN");
        $readmemh ("img_in.mem", input_mem);
        out_file = $fopen ("hist_v_out.mem", "w");
        if (!out_file) begin
            $display ("Error: Could not open output file.");
            $finish;
        end

        @(posedge clk);
        rst_n = 1;
        
        repeat(2) @(posedge clk);
        rd (ADDR_STATUS);
        check (IDLE);
        
        $display ("Time = %10t | [AXI-LITE  ] Sending START command...", $time);
        wr (ADDR_CTRL, 3);
        rd (ADDR_STATUS);
        check (BUSY);

        @(posedge clk);
        wait (s_axis_tready);
        #1 $display ("Time = %10t | [AXI-STREAM] Core is ready, DMA starts pixel transfer.", $time);

        for (i = 0; i < TOTAL_PIXEL; i = i + 1) begin
            s_axis_tdata = input_mem[i];
            s_axis_tvalid = 1;
            
            if (i == TOTAL_PIXEL - 1) begin
                s_axis_tlast = 1;
            end else begin
                s_axis_tlast = 0;
            end

            while (!s_axis_tready) begin
                @(posedge clk);
            end

            @(posedge clk);
            #1;
        end

        $display ("Time = %10t | [AXI-STREAM] Total pixels sent: %0d.", $time, i);
        // setting to hơn ảnh nó vẫn kêu là sent với con số đã set thay vì con số thực tế -> cần viết tb thông minh hơn, vd như là kiểm soát xem có bao nhiêu cái đã đc sent và khi nào đủ thì mới được close file và finish?
        @(posedge clk);
        #1;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        $display ("Time = %10t | [AXI-STREAM] DMA transfer finished.", $time);

        m_axis_tready = 1;
        #1;

        wait (irq == 1);
        #1 $display ("Time = %10t | [CPU       ] Interrupt received.", $time);
        rd (ADDR_STATUS);
        check (DONE);

        if (rd_data == DONE) begin
            $display ("Time = %10t | SUCCESS! Core finished with DONE status.", $time);
        end else if (rd_data == ERROR) begin
            rd (ADDR_ERR);
            $display ("Time = %10t | ERROR occured! Error code: %d.", $time, rd_data);
        end

        wr (ADDR_CTRL, 0);
        rd (ADDR_STATUS);
        check (IDLE);

        msg ("TEST END");
        #20 $finish;
    end

    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $fdisplay (out_file, "%2h", m_axis_tdata);
        end
    end
endmodule