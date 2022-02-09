
module cpu(clk,reset,read_data,out,N,V,Z,mem_cmd,mem_addr);
input clk, reset;
input [15:0] read_data;
output [1:0] mem_cmd;
output [8:0] mem_addr;
output [15:0] out;
output N, V, Z;


wire asel,bsel,loada,loadb,loadc,loads,write_regfile,/*new wires for lab7*/load_ir,load_pc,reset_pc,addr_sel,load_addr;
wire [2:0] opcode,readnum,writenum,nsel;
wire[1:0] op,vsel,ALUop,shift;
wire [8:0] PC,next_pc, count_plusone, addr_out;
wire[15:0] instruction,sximm5,sximm8;


//instantiating instruction register to store instructions when load is enabled
instruction_register IRREG(load_ir,clk,read_data,instruction);


instruct_dec dec(instruction, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);


//instanting the FSM controller
//FSMcontroller FSM(s,reset,clk,opcode,op,nsel,w,asel,bsel,vsel,loada,loadb,loadc,loads,write);
FSMcontroller FSM(reset,clk,opcode,op,nsel,asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir);



//instantiating datapath to be controlled by FSM
datapath DP(vsel,writenum,write_regfile,readnum,clk,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,Z,N,V,out,sximm5,sximm8,PC,read_data);






//PROGRAM COUNTER SECTION

assign count_plusone = PC + 9'b000000001;

//multiplexer to add one to program counter or reset to 0
 MUX #(9) ADDONE(reset_pc,count_plusone, 9'b000000000,  next_pc);
//load endabled register for the program counter
REG #(9) Program_Counter(clk,load_pc, next_pc, PC);




//DATA ADRESS REGISTER SECTION
REG #(9) DATA(clk,load_addr ,out[8:0], addr_out);

MUX #(9) MEM(addr_sel, addr_out, PC, mem_addr);








endmodule