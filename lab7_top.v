module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

input [3:0] KEY;
input [9:0] SW;
output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;


/*TO CHANGE MEMORY INITIALIZATION CHANGE THE FILENAME IN LINE
defparam MEM.filename="data.txt";
WHICH IS UNDER RAM INSTANTIATION

TESTBENCHING WAS DONE WITH "ram_test.txt" and human readable assembly is contained in "ram_test_annotations.txt"

*/



//seven segment macros

`define one 7'b1111001
`define two 7'b0100100
`define three 7'b0110000
`define four 7'b0011001
`define five 7'b0010010
`define six 7'b0000010
`define seven 7'b1111000
`define eight 7'b0000000
`define nine 7'b0010000
`define zero 7'b1000000
`define R 7'b0101111
`define P 7'b0001100
`define N 7'b0101011
`define L 7'b1000111
`define O 7'b1000000
`define S 7'b0010010
`define C 7'b1000110
`define D 7'b0100001
`define E 7'b0000110
`define F 7'b0001110
`define A 7'b0001000
`define B 7'b0000011



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






//ram interface
wire clk,reset;
wire [1:0] mem_cmd;
wire [8:0] mem_addr;
reg [15:0] read_data;
wire [15:0] write_data;
wire write;
wire [15:0] dout;
wire msel;
wire buffer_enable;

//status bits for cpu
wire N, V, Z;

//IO wires
//enables loading to LED register
reg LED_load;
//enables reading from switch buffers
reg SWITCH_read;
wire [15:0] read_data_RAM,read_data_SWITCH;



//SETTING INPUT SIGNALS FOR CLK AND RESET
assign clk=~KEY[0];
assign reset=~KEY[1];



//instantiion of ram module
RAM MEM(clk,mem_addr[7:0],mem_addr[7:0],write,write_data,dout);
//overriding filename paramter to choose memory initialization
defparam MEM.filename="ram_test.txt";
//creating logic to control the IO behivour of RAM
//msel=1 only if mem_adress is 255 or lower
assign msel=~mem_addr[8];
//enable writing if mem_cmd is to write and adress exists
assign write=(mem_cmd==`MWRITE)&msel;
//defining condition to enable tri state buffer to read output
assign buffer_enable=msel&(mem_cmd==`MREAD);
//tri state buffer 
assign read_data_RAM = buffer_enable ? dout : 16'bzzzzzzzzzzzzzzzz;



cpu CPU(clk,reset,read_data,write_data,N,V,Z,mem_cmd,mem_addr);



//SWITCH READ INTERFACE
//choosing whether or not to enable buffer outputs
always@(*) begin
if((mem_cmd==`MREAD)&(mem_addr==9'b101000000)) begin
SWITCH_read=1'b1;
end else begin
SWITCH_read=1'b0;
end
end

//buffers for switch output to read data
assign read_data_SWITCH[7:0]=SWITCH_read ? SW[7:0]: (8'bzzzzzzzz);
assign read_data_SWITCH[15:8]=SWITCH_read? (8'b00000000):(8'bzzzzzzzz);


//LED STORE INTERFACE
//register to store led output
REG #(8) LEDREG(clk,LED_load,write_data[7:0],LEDR[7:0]);
assign LEDR[9:8]=2'b00;
//enabling loading into LED register during store instuctions to register 9'b100000000
always@(*) begin
if((mem_addr==9'b100000000)&(mem_cmd==`MWRITE)) begin
LED_load=1'b1;
end
else begin
LED_load=1'b0;
end
end





//picking read_data based on which buffers are active
always@(*) begin
if(read_data_RAM!==16'bzzzzzzzzzzzzzzzz) begin
read_data=read_data_RAM;
end else if(read_data_SWITCH!==16'bzzzzzzzzzzzzzzzz) begin
read_data=read_data_SWITCH;
end else begin
//error case where both buffers are highZ
read_data=16'bxxxxxxxxxxxxxxxx;
end
end



//SEVEN SEGMENT INTERFACE

sseg H1(write_data[3:0],HEX0);
sseg H2(write_data[7:4],HEX1);
sseg H3(write_data[11:8],HEX2);
sseg H4(write_data[15:12],HEX3);
//sseg H1(SW[3:0],HEX0);
//sseg H2(SW[7:4],HEX1);
//assign HEX3=`zero;
//assign HEX2=`zero;
assign HEX4=`zero;
assign HEX5=`zero;










endmodule








module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;




  always@(in) begin
   
   case(in)
4'b0000: segs=`zero;
4'b0001: segs=`one;
4'b0010: segs=`two;
4'b0011: segs=`three;
4'b0100: segs=`four;
4'b0101: segs=`five;
4'b0110: segs=`six;
4'b0111: segs=`seven;
4'b1000: segs=`eight;
4'b1001: segs=`nine;
4'b1010: segs=`A;
4'b1011: segs=`B;
4'b1100: segs=`C;
4'b1101: segs=`D;
4'b1110: segs=`E;
4'b1111: segs=`F;
default: segs=`N;
endcase
   end
endmodule


module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule