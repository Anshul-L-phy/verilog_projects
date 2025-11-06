/*
Module HC_SR04 Ultrasonic Sensor

This module will detect objects present in front of the range, and give the distance in mm.

Input:  clk_50M - 50 MHz clock
        reset   - reset input signal (Use negative reset)
        echo_rx - receive echo from the sensor

Output: trig    - trigger sensor for the sensor
        op     -  output signal to indicate object is present.
        distance_out - distance in mm, if object is present.
*/

/*
# Team ID:          1103
# Theme:            MazeSolver Bot
# Author List:      Goutham R, Harini M, Anshul L, Mohammed Anas
# Filename:         t1b_ultrasonic.v
# File Description: Implements distance measurement using ultrasonic sensor hc sr04
# Global variables: - 
# Local variables : counter, distance_counter, idle, trigger, echo, waite, distance, op_out, state
*/

// module Declaration
module t1b_ultrasonic(
    input clk_50M, reset, echo_rx,
    output reg trig,
    output op,
    output wire [15:0] distance_out
	 
);


initial begin
    trig = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////
//counter 
reg [22:0] counter = 0; // overall counter to ensure triggering happens every 12ms
reg [19:0] distance_counter = 0; // to count the clock cycles when echo is high
localparam idle =2'b00, trigger =2'b01, measure = 2'b10, waite =2'b11;

// idle, trigger, echo, wait are four states
// idle for 1microseconds delay, trigger for trig pin in hcsro4, 
// echo for reading the distance, waite for 12ms delay before next trigger event

reg [1:0] state, next_state; // state register to hold current state
reg [15:0] distance = 0; //  register to store distance 
reg op_out = 1; // register to make output high if distance less than 70mm

assign distance_out = distance;
assign op = op_out;

always @(posedge clk_50M) begin
if (!reset) begin // synchronous active-low reset
        state <= idle;
    end
else begin
		state <= next_state;
		end
end

always @(state) begin
        case (state)
            idle: begin // base condition, where trigger stays for 1us
					 distance_counter = 0;
                trig = 0;
                counter = 0;
                if (counter <=50) 
						  counter = counter + 1;
						  //$display("Counter (idle): %d", counter);
                 else begin 
								next_state = trigger;
								
						  end

            end
            trigger: begin // trigger gets high for 10 us
                if (counter <= 550) begin
						  trig = 1;
						  op_out = 0;
                    counter = counter + 1;
                end else begin
						  op_out = 0;
                    trig = 0;
						  counter = counter + 1;
						  if (echo_rx) begin
								next_state = measure;
								trig = 0;
								distance_counter = 0;
						  end else if ((!echo_rx) && (counter <= 600551))begin // what if echo is not high but counter is running, so go to idle state
						  // 600551 is the total cycles count of 12ms + 1us + 10us
									trig = 0;
									distance = 0;
									counter = counter + 1; 
								end else begin
									counter = 0;
									next_state = idle;
								end
                end
            end
				
            measure: begin // distance counter to count number of cycles echo is high
					 trig = 0;
                if (echo_rx) begin
                    distance_counter = distance_counter + 1;
						  counter = counter + 1;
                end else //if (!echo_rx) 
					 begin
						  distance = ((distance_counter * 17)/5000); // to get distance in 70mm
						  op_out <= ((distance >= 0)&&(distance < 170)) ? 1 : 0;
						  next_state = waite;

						  
                end
            
				end
            waite: begin // rest state till next triggering action
						trig = 0;
						if (counter <= 600551)
								counter = counter + 1;
						else begin
								next_state = idle;
								//$display("Counter (waite): %d", counter);
								counter =0;
								 
								end
				end
            default: begin
                next_state = idle;
                counter = 0;
                trig = 0;
                op_out = 1;
                distance = 0;
					 distance_counter = 0;
            end
        endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
