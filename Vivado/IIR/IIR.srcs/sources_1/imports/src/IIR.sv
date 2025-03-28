module IIR #(
    parameter XW = 8,  // Width of input signal xn
    parameter YW = 32,  // Width of output signal yn
    parameter DW = 16,  // Width of the decay value d
    parameter DTW = (XW > YW) ? XW + 1 : YW + 1,
    parameter MW = 2*(DW-1)+DTW+1, // Width of the multiplication value
    parameter ConcatWidth = MW - YW,
    parameter HIGH_BIT = MW - 1,   // Highest bit for slicing
    parameter LOW_BIT = MW - YW    // Lowest bit for slicing
)(
    input  wire                  clk,      
    input  wire                  rst,      
    input  wire                  cke,      
    input  wire signed [XW-1:0]  xn,  // Input signal
    output reg  signed [YW-1:0]  yn  // Output signal
);

    // IIR variables

    typedef logic signed [XW + DW - 1:0] signal_array_t [0:2]; // Define an array of signed values for x_n
    signal_array_t x_n; // Declare the array
    
    // Initialize the array with all zeros
    initial begin
        x_n = '{default: {XW{1'b0}}}; // Initialize all elements to zero
    end

    reg signed [DW-1:0] d = 32440; // Decay value = 0.9899 in Q1.15 format
    reg signed [YW-1:0] yn_m1 = {YW{1'b0}}; // Previous output
    reg signed [DTW-1:0] delta_n; // Delta value
    reg signed [MW-1:0] mul_n; // Multiplication value

    always @(posedge clk) begin 
        if (rst) begin
            yn_m1 <= {YW{1'b0}}; // Reset previous output
            yn <= {YW{1'b0}};    // Reset current output
            x_n <= '{default: {XW{1'b0}}}; // Reset all elements to zero
            delta_n <= {DTW{1'b0}}; // Reset delta_n
            mul_n <= {MW{1'b0}};    // Reset mul_n
        end else if (cke) begin
            // Shift elements in x_n
            x_n[2] <= x_n[1];
            x_n[1] <= x_n[0];
            x_n[0] <= xn << (DW - 1);  // Shift input signal by DW - 1
    
            // IIR filter equations
            delta_n <= yn_m1 - x_n[0]; // Compute delta_n
            // mul_n <= (delta_n * d) >>> (2*(DW-1));  // Perform arithmetic right shift to keep sign
            mul_n <= (delta_n * d);  // Perform arithmetic right shift to keep sign
            yn <= $signed(mul_n + x_n[2]) >>> (HIGH_BIT - LOW_BIT + 1);
            yn_m1 <= yn;               // Update previous output
        end
    end

endmodule
