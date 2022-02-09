
module regfile(data_in,writenum,write,readnum,clk,data_out);
input [15:0] data_in;
input [2:0] writenum, readnum;
input write, clk;
output [15:0] data_out;
// fill out the rest
wire[7:0] one_hot_write_adress,load_enables,mux_select;

//8 16bit buses to be fed from registers into multiplexer. These represent R0 R1 R2 .....R7
//wire  [15:0] mux_inputs [7:0];
wire [15:0] R0,R1,R2,R3,R4,R5,R6,R7;




//decoding binary writing adress to one hot code
DEC writing_adress_decoder(writenum,one_hot_write_adress);

//decoding binary reading adress to one hot code
DEC reading_adress_decoder(readnum,mux_select);

//making the load enable signal for each register equal to one_hot_write_adress[i]&write so no loading will be possible if write=1'b0
//if writenum is 3'bx then load_enables=8'bx
assign load_enables=one_hot_write_adress&{write,write,write,write,write,write,write,write};
/*
load_enables[i] will tell the ith register whetehr or not to store data_in(there are 8 registers numbered 0 to 7) 
R0,R1,R2...R7 go into the output select mux
if load_enable[i] is x then Ri becomes x on posedge clk
*/
//register 0
REG #(16) reg0(clk,load_enables[0],data_in,R0);
//register 1
REG #(16)reg1(clk,load_enables[1],data_in,R1);
//register 2
REG #(16)reg2(clk,load_enables[2],data_in,R2);
//register 3
REG #(16)reg3(clk,load_enables[3],data_in,R3);
//register 4
REG #(16)reg4(clk,load_enables[4],data_in,R4);
//register 5
REG #(16)reg5(clk,load_enables[5],data_in,R5);
//register 6
REG #(16)reg6(clk,load_enables[6],data_in,R6);
//register 7
REG #(16)reg7(clk,load_enables[7],data_in,R7);


//using multiplexer to select the output signal between R0 to R7
MUX8 #(16)outputMUX(mux_select,R0,R1,R2,R3,R4,R5,R6,R7,data_out);


endmodule














