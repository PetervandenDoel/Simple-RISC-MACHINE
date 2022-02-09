module ALU(Ain,Bin,ALUop,out,Z,N,V);
input [15:0] Ain, Bin;
input [1:0] ALUop;
output [15:0] out;
output reg Z,N,V;
reg [15:0] out;


always@(*) begin
//performing operation corresponding to ALUop
	case(ALUop)
		{2'b00}: out = Ain + Bin;
		{2'b01}: out = Ain - Bin;
 		{2'b10}: out = Ain & Bin;
		{2'b11}: out = ~Bin;
		default: out = {16{1'bx}};
	endcase
/*
	if (ALUop == 2'b00) begin
		if(Ain + Bin == 0) Z = 1;
	end
	else if (ALUop == 2'b01) begin
		if(Ain - Bin == 0) Z = 1;
	end
	else if (ALUop == 2'b10) begin
		if(Ain & Bin == 0) Z = 1;
	end
	else if (ALUop == 2'b11)begin
		if(~Bin == 0) Z = 1;
	end
	else begin
	Z = 0;
	end 

*/
//status bit assignments
//assigning Z = 1 if out is 0 ZERO STATUS
if (out == 16'b0000000000000000)begin
Z =1'b1;
end
else begin
Z=1'b0;
end



//assigning N=1 if out[15]=1 representing negative 2s compliment representation
//NEGATIVE STATUS
if(out[15]==1'b1) begin
N=1'b1;
end
else begin
N=1'b0;
end

//assigning V=1 if overflow is detected and V=0 if not OVERFLOW STATUS


/*overflow from summation can be detected with these criteria taken from http://sandbox.mc.edu/~bennet/cs110/tc/orules.html

If the sum of two positive numbers yields a negative result, the sum has overflowed.
If the sum of two negative numbers yields a positive result, the sum has overflowed.
Otherwise, the sum has not overflowed.

overflow from subtraction can be detected with these criteria taken from https://www.doc.ic.ac.uk/~eedwards/compsys/arithmetic/index.html

If 2 Two's Complement numbers are subtracted, and their signs are different, then overflow occurs if and only if the result has the same sign as the subtrahend.
Overflow occurs if
(+A) ? (?B) = ?C
(?A) ? (+B) = +C

*/


//checking overflow from addition condition 1
if(ALUop===2'b00&Ain[15]===1'b0&Bin[15]===1'b0&out[15]===1'b1) begin
V=1'b1;
end 
//checking overflow from addition condition 2
else if(ALUop===2'b00&Ain[15]===1'b1&Bin[15]===1'b1&out[15]===1'b0) begin
V=1'b1;
end 

//checking overflow from subtraction condition 1
else if (ALUop===2'b01&Ain[15]===1'b0&Bin[15]===1'b1&out[15]===1'b1) begin
V=1'b1;
end
else if(ALUop===2'b01&Ain[15]===1'b1&Bin[15]===1'b0&out[15]===1'b0) begin
V=1'b1;
end 
else begin
V=1'b0;
end


//end of main always block
end

endmodule
