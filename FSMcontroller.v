


module FSMcontroller(reset,clk,opcode,op,nsel,asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir);
input /*s*/reset,clk;
input [2:0] opcode;
input [1:0] op;
output reg /*w*/asel,bsel,loada,loadb,loadc,loads,write_regfile,load_pc,reset_pc,load_addr,addr_sel,load_ir;
output reg [1:0] vsel,mem_cmd;
//nsel is one hot 
output reg [2:0] nsel;

reg[3:0] state;
reg[3:0] next_state;


//MACROS for memory commands
`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

//MACROS FOR VARIOUS STATES
/*`define waiting 4'b0000*/
//program counter initialized in reset
`define reset 4'b0000
//choose next state from instruction register 
`define decode 4'b0001
//load into reg a
`define getA 4'b0010
//load into reg b
`define getB 4'b0011
//use alu to store result in reg c
`define execute 4'b0100
//store value in reg in register file
`define store 4'b0101
//mem_read_step1 is where output from the memory is updated
`define mem_read_step1 4'b0110
//mem_read_step2 is where the instruction register is updated with ouptut from memory
`define mem_read_step2 4'b0111
`define update_pc 4'b1000
//halt will remain as the state until reset is hit
`define halt 4'b1001
//for loading into data adress register to execute LDR/STR instructions
`define load_data_adress 4'b1010
//reading from memory for LDR instruction
`define mem_read_LDR 4'b1011
//execute state for outputting value in Rd to datapath_out to execute STR instruction
`define executeSTR 4'b1100
//writing to memory state
`define writemem 4'b1101


//THIS IS A MEALY MACHINE THAT USES STATES AND OPCODE TO PICK OUTPUTS
//AND TO PICK STATE TRANSITIONS





//state transition logic
always@(*) begin
case(state)

//only leave waiting state if s is 1, NEXT STATE WILL BE DECODE IN LATER VERSIONS
/*`waiting:next_state= ((s==1'b1)? `decode: `waiting );*/

//will remain halted
`halt:next_state=`halt;

//in reset state, transition to state 1 for reading instructions from memory
`reset : next_state = `mem_read_step1;
//after memory reading step 1, transition to memory reading step 2
`mem_read_step1 :next_state = `mem_read_step2;
//after instructiosn loaded into instruction register, update program counter
`mem_read_step2 : next_state=`update_pc;
//after updating program counter, decode
`update_pc: next_state=`decode;



//next state after decoding will depend on {opcode,op}
`decode: begin
//next state will be store if instruction is MOV Rn,#<im8> ({opcode,op}=5'b11010)
if({opcode,op}==5'b11010) begin 
next_state=`store;
end 

