
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
Module UART Receiver

Input:  clk_3125 - 3125 KHz clock
        rx- signal being received
        

Output: rx_msg   - received uart message
        rx_parity - received parity bit
		  rx_complete - successful uart packet processed signal


        Baudrate : 115200 bps
*/
/*
# Team ID:          1103
# Theme:            MazeSolver Bot
# Author List:      Goutham R, Harini M, Anshul L, Mohammed Anas
# Filename:         uart_tx.v
# File Description: Implements UART receiving protocal
# Global variables: - 
# Local variables : counter, data_counter, idle, start, transmit, done, data_cycles, state
*/

module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////


reg [7:0] buffer = 0; // buffer to load the message being received
//reg [8:0] counter = 0; // overal counter to ensure continous data transmission occurs according to 11520bps frame rate
reg [3:0] data_cycles = 0; // total data cycles, total 8 bit, for index
reg [5:0] counter = 0; // 27 clock cycles for one bit, as 8640/320 = 27 clock cycles

localparam idle =1'b0, receive =1'b1; //done = 2'b11;
//states that define the operation

reg state = idle;

always @(posedge clk_3125 ) begin

case (state) 
idle : begin // to initialise the values
	
		rx_parity <= (^buffer);
		data_cycles <= 0;
		rx_complete <= (buffer || rx_msg) ? 1 : 0; // logic to transmit rx_complete
		rx_msg <= buffer;
		counter <= 1;
		buffer <= 0;
		state <= receive;
end

receive : begin // to receive data, parity bit,even parity
				
	rx_complete <= 0;
	if (data_cycles == 0) begin	
			if (counter < 26) begin //27 clock cyles for one bit
					counter <= counter + 1;
					//rx_parity <= (^buffer);
			end else begin
					counter <= 0;
					data_cycles <= data_cycles + 1;
		//rx_parity <= (^buffer);
	end
	end
	else if ((data_cycles > 0) && (data_cycles <= 8)) begin
		
		if (counter < 26) begin //27 clock cycles for one bit
		
			buffer[7-data_cycles+1] <= rx;
			counter <= counter + 1;
			
			
		end
		
		else begin
			buffer[7-data_cycles+1] <= rx;
			counter <= 0;
			data_cycles <= data_cycles + 1;
		end
		
	
	end
	
	else if (data_cycles > 8) begin
	//parity bit loading
		if (counter < 26)  begin
				counter <= counter + 1;
			end
		
		else begin
				
				if (counter < 53) begin
					rx_complete <= 0;
					counter <= counter + 1;
		
				end		
					else begin
		
		//$display("Counter (done): %d", counter); to check if counter is working properly
					state <= idle;
					counter <= 1;
					end
			
			end
			
		
	end
end

/*done : begin //to ensure data receiving completes one frame or 297 clock cycles
	if (counter < 296) begin
		rx_complete <= 0;
		counter <= counter + 1;
		
	end		
	else begin
		
		//$display("Counter (done): %d", counter); to check if counter is working properly
		state <= idle;
		counter <= 1;
	end
	
end */
endcase
end
 


//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule
