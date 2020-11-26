`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2020 08:18:37 PM
// Design Name: 
// Module Name: sync_vg
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


module interlacer
#(
    parameter       v_total_0   = 'd312,
    parameter       v_fp_0      = 'd6,
    parameter       v_sync_0    = 'd5,
    parameter       v_bp_0      = 'd13,
    parameter       v_total_1   = 'd313,
    parameter       v_fp_1      = 'd6,
    parameter       v_sync_1    = 'd5,
    parameter       v_bp_1      = 'd14,
    parameter       h_total     = 'd944,
    parameter       h_fp        = 'd12,
    parameter       h_sync      = 'd100,
    parameter       h_bp        = 'd64,
    parameter       hv_offset_0 = 'd0,
    parameter       hv_offset_1 = 'd472,
    parameter       X_BITS      = 'd12,
    parameter       Y_BITS      = 'd12
)(
    input                       clk         ,
    input                       reset       ,
    input                       vsync       ,
    input                       hsync       ,
    input                       de          ,
    input  [X_BITS-1:0]         h_cnt       ,
    input  [Y_BITS-1:0]         v_cnt       ,
    input  [X_BITS-1:0]         x_cnt       ,
    input  [Y_BITS-1:0]         y_cnt       ,
    output   reg                vs_out      ,
    output   reg                hs_out      ,
    output   reg                de_out      ,
    output   reg                field_out   ,
    output   wire               clk_out     ,
    output   reg  [Y_BITS-1:0]  v_out       ,
    output   reg  [X_BITS-1:0]  h_out       ,
    output   reg  [X_BITS-1:0]  x_out       ,
    output   reg  [Y_BITS-1:0]  y_out       

);

/* clk_out = 1/2 clk */
reg     clk_out_r;
always @ (posedge clk or posedge reset)
begin
    if (reset)  
    begin
        clk_out_r <= 1'b0;
    end
    else
    begin
        clk_out_r <= ~clk_out_r;
    end
end
assign  clk_out = clk_out_r;

/*  frame sync */
reg vsync_d1;
always @ (posedge clk or posedge reset)
begin
    if (reset)  
    begin
       vsync_d1 <= 1'b1;
    end
    else
    begin
       vsync_d1 <= vsync;
    end
end
wire    frame_sync = ~vsync_d1 & vsync;


/* field */
reg field;
wire [Y_BITS-1:0] v_total;
assign v_total = field ? v_total_0 : v_total_1;
/* field */
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        field <= 1'b1;
    end
    else 
    begin
        if ((v_cnt == v_total_0 + v_total_1 - 1) && (h_cnt == h_total - 1))
        begin
            field <= field + 1'b1;
        end
    end
end

/*
always @(posedge clk_out_r or posedge reset)
begin
    if (reset)
    begin
        field_out <= 1'b1;
    end
    else// if (ready)
    begin
        field_out <= field;
    end
end
*/

reg     v_sync_ready;
//always @ (posedge clk_out_r or posedge reset)
always @ (posedge clk or posedge reset)
begin
    if (reset)  
    begin
        v_sync_ready <= 1'b0;
    end
    else
    begin
        if (frame_sync)
        //if (field_out ^ field)
              v_sync_ready     <= 1'b1;  
    end
end

reg hsync_d1;
always @ (posedge clk)
begin
    if (reset && ~v_sync_ready)  
    begin
       hsync_d1 <= 1'b1;
    end
    else
    begin
       hsync_d1 <= hsync;
    end
end
wire    line_sync = v_sync_ready? (~hsync_d1 & hsync): 0;

reg     h_sync_ready;
//always @ (posedge clk_out_r or posedge reset)
always @ (posedge clk or posedge reset)
begin
    if (reset)  
    begin
        h_sync_ready <= 1'b0;
    end
    else
    begin
        if (line_sync)
              h_sync_ready     <= 1'b1;  
    end
end

wire ready = v_sync_ready & h_sync_ready;


reg write_en;
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        write_en <= 1'b0;
    end
    else if (ready)
    begin
        if (y_cnt!='d0 && y_cnt!='d0)
        begin
            if (y_cnt[0]==1'b1)
            begin
                write_en <= (field? 1'b0:1'b1)&de;
            end
            else
            begin
                write_en <= (field? 1'b1:1'b0)&de;
            end
        end
        else
            write_en <= 1'b0;
    end
end

//afifo_line  afifo_line_inst(
//	.rst                         (write_fifo_aclr         ),
//	.wr_clk                      (write_clk               ),
//	.rd_clk                      (mem_clk                 ),
//	.din                         (write_data              ),
//	.wr_en                       (write_en                ),
//	.rd_en                       (wr_burst_data_req       ),
//	.dout                        (wr_burst_data           ),
//	.full                        (                        ),
//	.empty                       (                        ),
//	.rd_data_count               (rdusedw                 ),
//	.wr_data_count               (                        )
//);


reg [X_BITS-1:0] h_count;
reg [Y_BITS-1:0] v_count;

//reg [Y_BITS-1:0] v_total;

reg [Y_BITS-1:0] v_fp;
reg [Y_BITS-1:0] v_bp;
reg [Y_BITS-1:0] v_sync;
reg [X_BITS-1:0] hv_offset;

always @(posedge clk_out_r or posedge reset)
begin
    if (reset || ~ready)
    begin
//        field <= 0;
        v_fp <= v_fp_1;
        v_bp <= v_bp_0;
        v_sync <= v_sync_0;
        hv_offset <= hv_offset_0;
    end
    else 
    begin
        if ((v_count == v_total - 1) && (h_count == h_total - 1))
        begin
//            field <= field + 1'b1;
            v_fp <= field ? v_fp_1 : v_fp_0;
            v_bp <= field ? v_bp_0 : v_bp_1;
            v_sync <= field ? v_sync_0 : v_sync_1;
            hv_offset <= field ? hv_offset_0 : hv_offset_1;
        end
    end
end


/* horizontal counter */
always @(posedge clk_out_r or posedge reset)
begin
    if (reset) begin
        h_count <= 0;
    end
    else if (ready)
    begin
        if (h_count < h_total - 1)
            h_count <= h_count + 1;
        else
            h_count <= 0;
    end
    else
        h_count <= 0;
end

/* vertical counter */
always @(posedge clk_out_r or posedge reset)
begin
    if (reset || ~ready) begin
        v_count <= 0;
    end
    else if (ready)
    begin
        if (h_count == h_total - 1)
        begin
            if (v_count == v_total - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end
end



always @(posedge clk_out_r or posedge reset)
begin
    if (reset)
        { vs_out, hs_out, de_out, field_out } <= 4'b0;
    else begin
        hs_out <= ((h_count < h_sync));
        de_out <= (((v_count >= v_sync + v_bp) && (v_count <= v_total - v_fp - 1)) && ((h_count >= h_sync + h_bp) && (h_count <= h_total - h_fp - 1)));
        if ((v_count == 0) && (h_count == hv_offset))
            vs_out <= 1'b1;
        else if ((v_count == v_sync) && (h_count == hv_offset))
            vs_out <= 1'b0;

        /* H_COUNT_OUT and V_COUNT_OUT */
        h_out <= h_count;
//        if (field)
//            v_count_out <= v_count + v_total_0;
//        else
            v_out <= v_count;

        /* X and Y coords - for a backend pattern generator */
        x_out <= h_count - (h_sync + h_bp);
        //if (interlaced)
            y_out <= { (v_count - (v_sync + v_bp)) , field };
        //else
            //y_out <= { 1'b0, (v_count - (v_sync + v_bp)) };
        field_out <= field;
    end
end

endmodule

