transcript on
#compile
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


#vcom -2008 -work work {./OUT_REG.vhd}
#vlog -vlog01compat -work work {./CONV_REGS.v}
vlog -vlog01compat -work work {./interlacer.v}
vlog -vlog01compat -work work {./colorbar_gen_rgb565.v}
vlog -vlog01compat -work work {./top.v}
vlog -vlog01compat -work work {./top_tb.v}

#simulate
vsim -novopt top_tb

#probe signals
add wave -radix unsigned *
add wave -radix unsigned /top_tb/top_inst/colorbar_gen_rgb565_inst/data
add wave -radix unsigned /top_tb/top_inst/h_cnt
add wave -radix unsigned /top_tb/top_inst/v_cnt
add wave -radix unsigned /top_tb/top_inst/x_cnt
add wave -radix unsigned /top_tb/top_inst/y_cnt
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/clk_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/field
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/field_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/frame_sync
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/ready
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/write_en
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/h_count
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/v_count
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/h_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/v_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/x_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/y_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/vs_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/hs_out
#add wave -radix unsigned /top_tb/top_inst/interlacer_inst/de_out
add wave -radix unsigned /top_tb/top_inst/interlacer_inst/*

view structure
view signals

#300 ns

run 100us
