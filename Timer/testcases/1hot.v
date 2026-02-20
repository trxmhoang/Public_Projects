task run_test();
    begin
        test_bench.wr (test_bench.tcr, 32'h2222_2222);
        test_bench.wr (test_bench.tdr0, 32'h3333_3333);
        test_bench.wr (test_bench.tdr1, 32'h4444_4444);
        test_bench.wr (test_bench.tcmp0, 32'h5555_5555);
        test_bench.wr (test_bench.tcmp1, 32'h6666_6666);
        test_bench.wr (test_bench.tier, 32'h7777_7777);
        test_bench.wr (test_bench.tisr, 32'h8888_8888);
        test_bench.wr (test_bench.thcsr, 32'ha55a_5aa5);

        test_bench.rd (test_bench.tcr, 32'h0000_0202);
        test_bench.rd (test_bench.tdr0, 32'h3333_3333);
        test_bench.rd (test_bench.tdr1, 32'h4444_4444);
        test_bench.rd (test_bench.tcmp0, 32'h5555_5555);
        test_bench.rd (test_bench.tcmp1, 32'h6666_6666);
        test_bench.rd (test_bench.tier, 32'h1);
        test_bench.rd (test_bench.tisr, 32'h0);
        test_bench.rd (test_bench.thcsr, 32'h3);
    end
endtask
