module t2a_dht(
    input clk_50M,
    input reset,
    inout sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal,
    output reg [7:0] Checksum,
    output reg data_valid
);

    initial begin
        T_integral = 0;
        RH_integral = 0;
        T_decimal = 0;
        RH_decimal = 0;
        Checksum = 0;
        data_valid = 0;
    end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

localparam idle = 3'b000, wait_low = 3'b001, wait_high = 3'b010, read_low = 3'b011, read_high = 3'b100,update = 3'b101,check = 3'b110,stop = 3'b111;
reg[3:0] state;
reg[5:0] bit_counter;
reg[39:0] data;
reg[7:0] sum;
reg[12:0]counter; 
reg prev;
wire sensor_in = sensor;
wire sensor_fall = prev & ~sensor_in; 
wire sensor_rise = ~prev & sensor_in;


always @(posedge clk_50M or negedge reset) begin
	if (!reset) begin
		prev <=1; 
      state <= idle;
		counter <= 0;
		bit_counter <= 39;
		data_valid <= 0;
		T_integral <= 0; RH_integral <= 0;
		T_decimal <= 0; RH_decimal <= 0;
		Checksum <= 0;
		data <= 0;
		sum <= 0;

	end else begin
		prev <= sensor_in;
		if(state != update)
			data_valid <= 0;
		
		if (sensor_fall || sensor_rise) 
			counter <= 0;
      else if (state == wait_low || state == wait_high || state == read_low || state == read_high) 
			counter <= counter + 1;
		else 
			counter <= 0;
	
	
	case(state)
		idle : begin
			if (sensor_fall) begin
				state <= wait_low;
				bit_counter <= 39;
				data <= 0;
				
			end
		end
		
		wait_low : begin
			if(sensor_rise) 
				state <= wait_high;
		end
		
		wait_high : begin
			if(sensor_fall) 
				state <= read_low;
		end
		
		read_low: begin
			if(sensor_rise) 
				state <= read_high;
		
		end
		
		read_high : begin
			if(sensor_fall) begin 
				if (counter > 2400) 
					data[bit_counter] <= 1;
				else
					data[bit_counter] <= 0;
				if (bit_counter == 0)
					state <= update;
				else begin
					state <= read_low;
					bit_counter <= bit_counter - 1;
				end
				
			end else if (bit_counter == 0 && counter > 4000) begin  
					if(counter > 2400)
						data[bit_counter] <= 1;
					else
						data[bit_counter] <= 0;
					state <= update;
			end
		end

		
		update : begin
			RH_integral <= data[39:32];
			RH_decimal <= data[31:24];
			T_integral <= data[23:16];
			T_decimal <= data[15:8];
			Checksum <= data[7:0];
			
			sum <= (data[39:32]+data[31:24]+data[23:16]+data[15:8]);
			state <= check;
		end
		
		check : begin
			
			if (Checksum== sum) 
				data_valid <= 1;
			else 
				data_valid <= 0;
			state <= stop;
		end
		
		stop : begin
			state <= idle;
      end
                
      default: begin
         state <= idle;
      end
	endcase
	end
end
				
		
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////
  
endmodule
