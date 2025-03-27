module INTERFACE (
    input wire CLK, // Horloge
    input wire RST, // Reset synchrone, SW0
    input wire MODE_SW, // Mode select entre "0" et signal filtré, SW1
    output wire [15:0] led // Signal filtré
);
    // Signaux utilisés pour ILA
    wire signed [7:0] sCosine;
    reg signed [7:0] sDelayed_Cosine = 0;
    reg signed [15:0] sCosine_F = 0;
    reg signed [15:0] sBUS_OUT = 0;
    reg Last_sMode_SW = 0;
    reg sDelayed_cke = 0;
    reg Restart_SignalGen = 0;

    wire [15:0] sAd0 = 0;
    wire [15:0] sAd1 = 0;
    wire [15:0] sAd2 = 0;
    wire [15:0] sAd3 = 0;
    wire [15:0] sAd4 = 0;
    wire [15:0] sAd5 = 0;
    wire [15:0] sAd6 = 0;
    wire [15:0] sAd7 = 0;
    wire [3:0] si_o = 0;

    wire signed [15:0] sFiltered_Cosine;

    // Instantiation of FILTRE module
    FIR filtre_inst (
        .clk(CLK),
        .rst(RST),
        .cke(sDelayed_cke),
        .cosine(sDelayed_Cosine),
        .cosine_f(sFiltered_Cosine),
        .oAd0(sAd0),
        .oAd1(sAd1),
        .oAd2(sAd2),
        .oAd3(sAd3),
        .oAd4(sAd4),
        .oAd5(sAd5),
        .oAd6(sAd6),
        .oAd7(sAd7)
    );

    SignalGen signalgen_inst (
        .clk(CLK),
        .rst(RST),
        .restart(Restart_SignalGen),
        .cosine(sCosine),
        .i_o(si_o)
    );

    always @(posedge CLK) begin

        if (RST == 1 || Restart_SignalGen == 1)
            sDelayed_Cosine <= 0;
        else
            sDelayed_Cosine <= sCosine;

        Restart_SignalGen <= Last_sMode_SW ^ MODE_SW;

        Last_sMode_SW <= MODE_SW;
        sDelayed_cke <= Last_sMode_SW;

        if (MODE_SW == 1)
            sBUS_OUT <= sFiltered_Cosine;
        else begin
            sBUS_OUT[15:8] <= sCosine;
            sBUS_OUT[7:0] <= 0;
        end
    end

    assign led = sBUS_OUT;

endmodule
