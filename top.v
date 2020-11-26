`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2020 02:11:18 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
(
//input                           sys_clk_p 		,       // system clock 200MHz
//input                           sys_clk_n 		, 
input                           sys_clk         ,       //system clock 50Mhz on board
input                           rst_n           ,       //reset input，low active
output 	 			            hdmi_tx_clk	    ,
output 	 			            hdmi_tx_de 	    ,
output                          hdmi_tx_vs      ,
output                          hdmi_tx_hs      ,
output      [15:0]              hdmi_td         
);

//wire                          sys_clk         ;
wire                            locked          ;
wire                            clk_50MHz       ;
wire                            data_clk        ;
wire                            rst             ;
assign  rst =                   ~rst_n          ;
assign  data_clk =              sys_clk         ;
assign  locked =                rst_n           ;

wire    [11:0]x_cnt;
wire    [11:0]y_cnt;
wire    [11:0]h_cnt;
wire    [11:0]v_cnt;
wire    fv;
wire    lv;
wire    [15:0] pdata;
wire    de1;
wire    hs1;
wire    vs1;
colorbar_gen_rgb565 #(
//768*576 50fps @ 29.5MHz
    .h_active       ('d768 ),
	.h_total        ('d944 ),
	.v_active       ('d576 ),
	.v_total        ('d625 ),
	.H_FRONT_PORCH  ('d12  ),
	.H_SYNCH        ('d100 ),
	.H_BACK_PORCH   ('d32  ),
	.V_FRONT_PORCH  ('d12  ),
	.V_SYNCH        ('d10  ),
    .V_BACK_PORCH   ('d27  ),
    .input_mode     ('d0   ),
    .clk2_mode      ('d0   ),
    .pattern_mode   ('d0   )
)colorbar_gen_rgb565_inst
(
	.rstn       (locked  ) , 
	.clk        (data_clk) ,
	.data_i     (16'b0),
	.fv         (fv) ,
	.lv         (lv) ,
	.data       (pdata),
	.de         (de1),
	.vsync      (vs1),
	.hsync      (hs1),
	.x_cnt      (x_cnt),
	.y_cnt      (y_cnt),
	.h_cnt      (h_cnt),
	.v_cnt      (v_cnt),
	.ready      ()
);

assign hdmi_tx_clk = data_clk;
assign hdmi_tx_de = de1;
assign hdmi_tx_vs = vs1;
assign hdmi_tx_hs = hs1;
assign hdmi_td    = pdata;

interlacer 
#(
    .v_total_0  ('d312),
    .v_fp_0     ('d6),
    .v_sync_0   ('d5),
    .v_bp_0     ('d13),
    .v_total_1  ('d313),
    .v_fp_1     ('d6),
    .v_sync_1   ('d5),
    .v_bp_1     ('d14),
    .h_total    ('d944),
    .h_fp       ('d12),
    .h_sync     ('d100),
    .h_bp       ('d64),
    .hv_offset_0('d0),
    .hv_offset_1('d472)
)
interlacer_inst
(
    .clk        (data_clk),
    .reset      (rst),
    .vsync      (vs1),
    .hsync      (hs1),
    .de         (de1),
    .h_cnt      (h_cnt),
    .v_cnt      (v_cnt),
    .x_cnt      (x_cnt),
    .y_cnt      (y_cnt),
    .vs_out     (),
    .hs_out     (),
    .de_out     (),
    .field_out  (),
    .clk_out    (),
    .v_out      (),
    .h_out      (),
    .x_out      (),
    .y_out      ()
);

endmodule

