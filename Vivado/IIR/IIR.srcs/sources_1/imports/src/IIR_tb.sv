`timescale 1ns / 1ps

module IIR_tb;

    // Parameters for the IIR module
    parameter DW = 16;  // Width of the decay value
    parameter XWI = 16;  // Width of the input signal
    parameter YWO = 32; // Width of the output signal

    // Inputs
    reg clk;
    reg rst;
    reg cke;
    reg signed [XWI-1:0] xn; // Match the XW width in the IIR module

    // Outputs
    wire signed [YWO-1:0] yn_o; // Match the YWO width in the IIR module

    // Instantiate the DUT (Device Under Test)
    IIR #(
        .DW(DW),
        .XWI(XWI),
        .YWO(YWO)
    ) dut (
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .xn(xn),
        .yn_o(yn_o)
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

        // Section 1: Apply constant input of 10 to xn
        #10;
        xn = 10;
        #6000; // Run for 110 clock cycles

        #20;
        rst = 1; 
        xn = -10;
        #20;
        rst = 0;

        // Section 1: Apply constant input of 10 to xn
        #10;
        xn = -10;
        #6000; // Run for 110 clock cycles

        #20;
        rst = 1; 
        #20;
        rst = 0;

        // Section 2: Apply maximum positive value of xn
        xn = {(XWI-1){1'b1}}; // Maximum positive value for signed XWI-bit input
        #6000; // Run for 110 clock cycles

        // Wait for 600 clock cycles
        #6000;

        // Section 3: Jiggle rst while applying xn = 20
        xn = 20;
        #10 rst = 1; // Assert reset
        #10 rst = 0; // Deassert reset
        #10 rst = 1; // Assert reset again
        #10 rst = 0; // Deassert reset
        #6000; // Run for 110 clock cycles

        // Wait for 600 clock cycles
        #6000;

        // Section 4: Apply xn = 30 and then set cke = 0
        xn = 30;
        #6000; // Run for 110 clock cycles
        cke = 0; // Disable clock enable
        #20; // Run for another 110 clock cycles
        cke = 1; // Disable clock enable
        #6000; // Run for another 110 clock cycles

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | rst: %b | cke: %b | xn: %d | yn: %d", $time, rst, cke, xn, yn_o);
    end

endmodule
