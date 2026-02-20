//iverilog -o run tb_hist.v ../rtl/histogram.v ../rtl/divider.v
module tb_hist;
    parameter W = 256;
    parameter H = 256;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);

    reg clk, rst_n, start;
    wire [1:0] status, err_code;

    reg [7:0] s_axis_tdata;
    reg s_axis_tvalid, s_axis_tlast;
    wire s_axis_tready;

    wire [7:0] m_axis_tdata;
    wire m_axis_tvalid, m_axis_tlast;
    reg m_axis_tready;

    reg [7:0] input_mem [0:TOTAL_PIXEL-1];
    reg [2:0] pre_state;
    integer out_file, i;

    histogram #(
        .W (W),
        .H (H),
        .TOTAL_PIXEL (TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT (TOTAL_PIXEL_BIT)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),
        .start (start),
        .status (status),
        .err_code (err_code),

        .s_axis_tdata (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast (s_axis_tlast),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

    task br;
        $display ("%0s", {80{"="}});
    endtask

    task msg (input [511:0] txt);
        begin
            br();
            $display ("%0s", txt);
            br();
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        start = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 0;
        pre_state = 0;
        #10;

        msg ("TEST BEGIN");
        $readmemh ("img_in.mem", input_mem);
        out_file = $fopen ("hist_v_out.mem", "w");

        if (!out_file) begin
            $display ("Error: Could not open output file.");
            $finish;
        end

        @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        @(posedge clk);
        #1;
        $display ("Time = %10t | Sending START command...", $time);
        start = 1;

        wait (status == 1);
        #1 start = 0;
        $display ("Time = %10t | Core is BUSY. State: %d", $time, dut.state);

        @(posedge clk);
        wait (s_axis_tready == 1);
        #1 $display ("Time = %10t | Core is ready, DMA starts pixel transfer.", $time);
        
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

        $display ("Time = %10t | Total pixels sent: %0d", $time, i);
        @(posedge clk);
        #1;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        $display ("Time = %10t | DMA transfer finished.", $time);

        m_axis_tready = 1;
        #1;

        wait (status == 2 || status == 3);
        #1;
        if (status == 3) begin
            $display ("Time = %10t | Error occured! Error code: %d", $time, err_code);
        end else begin
            $display ("Time = %10t | Success! Core finished with DONE status", $time);
        end

        @(posedge clk);
        #1 $fclose (out_file);
        
        msg ("TEST END");
         #100 $finish;
    end

    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready) begin
            $fdisplay (out_file, "%02h", m_axis_tdata);
        end
    end

    always @(posedge clk) begin
        if (dut.state != pre_state) begin
            $display ("Time = %10t | State changed: %d -> %d", $time, pre_state, dut.state);
            pre_state <= dut.state;
        end
    end

    always @(posedge clk) begin
        if (dut.state == 3'd2) begin
            $display ("Time = %10t | HIST | pixel_cnt = %4d, s_asixs_tvalid = %b, s_axis_tready = %b, s_axis_tlast = %b", $time, dut.pixel_cnt, s_axis_tvalid, s_axis_tready, s_axis_tlast);
        end
    end
endmodule