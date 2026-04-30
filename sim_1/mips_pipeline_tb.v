`timescale 1ns / 1ps

module mips_pipeline_tb;
    reg clk;
    reg rst;

    mips_pipeline uut (
        .clk(clk),
        .rst(rst)
    );

    // 10 ns clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst = 1'b1;
        #12;
        rst = 1'b0;
    end

    // Dump all DUT signals for waveform viewing
    initial begin
        $dumpfile("mips_pipeline.vcd");
        $dumpvars(0, mips_pipeline_tb);
    end
    // -------------------------

    // Console output
    initial begin
        $display("-------------------------");
        $display(" MIPS Pipeline Simulation Start");
        $display(" instr.txt will compute 12 into r1");
        $display("-------------------------");
        $display(" time\tclk\trst");
        $monitor("%0t\t%b\t%b", $time, clk, rst);
    end

    // Let the program run
    initial begin
        #300;
        $display("REG[1] = %d", uut.REG[1]);
        $display("REG[2] = %d", uut.REG[2]);
        $display("REG[3] = %d", uut.REG[3]);
        $finish;
        $display("-------------------------");
        $display(" Simulation finished at time %0t", $time);
        $display(" Regs should go as folllowing: 1->12, 2->2, 3->3");
        $display("-------------------------");
        $finish;
    end

endmodule