module IIR #(
    parameter XW = 16,  // Width of input signal xn
    parameter DW = 16,  // Width of the decay value d
    parameter XWI = XW + DW - 1,  // Width of input signal xn
    parameter DTW = (XWI > (2*(DW-1)+XW)) ? XWI + 1 : ((2*(DW-1)+XW)) + 1,
    parameter MW = DTW + DW, // Width of the multiplication value
    parameter YW = (2*(DW-1)+XW),  // Width of output signal yn
    parameter YWO = 32,  // Width of output signal yn
    parameter CONCAT_O = YW - YWO, // Output concatenation parameter
    parameter real DECAY_VALUE = 0.99 // Decay value as a parameter
)(
    input  wire                  clk,      
    input  wire                  rst,      
    input  wire                  cke,      
    input  wire signed [XW-1:0]  xn,  // Input signal
    output reg  signed [YW-1:0]  yn  // Output signal
);

    // IIR variables
    typedef logic signed [XWI:0] signal_array_t [0:1]; // Define an array of signed values for x_n
    signal_array_t x_n; // Declare the array
    reg [31:0] i = 0; // Index for x_n (unsigned for proper modulus behavior)
    reg delta_toggle = 1; // Toggle for delta_n calculation
    reg nData_toggle = 1; // Toggle for x_n data
    
    // Initialize the array with all zeros
    initial begin
        x_n = '{default: {XW{1'b0}}}; // Initialize all elements to zero
    end

    reg signed [DW-1:0] d = $rtoi(DECAY_VALUE * (1 << (DW - 1))); // Decay value in Q1.15 format
    reg signed [YW-1:0] yn_m1 = {YW{1'b0}}; // Previous output
    reg signed [DTW-1:0] delta_n; // Delta value
    reg signed [MW-1:0] mul_n; // Multiplication value
    wire signed [YWO-1:0] yn_o; // Output signal

    always @(posedge clk) begin 
        if (rst) begin
            yn_m1 <= {YW{1'b0}}; // Reset previous output
            yn <= {YW{1'b0}};    // Reset current output
            x_n <= '{default: {XW{1'b0}}}; // Reset all elements to zero
            delta_n <= {DTW{1'b0}}; // Reset delta_n
            mul_n <= {MW{1'b0}};    // Reset mul_n
            i <= 0; // Reset index
        end else if (cke) begin
            // Shift elements in x_n
            x_n[1] <= x_n[0];
            x_n[0] <= xn << (DW - 1);  // Shift input signal by DW - 1

            nData_toggle <= nData_toggle + 1; // Toggle x_n data

            if (!nData_toggle) begin
                i <= i + 1; // Increment index
            end
    
            // IIR filter equations
            if (delta_toggle) begin
                delta_n <= (yn >> (DW-1)) - x_n[0]; // Compute delta_n
                mul_n <= (delta_n * d);  // Perform arithmetic right shift to keep sign
                delta_toggle <= delta_toggle + 1; // Toggle delta_n calculation
                yn <= (mul_n + {x_n[1], {(DW-1){1'b0}}});
            end
            yn_m1 <= yn;               // Update previous output
        end
    end

    always @(negedge clk) begin
        if (cke && !rst) begin
            if (!delta_toggle) begin
                delta_n <= (yn >> (DW-1)) - x_n[0]; // Compute delta_n
                mul_n <= (delta_n * d);  // Perform arithmetic right shift to keep sign
                delta_toggle <= delta_toggle + 1; // Toggle delta_n calculation
            end
        end
    end

    assign yn_o = yn[YW-1:CONCAT_O]; // Assign the output width parameter

endmodule
