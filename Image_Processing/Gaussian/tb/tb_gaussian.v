//iverilog -o run tb_gaussian.v ../rtl/gaussian.v ../rtl/line_buffer.v ../rtl/kernel.v
module tb_gau_top;
    parameter W = 512;
    parameter H = 512;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);
    parameter TIME_LIMIT = 100_000_000;
    parameter IN_FILE = "hist_v_out.mem";
    parameter OUT_FILE = "gau_v_out.mem";

    reg clk, rst_n;
    reg start;
    wire [1:0] status, err_code;

    reg [7:0] s_axis_tdata;
    wire s_axis_tready;
    reg s_axis_tvalid, s_axis_tlast;

    wire [7:0] m_axis_tdata;
    reg m_axis_tready;
    wire m_axis_tvalid, m_axis_tlast;

    reg [7:0] input_mem [0:W*H - 1];
    integer out_f, out_cnt, i;

    gaussian #(
        .W (W),
        .H (H),
        .TOTAL_PIXEL (TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT (TOTAL_PIXEL_BIT),
        .TIME_LIMIT (TIME_LIMIT)
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

        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast (m_axis_tlast)
    );

    task divi;
        $display ("%0s", {80{"-"}});
    endtask

    task msg (input [255:0] txt);
        begin
            divi();
            $display ("%0s", txt);
            divi();
        end
    endtask

    initial begin
        #(TIME_LIMIT);
        msg ("Timeout! System hung.");
        $finish;
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        start = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        m_axis_tready = 1;
        out_cnt = 0;
        #10;

        msg ("TEST BEGIN");
        $display ("Load image.");
        $readmemh (IN_FILE, input_mem);
        out_f = $fopen (OUT_FILE, "w");
        if (!out_f) begin
            $display ("Error: Could not open output file.");
            $finish;
        end

        repeat(2) @(posedge clk);
        rst_n = 1;
        repeat (5) @(posedge clk);
        #1;

        $display ("Start core.");
        start = 1;
        wait (status == 1);
        $display ("Core is busy.");
        @(posedge clk);
        #1 start = 0;

        $display ("Send pixels.");
        for (i = 0; i < TOTAL_PIXEL; i = i + 1) begin
            @(posedge clk);
            #1;
            s_axis_tdata = input_mem[i];
            s_axis_tvalid = 1;
            s_axis_tlast = (i == TOTAL_PIXEL-1);

            while (!s_axis_tready) begin
                @(posedge clk);
            end
        end

        @(posedge clk);
        #1;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;
        $display ("Send pixels complete.");

        wait (status == 2 || status == 3);
        if (status == 3) begin
            $display ("Error occured! Error code: %d", err_code);
        end else begin
            $display ("Success! Core finished with DONE status");
        end
    end

    always @(posedge clk) begin
        if (rst_n && m_axis_tvalid && m_axis_tready) begin
            $fdisplay (out_f, "%2h", m_axis_tdata);
            out_cnt = out_cnt + 1;

            if (out_cnt == TOTAL_PIXEL) begin
                $display ("Receive enough %0d pixel.", out_cnt);
                $fclose (out_f);
                msg ("TEST END");
                #10 $finish;
            end
        end
    end
endmodule