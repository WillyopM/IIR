module IIR #(
    parameter XW = 8,  // Width of input signal xn
    parameter YW = 16, // Width of output signal yn
    parameter DW = 8,  // Width of the decay value d
    parameter DTW = (XW > YW) ? XW + 1 : YW + 1,
    parameter MW = DTW + 1,
    parameter ConcatWidth = MW - YW,

)(
    input  wire                  clk,      
    input  wire                  rst,      
    input  wire                  cke,      
    input  wire signed [XW-1:0]  xn,  // Input signal
    output reg  signed [YW-1:0]  yn  // Output signal
);
    // IIR coefficients
    reg signed [XW-1:0] a = {XW{1'b0}}; // Coefficient a
    reg signed [XW-1:0] b = {XW{1'b0}}; // Coefficient b
    reg signed [DW-1:0] d = {DW{1'b0}}; // Coefficient d

    reg signed [YW-1:0] yn_m1 = {YW{1'b0}}; // Previous output

    // Define an array of signed values for x_n
    typedef logic signed [XW-1:0] signal_array_t [0:3]; // Array type
    signal_array_t x_n; // Declare the array

    reg signed [DTW-1:0] delta_n;
    reg signed [MW-1:0] mul_n;

    // Initialize the array with all zeros
    initial begin
        x_n = '{default: {XW{1'b0}}}; // Initialize all elements to zero
    end

    always @(posedge clk) begin 
        if (rst || !cke) begin
            yn_m1 <= {YW{1'b0}}; // Reset previous output
            yn <= {YW{1'b0}};    // Reset current output
            x_n <= '{default: {XW{1'b0}}}; // Reset all elements to zero
        end else if (cke) begin
            for (int i = 3; i > 0; i = i - 1) begin
                x_n[i] <= x_n[i-1]; // Shift elements
            end
            x_n[0] <= xn; // Update first element with new input
            delta_n = yn_m1 - x_n[0]; // Calculate delta_n
            mul_n = delta_n * d; // Multiply delta_n by d
            yn = yn_m1 - mul_n; // Calculate yn
            yn_m1 <= yn; // Update previous output
        end
    end

endmodule
