module datapath(vsel,writenum,write,readnum,clk,loada,loadb,shift,asel,bsel,ALUop,loadc,loads,Z_out,N_out,V_out,datapath_out,sximm5,sximm8,PC,mdata);
input write,clk,loada,loadb,asel,bsel,loads,loadc;
input [1:0] shift,ALUop,vsel;
input [2:0] writenum,readnum;
input [8:0] PC;
input [15:0] sximm5,sximm8,mdata;
output Z_out,N_out,V_out;
output [15:0] datapath_out;
wire Z,N,V;
wire [15:0] data_in,data_out,regA_out,regB_out,Ain,Bin,sout,out;






//selecting to feed register with datapath_out for in0,{8'b0,PC} for in1,sximm8 for in2, datapath_in for in3
MUX4 #(16) inputMux(vsel,datapath_out,{7'b0000000,PC},sximm8,mdata,data_in);

//the register file itself
regfile REGFILE(data_in,writenum,write,readnum,clk,data_out);

//storing output from register file into regA for execution stage
REG #(16) regA(clk,loada,data_out,regA_out);
//storing output from register file into regB for execution stage
REG #(16) regB(clk,loadb,data_out,regB_out);

//shifter takes output from reg b and outputs sout intto BinMux
shifter shifter(regB_out,shift,sout);



//selecting between data_out and 16'b0 as A input to ALU
MUX #(16) AinMux(asel,regA_out,16'b0,Ain);
//selecting between shifter output or {11'b0,datapath_in[4:0]} as B input to ALU
MUX #(16) BinMux(bsel,sout,sximm5,Bin);

//instantiating alu with Ain/Bin as inputs and Z and out as outputs
ALU ALU(Ain,Bin,ALUop,out,Z,N,V);
//storing ALU output in register C
REG #(16)regC(clk,loadc,out,datapath_out);

//3 SEPERATE STATUS REGS ARE USED FOR THE DIFFERENT STATUS FLAGS

//storing the value of Z in the status register
REG regSZ(clk,loads,Z,Z_out);
//storing the of N in the status register
REG regSN(clk,loads,N,N_out);
//storing the value of V in the status register
REG regSV(clk,loads,V,V_out);

endmodule









//SOME USEFUL HELPER MODULES 




// 3 to 8 binary to one hot decoder

module DEC(in,out);
input[2:0] in;
output reg [7:0] out;

always@(in) begin
/*assigning one hot outputs based on corresponding binary values so 3'b000 results in 8'b00000001 and 3'b111 results in 8'b10000000. 
If input is 3'bx then output is 8'bx
*/
case(in)
3'b000:out=8'b00000001;
3'b001:out=8'b00000010;
3'b010:out=8'b00000100;
3'b011:out=8'b00001000;
3'b100:out=8'b00010000;
3'b101:out=8'b00100000;
3'b110:out=8'b01000000;
3'b111:out=8'b10000000;
default: out=8'bx;
endcase
end


endmodule




//N BIT LOAD ENABLED REGISTER

module REG(clk,load,in,out);
parameter n=1;
input clk,load;
input [n-1:0] in;
output reg [n-1:0] out;
wire [n-1:0] D;
wire [n-1:0] Q;

//selecting between input or output to copy into flip flop
MUX #(.n(n)) LoadEnable(load,out,in,D);

//reading D and assigning it to Q on posedge clk
vDFF #(.n(n)) RegisterFlipFlop(clk,D,Q);

//converting wire output Q from vDFF to reg output out
always@(Q) begin
out=Q;

end


endmodule







//N BIT MULTIPLEXER FOR FOUR INPUTS
module MUX4(sel,in0,in1,in2,in3,out);
parameter n=1;
input [1:0]sel;
input [n-1:0] in0,in1,in2,in3;
output reg [n-1:0] out;


//assigning output as in0, in1,in2,in3 based on 4 bit input, if input is x then output is x
always@(sel,in0,in1,in2,in3) begin
case(sel)
2'b00:out=in0;
2'b01:out=in1;
2'b10:out=in2;
2'b11:out=in3;
default: out=1'bx;
endcase
end
endmodule


//N BIT MULTIPLEXER FOR TWO INPUTS

module MUX(sel,in0,in1,out);
parameter n=1;
input sel;
input [n-1:0] in0,in1;
output reg [n-1:0] out;


//assigning output as in0 or in1 based on binary select input, if input is x then output is x
always@(sel,in0,in1) begin
case(sel)
1'b1:out=in1;
1'b0:out=in0;
default: out=1'bx;
endcase
end
endmodule





//8 INPUT N BIT MULTIPLEXER WITH ONE HOT SELECT

module MUX8(sel,in0,in1,in2,in3,in4,in5,in6,in7,out);
parameter n=1;
//this should be 1 hot select signal
input [7:0] sel;

input [n-1:0] in0,in1,in2,in3,in4,in5,in6,in7;
output reg [n-1:0] out;

/*
assigning appropriate ouput to input based on which bit of sel is hot(equal to 1).
This will obviously misbehave if multiple bits of sel are 1. If none of sel[7:0]=1 then output is 16'bx
*/
always@(sel,in0,in1,in2,in3,in4,in5,in6,in7) begin
if(sel[0]==1'b1)
out=in0;
else if(sel[1]==1'b1)
out=in1;
else if(sel[2]==1'b1)
out=in2;
else if(sel[3]==1'b1)
out=in3;
else if(sel[4]==1'b1)
out=in4;
else if(sel[5]==1'b1)
out=in5;
else if(sel[6]==1'b1)
out=in6;
else if(sel[7]==1'b1)
out=in7;
else
out=16'bx;

end

endmodule




//16 bit load enabled register to store instructions
module instruction_register(load,clk,in,out);
input load,clk;
input [15:0] in;
output reg [15:0] out;
//storing instruction signal on posedge clk
always@(posedge clk) begin
if(load==1'b1) begin
out=in;
end
end

endmodule







