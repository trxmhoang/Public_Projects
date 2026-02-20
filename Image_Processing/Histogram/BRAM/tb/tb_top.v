//iverilog tb_top.v ../rtl/top ../rtl/ram_in.v ../rtl/ram_out.v ../rtl/divider.v ../rtl/histogram.v
module tb_top;
    parameter W = 256;
    parameter H = 256;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);

    reg clk, rst_n;
    reg start;
    wire done;
    reg [TOTAL_PIXEL_BIT-1:0] rd_addr;
    wire [7:0] rd_data;

    integer i, out_file;

    top #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .done(done),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
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
        #100_000_000; 
        msg ("TIMEOUT ERROR! SYSTEM HUNG.");
        $finish;
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        start = 0;
        rd_addr = 0;
        #10;

        @(posedge clk);
        rst_n = 1;
        #10;

        msg ("PROCESS IMAGE START");
        @(posedge clk);
        #1 start = 1;
        @(posedge clk);
        #1 start = 0;

        wait (done === 1);
        msg ("PROCESS IMAGE DONE");
        //$display ("cdf_min = %0d, K = %0d", dut.dut_eq.cdf_min, dut.dut_eq.K);

        
        /* for (i = 0; i < 256; i = i + 1)
            $display("H[%d] = %d", i, dut.dut_eq.hist_mem[i]); */
        

        msg ("STORE DATA TO HEX FILE");
        @(posedge clk);
        out_file = $fopen ("hist_v_out.mem", "w");

        if (!out_file) begin
            $display ("Error: Could not open output file.");
            $finish;
        end

        for (i = 0; i < TOTAL_PIXEL; i = i + 1) begin
            rd_addr = i;
            @(posedge clk);
            #1;
            $fdisplay (out_file, "%2h", rd_data); // %2h = %02x 
        end

        $fclose (out_file);
        msg ("FINISH STORING DATA TO HEX FILE");

        #10 $finish;
    end
endmodule