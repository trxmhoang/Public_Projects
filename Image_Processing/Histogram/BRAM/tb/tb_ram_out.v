//iverilog tb_ram_out.v ../rtl/ram_out.v
module tb_ram_out;
    parameter W = 64;
    parameter H = 64;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);

    reg clk;
    reg wr_en;
    reg [TOTAL_PIXEL_BIT-1:0] wr_addr;
    reg [7:0] wr_data;
    reg [TOTAL_PIXEL_BIT-1:0] rd_addr;
    wire [7:0] rd_data;

    integer i, out_file;
    
    ram_out #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut (
        .clk(clk),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        
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
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr = 0;
        #10;

        msg ("WRITE DATA TO RAM");
        @(posedge clk);
        #1 wr_en = 1;
        for (i = 0; i < TOTAL_PIXEL; i = i + 1) begin
            @(posedge clk);
            #1;
            wr_addr = i;
            wr_data = i % 256;
        end
        @(posedge clk);
        #1 wr_en = 0;
        
        @(posedge clk);
        #1;

        msg ("READ DATA FROM RAM & WRITE TO FILE");
        out_file = $fopen("v_output_hex.txt", "w");
        if (!out_file) begin
            $display ("Error: File is not found!");
            $finish;
        end

        for (i = 0; i < TOTAL_PIXEL; i = i + 1) begin
            rd_addr = i;
            @(posedge clk);
            #1 $fdisplay (out_file, "%2h", rd_data);
        end

        $fclose (out_file);
        msg ("FINISH WRITTING DATA FROM RAM TO FILE");
        #10 $finish;
    end
endmodule