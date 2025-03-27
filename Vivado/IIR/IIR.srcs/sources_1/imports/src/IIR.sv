module IIR (
    input  wire        clk,      
    input  wire        rst,      
    input  wire        cke,      
    input  wire signed [7:0]  xn,  // Input signal
    output reg  signed [15:0] yn // Output signal
);
    // IIR coefficients
    signed a = 8'sd125;
    signed b = 8'sd1;

    reg signed [15:0] yn_m1 = 16'sd0;

    always @(posedge clk) begin 
        if (rst || !cke) begin
            yn_m1 <= 16'sd0;
            yn <= 16'sd0;
        end else if (cke) begin
            yn <= (b * xn) + (a * yn_m1);
            yn_m1 <= yn;
        end
    end

endmodule
