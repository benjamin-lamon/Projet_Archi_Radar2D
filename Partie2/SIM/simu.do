puts "Simulation script for ModelSim "

vlib work
vcom -93 ../SRC/servo.vhd
vcom -93 testBench.vhd

vsim testBench(bench)

add wave -radix decimal *
add wave {sim:/testbench/uut/state } 
add wave {sim:/testbench/uut/cpt_10ms }
add wave {sim:/testbench/uut/cpt_imp } 

run -a
