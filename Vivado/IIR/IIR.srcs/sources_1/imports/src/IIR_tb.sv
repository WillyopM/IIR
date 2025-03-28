`timescale 1ns / 1ps

module IIR_tb;

    // Inputs
    reg clk;
    reg rst;
    reg cke;
    reg signed [15:0] xn; // Match the default XW width in the IIR module

    // Outputs
    wire signed [31:0] yn; // Match the default YW width in the IIR module

    // Instantiate the DUT (Device Under Test)
    IIR dut (
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .xn(xn),
        .yn(yn)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        rst = 1;
        cke = 0;
        xn = 0;

        // Apply reset
        #20;
        rst = 0; 
        cke = 1;

        // Apply constant input of 10 to xn
        #10;
        xn = 10;

        // Run for 110 clock cycles to observe transient response
        #1100;

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | rst: %b | cke: %b | xn: %d | yn: %d", $time, rst, cke, xn, yn);
    end

endmodule