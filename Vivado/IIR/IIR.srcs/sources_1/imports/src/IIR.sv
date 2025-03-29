module IIR #(
    parameter XWI = 16,  // Width of input signal x_n
    parameter DW = 16,  // Width of the decay value d
    parameter XW = XWI + DW - 1,  // Width of the internal input signal x_n
    parameter YW = 2*(DW-1) + XWI + 1,  // Width of internal output signal y_n
    parameter DTW = (XW > YW) ? XW + 1 : YW + 1, // Width of delta_n
    parameter MW = DTW + DW, // Width of mul_n
    parameter YWO = 32,  // Width of the output signal yn
    
    // Note: Real types are not synthesizable. For synthesis, calculate and provide the direct value.
    parameter real DECAY_VALUE = 0.99 // Decay value as a parameter
)(
    input  wire                  clk,      
    input  wire                  rst,      
    input  wire                  cke,      
    input  wire signed [XWI-1:0]  xn,  
    output wire  signed [YWO-1:0]  yn_o  
);
    
    typedef logic signed [XW:0] x_n_array_t [0:1]; // Define an array of signed values for x_n
    x_n_array_t x_n; // Declare the array
    // Initialize the array with all zeros
    initial begin
        x_n = '{default: {XWI{1'b0}}}; // Initialize all elements to zero
    end
    
    // IIR filter parameters
    reg signed [DTW-1:0] delta_n; // Delta value
    reg signed [MW-1:0] mul_n; // Multiplication value
    reg signed [YW-1:0] yn; // Output signal
    // Note: Real types are not synthesizable. For synthesis, calculate and provide the direct value.
    reg signed [DW-1:0] d = $rtoi(DECAY_VALUE * (1 << (DW - 1))); // Decay value
    
    // Used for falling edge calculation
    reg calc_toggle = 1; // Toggle for delta_n calculation

    // Debugging purposes
    reg [31:0] i = 0; // Index used for debugging purposes
    reg nData_toggle = 1; // Toggle for x_n data

    always @(posedge clk) begin 
        if (rst) begin
            yn <= {YW{1'b0}};
            x_n <= '{default: {XWI{1'b0}}}; // Reset all elements to zero
            delta_n <= {DTW{1'b0}};
            mul_n <= {MW{1'b0}}; 
            i <= 0;
            nData_toggle <= 1;
            calc_toggle <= 1;
        end else if (cke) begin
            // Shift elements in x_n
            x_n[1] <= x_n[0];
            x_n[0] <= xn << (DW - 1);  // Shift input signal by DW - 1

            // IIR filter equations
            if (calc_toggle) begin
                delta_n <= (yn >>> (DW-1)) - x_n[0]; // Compute delta_n and perform arithmetic right shift to keep sign
                mul_n <= (delta_n * d);  // Perform multiplication
                yn <= (mul_n + {x_n[1], {(DW-1){1'b0}}}); // Compute the output signal
                calc_toggle <= calc_toggle + 1; // Toggle for the falling edge calculation
            end
            
            // Debugging purposes
            nData_toggle <= nData_toggle + 1; // Toggle x_n data
            if (!nData_toggle) begin
                i <= i + 1; // Increment index
            end
    
        end
    end

    always @(negedge clk) begin
        if (cke && !rst) begin

            // IIR filter equations
            if (!calc_toggle) begin
                delta_n <= (yn >>> (DW-1)) - x_n[0]; // Compute delta_n and perform arithmetic right shift to keep sign
                mul_n <= (delta_n * d);  // Perform multiplication
                calc_toggle <= calc_toggle + 1; // Toggle delta_n calculation
            end
        end
    end

    assign yn_o = yn[YW-1:YW - YWO]; // Assign the output width parameter

endmodule
