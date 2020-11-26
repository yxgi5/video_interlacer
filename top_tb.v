`timescale 1ps/ 1ps

module top_tb();

reg  clk;
reg  rst_n;
wire hdmi_tx_clk;
wire hdmi_tx_de;
wire hdmi_tx_vs;
wire hdmi_tx_hs;
wire [15:0] hdmi_td;

top top_inst
(
    .sys_clk         (clk),       //system clock 50Mhz on board
    .rst_n           (rst_n),       //reset input，low active
    .hdmi_tx_clk	 (hdmi_tx_clk),
    .hdmi_tx_de 	 (hdmi_tx_de),
    .hdmi_tx_vs      (hdmi_tx_vs),
    .hdmi_tx_hs      (hdmi_tx_hs),
    .hdmi_td         (hdmi_td)
);

initial
begin
    rst_n = 0;
    clk = 0;
    #4000;
    rst_n = 1;
end

always
begin
    #10 clk = ~clk; // 400MHz sample clock
end

endmodule
