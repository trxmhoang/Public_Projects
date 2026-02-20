//iverilog tb_ram_in.v ../rtl/ram_in.v
module tb_ram_in;
    parameter W = 2;
    parameter H = 5;
    parameter TOTAL_PIXEL = W * H;
    parameter TOTAL_PIXEL_BIT = $clog2(W * H);

    reg clk;
    reg [TOTAL_PIXEL_BIT-1:0] rd_addr;
    wire [7:0] rd_data;

    integer pass, fail;

    ram_in #(
        .W(W),
        .H(H),
        .TOTAL_PIXEL(TOTAL_PIXEL),
        .TOTAL_PIXEL_BIT(TOTAL_PIXEL_BIT)
    ) dut (
        .clk(clk),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    task br;
        $display ("%0s", {60{"="}});
    endtask

    task msg (input [255:0] txt);
        begin
            br();
            $display ("%0s", txt);
            br();
        end
    endtask

    task check (input [TOTAL_PIXEL_BIT-1:0] addr, input [7:0] exp_data);
        begin
            @(posedge clk);
            #1 rd_addr = addr;

            @(posedge clk);
            #1;
            if (rd_data == exp_data) begin
                $display ("[PASS] t = %4t | Addr = %0h, Rd_Data = 8'h%0h, Exp = 8'h%0h", $time, addr, rd_data, exp_data);
                pass = pass + 1;
            end else begin
                $display ("[FAIL] t = %4t | Addr = %0h, Rd_Data = 8'h%0h, Exp = 8'h%0h", $time, addr, rd_data, exp_data);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rd_addr = 0;
        pass = 0;
        fail = 0;
        #10;

        msg ("TEST BEGIN");
        check (0, 8'h11);
        check (1, 8'h22);
        check (2, 8'h33);
        check (3, 8'h44);
        check (4, 8'h55);
        check (5, 8'h66);
        check (6, 8'h77);
        check (7, 8'h88);
        check (8, 8'h99);
        check (9, 8'hAA);

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

        msg ("TEST END");
        #100 $finish;
        end
endmodule