`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 12:25:49 PM
// Design Name: 
// Module Name: Interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Interface_tb;

    // Inputs
    reg CLK;
    reg RST;
    reg MODE_SW;

    // Outputs
    wire [15:0] led;

    // Instantiate the DUT (Device Under Test)
    INTERFACE dut (
        .CLK(CLK),
        .RST(RST),
        .MODE_SW(MODE_SW),
        .led(led)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100 MHz clock (10 ns period)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        RST = 1;
        MODE_SW = 0;

        // Apply reset
        #20;
        RST = 0;

        // Test MODE_SW = 0 (default mode)
        #50;
        MODE_SW = 0;

        // Test MODE_SW = 1 (filtered mode)
        #50;
        MODE_SW = 1;

        // Toggle MODE_SW back to 0
        #50;
        MODE_SW = 0;

        // End simulation
        #100;
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | RST: %b | MODE_SW: %b | led: %h", $time, RST, MODE_SW, led);
    end

endmodule
