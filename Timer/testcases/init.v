task run_test();
    begin
        test_bench.rd (test_bench.tcr, 32'h0000_0100);
        test_bench.rd (test_bench.tdr0, 32'h0);
        test_bench.rd (test_bench.tdr1, 32'h0);
        test_bench.rd (test_bench.tcmp0, 32'hffff_ffff);
        test_bench.rd (test_bench.tcmp1, 32'hffff_ffff);
        test_bench.rd (test_bench.tier, 32'h0);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h0);
    end
endtask
