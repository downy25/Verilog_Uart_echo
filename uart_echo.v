module top_uart_tx(clk, rst_rx, rst_tx, rx, data_rdy, tx);
  input wire clk;
  input wire rst_rx;
  input wire rst_tx;
  input wire rx;
  output wire data_rdy;
  output wire tx;
  
  wire [7:0] data_out;
  
  vio_0 uut02 (
    .clk(clk),              // input wire clk
    .probe_in0(data_out)  // input wire [7 : 0] data_out
  );
  uart_rx uut1(clk, rst_rx, rx, data_out, data_rdy);
  uart_tx uut2(clk, rst_tx, tx, data_out, data_rdy);
endmodule


module uart_rx(clk, rst, rx, data_out, data_rdy);
  input clk;
  input rst;
  input rx;
  output [7:0] data_out;
  output data_rdy;
  
  parameter CLK_FREQ = 125000000;
  parameter BAUD_RATE = 230400;
  parameter BIT_TIME = CLK_FREQ / BAUD_RATE;
  
  reg [15:0] clk_count = 0;
  reg [3:0]  bit_index = 0;
  reg [7:0] rx_buffer = 0;
  reg rx_ing = 0;
  reg [7:0] data_out = 0;
  reg data_rdy = 0;
  reg flag = 0;
  
  ila_0 ila_0 (
	.clk(clk), // input wire clk
	.probe0(rx_buffer), // input wire [7:0]  probe0  
	.probe1(data_rdy) // input wire [0:0]  probe1
   );
  
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      clk_count = 0;
      bit_index = 0;
      rx_buffer = 0;
      rx_ing = 0;
      data_out = 0;
      data_rdy = 0;	
	end 
	else begin
	  if(!rx_ing && rx == 0) begin
	    rx_ing <= 1;
		clk_count <=  BIT_TIME / 2;
		bit_index <= 0;
		data_rdy <= 0;
	  end
	  else if(rx_ing) begin
	    if (clk_count < (BIT_TIME-1)) begin
	      clk_count <= clk_count +1;
	    end
		else begin
		  clk_count <= 0;
		  if(bit_index <8 ) begin
		    rx_buffer[bit_index] <= rx;
			if(flag)
			  bit_index <= bit_index + 1;
			else 
			  flag = 1;
		  end
		  else if(bit_index == 8 ) begin
		    if(rx == 1) begin
			  data_rdy <= 1;
			  data_out <= rx_buffer;
			  flag <= 0;
			end
			rx_ing <= 0;
			flag <= 0;
		  end
		end 
	  end 
	  else begin
	    data_rdy <= 0;
	  end
	end 
  end
endmodule