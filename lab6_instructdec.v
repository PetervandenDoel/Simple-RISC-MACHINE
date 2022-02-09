module instruct_dec(instructreg, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);

input [15:0] instructreg;
input [2:0] nsel;

output [2:0] opcode;
output [1:0] op;
output [1:0] ALUop;
output reg [15:0] sximm5;
output reg [15:0] sximm8;
output [1:0] shift;
output [2:0] readnum;
output [2:0] writenum;

wire [4:0] imm5;
wire [7:0] imm8;
wire [2:0] Rn, Rd, Rm;
wire [2:0] mux_out;
//making sure to disable shiftig for load and store instructions
assign shift = ((opcode==3'b011)|(opcode==3'b100))? 2'b00 :instructreg[4:3] ; 
assign Rn = instructreg[10:8];
assign Rd = instructreg[7:5];
assign Rm = instructreg[2:0];

MUX3 outputMUX(nsel, Rn, Rd, Rm, mux_out);

assign readnum=mux_out;
assign writenum = mux_out;

assign imm5 = instructreg[4:0];
assign imm8 = instructreg[7:0];

assign opcode = instructreg[15:13];
assign op = instructreg[12:11];	
assign ALUop = instructreg[12:11];

//sign extend imm5
always@* begin
	if(imm5[4]== 1'b0)begin
		sximm5 = {{11{1'b0}},imm5};
	end
	else if(imm5[4]== 1'b1) begin
		sximm5 = {{11{1'b1}},imm5};
	end
	else begin
		sximm5 = {16{1'bx}};
	end
end

//sign extend imm8

always @* begin 
	if(imm8[7] == 1'b0) begin
		sximm8 = {{8{1'b0}},imm8};
	end
	else if (imm8[7] == 1'b1)begin
		sximm8 = {{8{1'b1}},imm8};
	end
	else begin
	sximm8 = {16{1'bx}};
	end
end

endmodule


//3-bit multiplexer with one-hot select for three inputs
module MUX3(sel,in0,in1,in2,out);

//this should be 1 hot select signal
input [2:0] sel;

input [2:0] in0,in1,in2;
output reg [2:0] out;

/*
assigning appropriate ouput to input based on which bit of sel is hot(equal to 1).
This will obviously misbehave if multiple bits of sel are 1. If none of sel[7:0]=1 then output is 16'bx
*/
always@(sel,in0,in1,in2) begin
if(sel[0]==1'b1)
out=in0;
else if(sel[1]==1'b1)
out=in1;
else if(sel[2]==1'b1)
out=in2;
else begin

out=3'bx;
end
end
endmodule