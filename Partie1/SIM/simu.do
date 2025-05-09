puts "Simulation script for ModelSim "

vlib work
vcom -93 ../SRC/telemetre_us.vhd
vcom -93 testBench.vhd

vsim testBench(bench)

add wave -radix hexadecimal *


run -a
