`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 12:23:01 AM
// Design Name: 
// Module Name: SignalGen
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


module SignalGen(
    input wire clk,
    input wire rst,
    input wire restart,
    output reg [15:0] cosine,
    output reg [3:0] i_o
    );

    localparam signed [7:0] cos_t [0:15] = '{
        8'd90,  8'd49,  8'd0,   -8'd49,
        -8'd90, -8'd117, -8'd127, -8'd117,
        -8'd90, -8'd49,  8'd0,   8'd49,
        8'd90,  8'd117,  8'd127, 8'd117
    };
    
reg [3:0] i = 0;

always @(posedge clk) begin
    if (restart == 1) 
        i <= 0;
    else
        i <= i + 1;
end 

always @(posedge clk) begin
    cosine <= cos_t[i];
    i_o <= i;
end

endmodule
