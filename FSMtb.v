state machine controller testbench


module FSMtb();





`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

//MACROS FOR VARIOUS STATES


`define reset 4'b0000
`define decode 4'b0001
`define getA 4'b0010
`define getB 4'b0011
`define execute 4'b0100
`define store 4'b0101
//mem_read_step1 is where output from the memory is updated
`define mem_read_step1 4'b0110
//mem_read_step2 is where the instruction register is updated with ouptut from memory
`define mem_read_step2 4'b0111
`define update_pc 4'b1000
//halt will remain as the state until reset is hit
`define halt 4'b101
`define load_data_adress 4'b1010
//reading from memory for LDR instruction
`define mem_read_LDR 4'b1011
`define executeSTR 4'b1100
//writing to memory state
`define writemem 4'b1101



reg /*s*/reset,clk,err;
reg [2:0] opcode;
reg [1:0] op;
wire /*w*/asel,bsel,loada,loadb,loadc,loads,write_regfile,load_pc,reset_pc,load_addr,addr_sel,load_ir;
wire [1:0] vsel,mem_cmd;
//nsel is one hot 
wire [2:0] nsel;

wire [3:0] state;
wire [3:0] next_state;

//probing state
assign state=DUT.state;
assign next_state=DUT.next_state;




FSMcontroller DUT(/*s,*/reset,clk,opcode,op,nsel,asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir);


initial begin
forever begin
clk=1'b0;
#10;
clk=1'b1;
#10;
end
end

initial begin
err=1'b0;
//need to reset state machine
reset=1'b1;
#15;// testing outputs in reset state
reset=1'b0;
if((mem_cmd!==`MNONE)|({load_pc,reset_pc}!==2'b11)) begin
err=1'b1;
end
#20;// testing outputs in mem_read_step1
if((mem_cmd!==`MREAD)|(addr_sel!==1'b1)) begin
err=1'b1;
end
opcode=3'b111;//to transition to halt once decode is reached
#20;//testing outputs in mem_read_step2
if((mem_cmd!==`MREAD)|(load_ir!==1'b1)|(addr_sel!==1'b1)) begin
 err=1'b1;
end
#20;//testing outputs in update_pc
if((mem_cmd!==`MNONE)|(reset_pc!==1'b0)|(load_pc!==1'b1))
#20;//in decode state
#20;//in halt state
#20;//still in halt
#20;//testing to make sure still in halt and not reset
if(reset_pc!==1'b0) begin
err=1'b1;
end
reset=1'b1;
#20;//in reset state
//testing to see if an ADD instruction will be executed after the decode state has been reached
{opcode,op}=5'b10100;
reset=1'b0;
#20;//mem_read_step1
#20;//mem_read_step2
#20;//update_pc
#20;//decode
#20;//getA
#20;//getB
if(loadb!==1'b1) begin
err=1'b1;
end
#20;//execute
#20;//store
if(write_regfile!==1'b1) begin
err=1'b1;
end
#20;//testing to see if read_mem_step1 was returned to after correct# of clock cycles
if(mem_cmd!==`MREAD) begin
err=1'b1;
end
#20;//now in read_mem_step2
//telling FSM to execute LDR instruction
{opcode,op}=5'b01100;
#20;//update PC
#20;//decode
#20;//should be in getA
if(loada!==1'b1) begin
err=1'b1;
end
#20;//should be executing and using immediate opearand instead of output from regb
if({loadc,bsel}!==2'b11) begin
err=1'b1;
end
#20;//should be loading to data adress register
if(load_addr!==1'b1) begin
err=1'b1;
end
#20;//memory read for LDR
if((addr_sel!==1'b0)|(mem_cmd!==`MREAD)) begin
err=1'b1;
end
#20;//store from mdata in multiplexer register Rn
if((vsel!==2'b11)|(nsel!==3'b010)) begin
err=1'b1;
end
#20;//should have returned to read_mem_step1

//TESTING STORE INSTRUCTION
{opcode,op}=5'b10000;

#20;//read_mem_step2
#20;//update pc
#20;//decode
#20;//getA
#20;//execute with asel=1'b0 bsel=1'b1
if({asel,bsel}!==2'b01) begin
err=1'b1;
end
#20;//load data adress
if(load_addr!==1'b1) begin
err=1'b1;
end
#20;//getB nsel should be 010 to get regsiter Rd
if({loadb,nsel}!==4'b1010) begin
err=1'b1;
end
#20;//executeSTR state
if({loadc,asel,bsel}!==3'b110) begin
err=1'b1;
end
#20;//write memory state
if( mem_cmd!==`MWRITE ) begin
err=1'b1;
end
#20;


end



endmodule