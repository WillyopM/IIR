module FIR (
    input  wire        clk,      // Horloge
    input  wire        rst,      // Reset synchrone
    input  wire        cke,      // Clock enable
    input  wire signed [7:0]  cosine,  // Cosinus signal
    output reg  signed [15:0] cosine_f, // Cosinus filtré
    output wire [15:0] oAd0, oAd1, oAd2, oAd3, oAd4, oAd5, oAd6, oAd7
);

    // FIR coefficients
    localparam signed [5:0] h [0:7] = {6'd8, -6'd2, 6'd3, -6'd4, 6'd4, -6'd3, 6'd2, 6'd1};
    
    reg signed [7:0]  x_n [0:15];
    reg signed [13:0] mul [0:7];
    reg signed [15:0] ad [0:7];
    
    integer i;
    
    always @(posedge clk) begin 
        if (rst || !cke) begin
            for (i = 1; i < 16; i = i + 1)
                x_n[i] <= 8'sd0;
            for (i = 0; i < 8; i = i + 1) begin
                mul[i] <= 14'sd0;
                ad[i]  <= 16'sd0;
            end
            cosine_f <= 16'sd0;
        end else if (cke) begin
            // Décalage des valeurs de x_n
            for (i = 15; i > 0; i = i - 1)
                x_n[i] <= x_n[i - 1];
            x_n[0] <= cosine;

            // Multiplication des coefficients FIR avec les échantillons
            for (i = 0; i < 8; i = i + 1)
                mul[i] <= h[i] * x_n[2*i + 1];

            // Somme des multiplications
            ad[0] <= {{2{mul[0][13]}}, mul[0]};
            for (i = 1; i < 8; i = i + 1)
                ad[i] <= ad[i-1] + {{2{mul[i][13]}}, mul[i]};
            
            cosine_f <= ad[7];
        end
    end

    // Assignation des sorties
    assign oAd0 = ad[0];
    assign oAd1 = ad[1];
    assign oAd2 = ad[2];
    assign oAd3 = ad[3];
    assign oAd4 = ad[4];
    assign oAd5 = ad[5];
    assign oAd6 = ad[6];
    assign oAd7 = ad[7];

endmodule
