//TESTBENCH FOR CPU MODULE

module cputb();

reg clk, reset,err;
reg [15:0] read_data;
wire [1:0] mem_cmd;
wire [8:0] mem_addr,PC;
wire [15:0] out;
wire N, V, Z;
wire[3:0] state,next_state;


assign state=DUT.FSM.state;
assign next_state=DUT.FSM.next_state;
assign PC=DUT.PC;

cpu DUT(clk,reset,read_data,out,N,V,Z,mem_cmd,mem_addr);

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
reset=1'b1;
#15;//in reset state
reset=1'b0;
$display("time is %0t",$time);
//move 2 to regsiter 0
read_data=16'b1101000000000010;
#40;//get instr from mem step2
//cheking proigram counter value
if(mem_addr!==9'b000000000) begin
err=1'b1;
end
#20;//update pc
#20;//decode
#20;//store
#20;//get mem step1
//checking program counter has been updated and mem command is correct
if((mem_addr!==9'b000000001)|(mem_cmd!==2'b01)) begin
err=1'b1;
end

//TEST CASE FOR LDR R1,[R0,#4]
read_data=16'b0110000000100100;
#20;//get mem step2
#20;//update pc
#20;//decode
//checl that mem_cmd is do nothing
if(mem_cmd!==2'b00)begin
err=1'b1;
end
//mimicing data output from ram
read_data=16'b1111111111111111;
#20;//getA
#20;//execute
#20;//load_data_adress
//checking that datapath outputs correct adress
if(out!==16'b0000000000000110) begin
err=1'b1;
end
#20;//mem_read_LDR
if((mem_cmd!==2'b01)|(mem_addr!==9'b000000110)) begin
err=1'b1;
end
#20;//store state, storing -1 in register 1
if(mem_cmd!==2'b01) begin
err=1'b1;
end
#20;//back to mem read step1
if(mem_cmd!==2'b01) begin
err=1'b1;
end


//TESTING STR INSTRUCTION STR R1,[R0,#31]
read_data=16'b1000000000101111 ;
#20;//mem_read_step2
#20;//update PC
#20;//decode
#20;//getA
#20;//execute
#20;//load_data_adress
//checking that correct adress+offset has been output
if(out!==(9'b000000010+9'b000001111)) begin
err=1'b1;
end
#20;//getB
#20;//executeSTR
#20;//write_mem
$display("time is %0t",$time);
//testing that we are writing correct value into the correct adress
if((mem_cmd!==2'b10)|(out!==16'b1111111111111111)|(mem_addr!==(9'b000000010+9'b000001111))) begin
err=1'b1;
end
#20;//mem_read_step1





















end



endmodule
