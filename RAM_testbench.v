module RAM_tb();
 `define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10


reg clk ,err;
reg [1:0] mem_cmd;
 reg[8:0] mem_addr;
reg[15:0] write_data;
wire [15:0] read_data;



//module instatitation
RAM_controller DUT(clk,mem_cmd,mem_addr,read_data,write_data);



//clock osscialtions
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
mem_cmd=`MNONE;

mem_addr=9'b000000000;
//this should do nothing as command is to do nothing
#15;
mem_cmd=`MREAD;
//read from adress 0 on posedge clk
#20;
if(read_data!==16'b1111111111111111) begin
err=1'b1;
end
#2;
mem_addr=9'b100000000;
#1;
//testing that driver outputs z for illegal adress
if(read_data!==16'bzzzzzzzzzzzzzzzz) begin
err=1'b1;
end
#17;
//writing to adress one
mem_addr=9'b000000001;
mem_cmd=`MWRITE;
write_data=16'b0000111100001111;
#5;
//checking that buffer outputs z due to being in writing mode
if(read_data!==16'bzzzzzzzzzzzzzzzz) begin
err=1'b1;
end
#15;
//reading from register 1 to see if it was written to
mem_cmd=`MREAD;
#20;
if(read_data!==16'b0000111100001111) begin
err=1'b1;
end
#20;
//testing that higher value register can be read from based on format given in file
mem_addr=9'b011111111;
#20;
if(read_data!==16'b1010101010101010) begin
err=1'b1;
end
#10;




end



endmodule 


