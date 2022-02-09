onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cputb/state
add wave -noupdate /cputb/reset
add wave -noupdate /cputb/read_data
add wave -noupdate /cputb/out
add wave -noupdate /cputb/next_state
add wave -noupdate /cputb/mem_cmd
add wave -noupdate /cputb/mem_addr
add wave -noupdate /cputb/err
add wave -noupdate /cputb/clk
add wave -noupdate /cputb/Z
add wave -noupdate /cputb/V
add wave -noupdate /cputb/PC
add wave -noupdate /cputb/N
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1827 ps}
