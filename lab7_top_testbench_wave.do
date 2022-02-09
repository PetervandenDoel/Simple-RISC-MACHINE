onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/FSM/state
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/PC
add wave -noupdate /lab7_homemade_testbench/DUT/MEM/mem
add wave -noupdate /lab7_homemade_testbench/err
add wave -noupdate /lab7_homemade_testbench/SW
add wave -noupdate /lab7_homemade_testbench/LEDR
add wave -noupdate /lab7_homemade_testbench/KEY
add wave -noupdate /lab7_homemade_testbench/HEX5
add wave -noupdate /lab7_homemade_testbench/HEX4
add wave -noupdate /lab7_homemade_testbench/HEX3
add wave -noupdate /lab7_homemade_testbench/HEX2
add wave -noupdate /lab7_homemade_testbench/HEX1
add wave -noupdate /lab7_homemade_testbench/HEX0
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R7
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R6
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R5
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R4
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R3
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R2
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R1
add wave -noupdate /lab7_homemade_testbench/DUT/CPU/DP/REGFILE/R0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2010 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 280
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {2010 ps} {2424 ps}
