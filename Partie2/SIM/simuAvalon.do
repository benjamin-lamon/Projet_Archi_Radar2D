puts "Simulation script for ModelSim "

vlib work
vcom -93 ../SRC/servo.vhd
vcom -93 ../SRC/servo_avalon.vhd
vcom -93 benchAvalon.vhd

vsim benchAvalon(bench)

add wave -radix unsigned *
add wave {sim:/benchavalon/uut/commande }
add wave {sim:/benchavalon/uut/s_commande } 
add wave {sim:/benchavalon/uut/s_position } 

run -a
