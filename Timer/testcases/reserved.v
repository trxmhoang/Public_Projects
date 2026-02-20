task run_test();
    integer i;
    reg [11:0] addr;
    begin
        for (i = 0; i < 20; i = i + 1) begin
            addr = $urandom_range (12'h20, 12'hfff);
            test_bench.wr (addr, 32'hffff_ffff);
            test_bench.rd (addr, 32'h0);
        end        
    end
endtask
