module INTERFACE (
    input wire CLK, // Horloge
    input wire RST, // Reset synchrone, SW0
    input wire MODE_SW, // Mode select entre "0" et signal filtré, SW1
    output wire [15:0] led // Signal filtré
);

    // Debounce state
    reg [8:0] debounce_counter_mode = 0;
    reg [8:0] debounce_counter_rst = 0;
    reg [8:0] clk_counter_rst = 0;
    reg [8:0] clk_counter_mode = 0;
    reg mode_state = 0;
    reg rst_state = 0;

    // Signaux utilisés pour ILA
    reg signed [7:0] sCosine = 0;
    reg signed [7:0] sDelayed_Cosine = 0;
    wire [7:0] std_sCosine = 0;
    reg signed [15:0] sCosine_F = 0;
    wire [15:0] std_sCosine_F = 0;
    reg signed [15:0] sBUS_OUT = 0;
    wire [15:0] std_sBUS_OUT = 0;
    wire sMode_SW = 0;
    reg Last_sMode_SW = 0;
    reg sDelayed_cke = 0;
    reg Restart_SignalGen = 0;

    reg [15:0] sAd0 = 0;
    reg [15:0] sAd1 = 0;
    reg [15:0] sAd2 = 0;
    reg [15:0] sAd3 = 0;
    reg [15:0] sAd4 = 0;
    reg [15:0] sAd5 = 0;
    reg [15:0] sAd6 = 0;
    reg [15:0] sAd7 = 0;
    reg [3:0] si_o = 0;

    wire signed [15:0] sFiltered_Cosine;

    // Instantiation of FILTRE module
    FIR filtre_inst (
        .clk(CLK),
        .rst(RST),
        .input_signal(sCosine),
        .filtered_signal(sFiltered_Cosine)
    );

    always @(posedge CLK) begin
        // Debounce logic for reset
        if (RST != rst_state) begin
            if (clk_counter_rst == 0)
                debounce_counter_rst <= debounce_counter_rst + 1;
            clk_counter_rst <= clk_counter_rst + 1;
            if (debounce_counter_rst == 511) begin
                rst_state <= RST;
                debounce_counter_rst <= 0;
            end
        end else begin
            debounce_counter_rst <= 0;
        end

        if (rst_state == 1 || Restart_SignalGen == 1)
            sDelayed_Cosine <= 0;
        else
            sDelayed_Cosine <= sCosine;

        Restart_SignalGen <= Last_sMode_SW ^ mode_state;

        if (sMode_SW != mode_state) begin
            if (clk_counter_mode == 0)
                debounce_counter_mode <= debounce_counter_mode + 1;
            clk_counter_rst <= clk_counter_rst + 1;
            if (debounce_counter_mode == 511) begin
                mode_state <= sMode_SW;
                debounce_counter_mode <= 0;
            end
        end else begin
            debounce_counter_mode <= 0;
        end

        Last_sMode_SW <= mode_state;
        sDelayed_cke <= Last_sMode_SW;

        if (mode_state == 1)
            sBUS_OUT <= sFiltered_Cosine;
        else begin
            sBUS_OUT[15:8] <= sCosine;
            sBUS_OUT[7:0] <= 0;
        end
    end

    assign led = std_sBUS_OUT;
    assign std_sCosine = sCosine;
    assign std_sCosine_F = sCosine_F;
    assign std_sBUS_OUT = sBUS_OUT;
    assign sMode_SW = MODE_SW;

endmodule
