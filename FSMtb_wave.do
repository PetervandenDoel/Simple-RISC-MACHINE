onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /FSMtb/write_regfile
add wave -noupdate /FSMtb/vsel
add wave -noupdate /FSMtb/state
add wave -noupdate /FSMtb/reset_pc
add wave -noupdate /FSMtb/reset
add wave -noupdate /FSMtb/opcode
add wave -noupdate /FSMtb/op
add wave -noupdate /FSMtb/nsel
add wave -noupdate /FSMtb/next_state
add wave -noupdate /FSMtb/mem_cmd
add wave -noupdate /FSMtb/loads
add wave -noupdate /FSMtb/loadc
add wave -noupdate /FSMtb/loadb
add wave -noupdate /FSMtb/loada
add wave -noupdate /FSMtb/load_pc
add wave -noupdate /FSMtb/load_ir
add wave -noupdate /FSMtb/load_addr
add wave -noupdate /FSMtb/err
add wave -noupdate /FSMtb/clk
add wave -noupdate /FSMtb/bsel
add wave -noupdate /FSMtb/asel
add wave -noupdate /FSMtb/addr_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4255 ps} 0}
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
WaveRestoreZoom {3900 ps} {5469 ps}