//next state will be halt if opcode=111
else if(opcode==3'b111) begin
next_state=`halt;
end




/*next state will be getB if instruction is MOV Rd,Rm{,<sh_op>} or MVN Rd,Rm{,<sh_op>} 
{opcode,op}=5'b11000 or {opcode,op}=5'b10111 respectivly*/
else if(({opcode,op}==5'b10111)|({opcode,op}==5'b11000)) begin
next_state=`getB;
end
//if the instructions are ADD, CMP, AND, LDR,or STR then the next step is to load into regA
else if( ({opcode,op}==5'b10100) | ({opcode,op}==5'b10101) | ({opcode,op}==5'b10110)|({opcode,op}==5'b01100)|({opcode,op}==5'b10000) ) begin
next_state=`getA;
end
//if the opcode does not correspond to any of the aformetioned instructions then reset instead of keeping up with illegal instructions
else begin
next_state=`reset;
end
//end of decode case
end


//after getting A FSM must get B UNLESS PERFORMING LDR OR STR IN WHICH CASE IT WILL GO TO EXECUTE
`getA:begin 
if(({opcode,op}==5'b01100)|({opcode,op}==5'b10000)) begin
next_state=`execute;
end
else begin
next_state=`getB;
end
end


//after getting B FSM must execute unless executing STR in which case it will go to executeSTR state 
`getB: begin 
if({opcode,op}==5'b10000) begin
next_state=`executeSTR;
end
else begin
next_state=`execute;
end
end


//after execution FSM must store UNLESS THE OPERATION IS CMP so {opcode,op}=10101 then go right back to memory_reading without storing
//MAKE SURE STATUS FLAG REGISTER ONLY UPDATES WHEN DOING CMP 
`execute:begin
//if instruction is CMP
if({opcode,op}==5'b10101)  begin
next_state=`mem_read_step1;
end
//transition to store in data adress reg if executing LDR or STR instruction
else if(({opcode,op}==5'b01100)|({opcode,op}==5'b10000)) begin
next_state=`load_data_adress;
end

else begin
next_state=`store;
end
//end of execute case
end

//after storing, the FSM will read the next instruction no matter what
`store: begin next_state=`mem_read_step1;
end

//transition from loading data adress to reading for LDR or getting value for STR
`load_data_adress: begin
//transiiton to LDR memory reading stage if performing LDR
if({opcode,op}==5'b01100) begin
next_state=`mem_read_LDR;
end
else begin
//or elseget data from adress Rd to store to memory
next_state=`getB;
end
end

//when reading from memory in an LDR instruction, the next step is to store
`mem_read_LDR: begin
next_state=`store;
end

//state where value from reg is loaded into regC in order to write to memory in STR instruction
//next state is writing to memory
`executeSTR: begin
next_state=`writemem;
end
//will write to memory and go to read next instruction on rising edge of clock
`writemem: begin 
next_state=`mem_read_step1;
end

//don't care about next state if state is illegal value
default:next_state=4'bxxxx;
endcase

end
















//state transition always block
always@(posedge clk) begin
if(reset==1'b1) begin
state=`reset;
end
else begin
state=next_state;
end 
end





//output behivour based on state
always@(*) begin
case(state)



`reset:begin
//reset program counter to 0 and load value into it, other settings can be copied from waiting state
//values for lab 7
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={2'b11,5'b00000};
//values from lab 6
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};
end

`halt: begin
//nothing is to be done in the halt state

//values for lab 7
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={2'b00,5'b00000};
//values from lab 6
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};

end


`mem_read_step1: begin
//values for executing instructions don't matter
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};
//make sure to select program counter and be in read mode
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={3'b000,1'b1,`MREAD,1'b0};
end

`mem_read_step2: begin
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};

{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={3'b000,1'b1,`MREAD,1'b1};

end

`update_pc: begin
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};

{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={1'b1,2'b00,1'b1,`MNONE,1'b0};



end



//every value should be 0 when decoding
`decode:begin {asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};
//RAM interaction variables are 0 when executing instructions
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={7'b0000000};
end

//when getting A loada is enabled, nsel will read Rn which corresponds to 001, other signals are 0
`getA: begin{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={4'b0000,1'b1,4'b0000,3'b001};
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}=7'b0000000;
end
//when getting B loada is enabled, nsel will read Rm which corresponds to 100, other signals are 0
//nsel=100 unless performing STR in which case nsel=010
`getB:begin{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile}={5'b00000,1'b1,3'b000};
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}=7'b0000000;
if({opcode,op}==5'b10000) begin
nsel=3'b010;
end else begin
nsel=3'b100;
end
end

/* when executing, bsel=0 and asel=0 unless moving from one register to another IE MOV Rd,Rm{,<sh_op>}
 or {opcode,op}=11000 ,loadc and loads are enabled, all other values 0, decoder will handle ALUop and shift*/
`execute: begin {vsel,loada,loadb,loadc,write_regfile,nsel}={4'b0000,1'b1,4'b0000};

{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}=7'b0000000;
//if the goal is to move from one register to another MOV Rd,Rm{,<sh_op>} then select 16'b0 instead of aout for Ain to ALU
if({opcode,op}==5'b11000) begin
//output 0 as Ain for ALU
asel=1'b1;
loads=1'b0;
bsel=1'b0;
end
//update status register if performing CMP operation
else if({opcode,op}==5'b10101)  begin
loads=1'b1;
//output value from register A into ALU
asel=1'b0;
bsel=1'b0;
//bsel=1'b1 if adding immediate operand to an adress in rega for LDR or STR
end else if(({opcode,op}==5'b01100)|({opcode,op}==5'b10000))  begin
loads=1'b0;
asel=1'b0;
bsel=1'b1;
end


//if instruction is neither move value from one reg to another nor CMP then select aout and do not update status register
else begin
asel=1'b0;
loads=1'b0;
bsel=1'b0;
end
//end of execute state condition
end



/*when storing the result of a computation into regfile vsel=00 and nsel=010 to pick Rd, when storing immediate operand MOV Rn,#<im8>
{opcode,op}=11010 vsel=10 and nsel=001 to pick Rn,write_regfile=1 to enable write_regfile, other signals are 0 */
`store:begin {asel,bsel,loada,loadb,loadc,loads,write_regfile}={2'b00,4'b0000,1'b1};
{load_pc,reset_pc,load_addr,addr_sel,load_ir}={4'b0000,1'b0};
//if storing an immidiate operand
if({opcode,op}==5'b11010) begin
//store immediate operand into regfile
vsel=2'b10;
nsel=3'b001;
mem_cmd=`MNONE;
end
//if storing from RAM (LDR instruction)
else if({opcode,op}==5'b01100) begin
vsel=2'b11;
nsel=3'b010;
mem_cmd=`MREAD;
end else 
begin
//store datapath_out into regfile
vsel=2'b00;
nsel=3'b010;
mem_cmd=`MNONE;
end
//end of store case condition
end

//for loading data adress in LDR/STR instructions
`load_data_adress: begin

//all datapath variables are not needed
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};

//load enabled on adress register, addr_sel is on to signify next step of feeding from adress reg to RAM
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={2'b00,2'b11,3'b000};
end

//for reading from memory in an LDR instruction
`mem_read_LDR: begin
//datapath variables not needed
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};
//must be in reading and selecting instruction from register not program counter
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={4'b0000,`MREAD,1'b0};
end

`executeSTR: begin
//add 0 from mux after reg a to what is in reg b
//values for lab 7
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={2'b00,5'b00000};
//values from lab 6
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={1'b1,5'b00000,1'b1,5'b00000};
end

`writemem: begin
//will write to adress given by register from datapath out on posedge clk
//values for lab 7
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}={2'b00,2'b00,`MWRITE,1'b0};
//values from lab 6
{asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'b000000000000};


end



//don't care about anything in default case
default:begin {asel,bsel,vsel,loada,loadb,loadc,loads,write_regfile,nsel}={12'bxxxxxxxxxxxx};
{load_pc,reset_pc,load_addr,addr_sel,mem_cmd,load_ir}=7'bxxxxxxx;
end
endcase


end




endmodule
