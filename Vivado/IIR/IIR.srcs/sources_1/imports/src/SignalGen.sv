module SignalGen(
    input wire clk,
    input wire rst,
    input wire restart,
    output wire signed [7:0] cosine,
    output wire [3:0] i_o
    );

    localparam signed [7:0] cos_t [0:15] = '{
        8'd127,
        8'd117,
        8'd90,
        8'd49,
        8'd0,
        -8'd49,
        -8'd90,
        -8'd117,
        -8'd127,
        -8'd117,
        -8'd90,
        -8'd49,
        8'd0,
        8'd49,
        8'd90,
        8'd117
    };
    
reg [3:0] i = 0;

always @(posedge clk) begin
    if (restart == 1 || rst == 1) 
        i <= 0;
    else
        i <= i + 1;
end 

assign cosine = cos_t[i];
assign i_o = i;

endmodule
