module lab7_homemade_testbench();
//THIS TESTBENCH IS TO BE RUN WITH ram_test.txt
//ADRESS FOR SWITCHES INTERFACE IS STORED IN adress 2'h4E or adress 8'b01001110 in memory
//ADRESS FOR LEDS INTERFACE IS STORED IN adress 2'h4F or adress 8'b01001111 in memory

reg err;



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



reg [3:0] KEY;
reg [9:0] SW;
wire [9:0] LEDR;
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);


//clock osscilations
initial begin
forever begin
//clock low
KEY[0]=1'b1;
#10;
//clock high
KEY[0]=1'b0;
#10;
end
end



initial begin
//switches will have a value on them to be read and eventually written to LEDs

SW[7:0]=8'b00110101;
err=1'b0;

#15;//allow one clock edge to pass without any reset asserted
KEY[1]=1'b0;//reset asserted
#20;//now in reset state
KEY[1]=1'b1;//reset de_asserted
#20;//in get memory step1 state
#60;//in decode, reading MOV R0, #01001110
#20;//storing
#20;//get memory step1
#60;//decoding MOV R1, #01001111
#20;//storing
#20;//get memory step1
#60;//decoding LDR R0,[R0]
#20;//getA
#20;//execute
#20;//load_data_adress
//testing that the correct adress of switch data in RAM is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`four,`E})  begin
err=1'b1;
end
#20;//mem_read_LDR
#20;//store
#20;//get memory step1
#60;//decoding LDR R1,[R1]
#60;//load_data_adress
//testing that the correct adress of LED data is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`four,`F})  begin
err=1'b1;
end
#60;//get memory step1
#60;//decoding MOV R2,#01000000
#20;//storing
#20;//get memory step1
#60;//decoding MOV R3,#00110011
#100;//decoding STR R3,[R2,#00010]
#20;//geta
#20;//execute
#20;//load_data_adress 
//testing that the correct adress for storage(R2+2) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`four,`two})  begin
err=1'b1;
end
#20;//getB
#20;//executeSTR
#20;//write mem
//testing that the correct data for storage is being outputted to write_data/seven seg
$display("time is %0t",$time);
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`three,`three})  begin
err=1'b1;
end
#20;//mem read step1
#60;//decoding LDR R4,[R2,#00010]
#60;//load data adress
//testing that the correct adress (R2+2) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`four,`two})  begin
err=1'b1;
end
#60;//read mem step1
#60;//decoding STR R4,[R1] //store value 8'b00110011 into LEDs
#60;//load data adress (corresponding to LED)
//testing that the correct adress (led adress) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`one,`zero,`zero})  begin
err=1'b1;
end
#60;//write mem
//testing that the correct data is being outputted to write_data/seven seg
$display("time is %0t",$time);
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`three,`three})  begin
err=1'b1;
end
#20;//read mem step1
//testing that the correct data was written to LEDS
if(LEDR[7:0]!==8'b00110011) begin
err=1'b1;
end
#60;//decoding LDR R5,[R0] //reading input to switches(8'b00110101) into R5
#60;//load data adress 
//testing that the correct adress (switch adress) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`one,`four,`zero})  begin
err=1'b1;
end
#60;//mem read step1
#60;//decoding MOV R5,R5 DISPLAYING THE DATA FROM THE SWITCHES
#20;//getB
#20;//execute
#20;//store
//testing that the correct data (switch data) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`three,`five})  begin
err=1'b1;
end
#20;//get memory step1
#60;//decoding STR R5,[R1] //writing value from switches 8'b00110101 into LEDs
#60;//load data adress
//testing that the correct adress (LED adress) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`one,`zero,`zero})  begin
err=1'b1;
end
#60;//write mem
//testing that the correct data (switch data) is being outputted to write_data/seven seg
if({HEX3,HEX2,HEX1,HEX0}!=={`zero,`zero,`three,`five})  begin
err=1'b1;
end
#20;//read mem step1;
//testing that the correct data was written to LEDS
if(LEDR[7:0]!==8'b00110101) begin
err=1'b1;
end
#60;//DECODE HALT

#10000;//we're just halted



end

endmodule
