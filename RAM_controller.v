module RAM_controller(clk,mem_cmd,mem_addr,read_data,write_data);
`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10


input clk;
input [1:0] mem_cmd;
input [8:0] mem_addr;
output [15:0] read_data;
input [15:0] write_data;
wire write;
wire [15:0] dout;
wire msel;
wire buffer_enable;

//instantiating the RAM module
RAM MEM(clk,mem_addr[7:0],mem_addr[7:0],write,write_data,dout);

//creating logic to control the IO behivour of RAM

//msel=1 only if mem_adress is 255 or lower
assign msel=~mem_addr[8];

//enable writing if mem_cmd is to write and adress exists
assign write=(mem_cmd==`MWRITE)&msel;

//defining condition to enable tri state buffer to read output
assign buffer_enable=msel&(mem_cmd==`MREAD);

//tri state buffer 
assign read_data = buffer_enable ? dout : 16'bzzzzzzzzzzzzzzzz;





endmodule
