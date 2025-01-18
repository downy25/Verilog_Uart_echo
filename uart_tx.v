module uart_tx(clk, rst, tx, data, data_rdy);
	input clk;   //12Mhz  (100Mhz -->12Mhz)
	input rst; //Negative reset
    input [7:0] data;
    input data_rdy;
	output tx;
	
	//Fixme
	parameter CLK_FREQ = 125000000;  //125Mhz	
	//parameter CLK_FREQ = 12000000 //클럭 주파수 12Mhz
	parameter BAUD_RATE = 230400; //BAUD_RATE 115200 bps
	parameter BIT_TIME = CLK_FREQ / BAUD_RATE;
	
	reg tx = 1;
	reg [15:0] clk_count = 0;
	reg [3:0] bit_index = 0;
	reg [7:0] tx_buffer = 0;
	reg tx_ing = 0;
	
	always @(posedge clk or posedge rst) begin  //pull_down 저항 안눌리면 0, 눌리면 1
		if(rst)begin
			tx <= 1'b1;
			clk_count = 0;
			bit_index = 0;
			//tx_buffer = 8'h35; //1넣기 h31
			tx_ing = 0;
		end
		else if(!tx_ing && data_rdy) begin  //rx쪽에서 완료되었으면 데이터를 tx_buffer에 저장
			tx_ing <= 1;
			tx <= 0;
            tx_buffer <= data;
			bit_index <= 0;
		end	
		else if(tx_ing) begin
			if(clk_count < BIT_TIME-1)begin
				clk_count <= clk_count +1;
			end
			else begin
				clk_count <= 0;
				if(bit_index < 8) begin
					tx <= tx_buffer[bit_index];
					bit_index <= bit_index + 1;
				end
				else if (bit_index == 8) begin
					tx <= 1; //stop bit
					bit_index <= bit_index + 1;
				end
				else begin
					tx_ing <= 0;
					tx <= 1;
				end
			end
		end
	end
endmodule