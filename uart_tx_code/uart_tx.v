// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/
/*
# Team ID:          1103
# Theme:            MazeSolver Bot
# Author List:      Goutham R, Harini M, Anshul L, Mohammed Anas
# Filename:         uart_tx.v
# File Description: Implements UART transmission protocal
# Global variables: - 
# Local variables : counter, data_counter, idle, start, transmit, done, data_cycles, state
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);



initial begin
    tx = 1'b1;
    tx_done = 1'b0;
	 
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

localparam idle = 1'b0,  transmit =1'b1;

//reg [8:0] counter = 0; // overal counter to ensure continous data transmission occurs according to 11520bps frame rate
reg [3:0] data_cycles = 0; // total data cycles, total 8 bit, for index
reg [5:0] counter = 0; // 27 clock cycles for one bit, as 8640/320 = 27 clock cycles
reg state = idle;

always @(posedge clk_3125 ) begin

case (state) 
idle : begin // to initialise the values
	
	data_cycles <= 0;
	tx_done <= 0;
	counter <= 1;
	if (tx_start)
		tx <= 0;
		
	else begin
		counter <= counter + 1;
		if (counter == 26) begin
			state <= transmit;
			counter <= 0;
		end
	end
end

/*start : begin // to serially transmit start bit

	if (counter < 26) begin //27 clock cyles for one bit
		counter <= counter + 1;
		tx <= 0;
	end else begin
		counter <= 0;
		state <= transmit;
	end
		

end*/
transmit : begin // to serially transmit data, parity bit, parity_type is chosen accordingly


	

	if (data_cycles <= 7)begin
		
			tx <= data[7-data_cycles];
			counter <= counter + 1;
			
		
		if (counter == 26) begin //27 clock cycles for one bit
			counter <= 0;
			data_cycles <= data_cycles + 1;
		end
		
	
	end
	
	else  begin
		
			tx <= (^data);
			//$display("dataCounter (party): %d", data_counter);
			counter <= counter + 1;
			
		if (counter == 53) begin
    tx_done <= 1;
    tx <= 1;
    state <= idle;
end
else if (counter >= 27) begin
    tx <= 1;
    tx_done <= 0;
    counter <= counter + 1;
end

	
			

		
	
end

/*done : begin //to serially transmit tx_done to make sure data has been serially transmitted correctly.
	
	if (counter < 25) begin
		tx_done <= 0;
		counter <= counter + 1;
		tx <= 1;
	end
	else if (counter == 25) begin
		tx_done <= 1;
		counter <= counter + 1;
		tx <= 1;
	end
	
	else begin
		tx_done <= 0;
		state <= idle;
		counter <= 1;
	end
	
end*/
end
endcase
end
 
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

