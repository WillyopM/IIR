module INTERFACE (
    input wire CLK, // Horloge
    input wire RST, // Reset synchrone, SW0
    input wire MODE_SW, // Mode select entre "0" et signal filtré, SW1
    output wire [15:0] led // Signal filtré
);
    // Signaux utilisés pour ILA
    wire signed [7:0] cosine;
    reg signed [7:0] delayed_Cosine = 0;
    reg signed [15:0] cosine_F = 0;
    reg signed [15:0] bus_out = 0;
    reg Last_sMode_SW = 0;
    reg delayed_cke = 0;
    reg Restart_SignalGen = 0;

    wire [3:0] si_o = 0;

    wire signed [15:0] yn;

    // Instantiation of FILTRE module
    IIR iir_inst (
        .clk(CLK),
        .rst(RST),
        .cke(delayed_cke),
        .xn(delayed_Cosine),
        .yn(yn)
    );

    SignalGen signalgen_inst (
        .clk(CLK),
        .rst(RST),
        .restart(Restart_SignalGen),
        .cosine(cosine),
        .i_o(si_o)
    );

    always @(posedge CLK) begin

        if (RST == 1 || Restart_SignalGen == 1)
            delayed_Cosine <= 0;
        else
            delayed_Cosine <= cosine;

        Restart_SignalGen <= Last_sMode_SW ^ MODE_SW;

        Last_sMode_SW <= MODE_SW;
        delayed_cke <= Last_sMode_SW;

        if (MODE_SW == 1)
            bus_out <= yn;
        else begin
            bus_out[15:8] <= cosine;
            bus_out[7:0] <= 0;
        end
    end

    assign led = bus_out;

endmodule
