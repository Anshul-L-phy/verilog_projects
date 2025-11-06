
// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
	 input [2:0] funct3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output      [DATA_WIDTH-1:0] rd_data_mem
);

wire [ADDR_WIDTH-1:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;
// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];


// combinational read logic
// word-aligned memory access
//assign rd_data_mem = data_ram[wr_addr[DATA_WIDTH-1:2] % 64];

// synchronous write logic
always @(posedge clk) begin
    if (wr_en) begin
		case(funct3)
			3'b000: begin //sb
				case(wr_addr[1:0])
					2'b00: data_ram[word_addr][ 7: 0] = wr_data[7:0];
					2'b01: data_ram[word_addr][15: 8] = wr_data[7:0];
					2'b10: data_ram[word_addr][23:16] = wr_data[7:0];
					2'b11: data_ram[word_addr][31:24] = wr_data[7:0];
				endcase
			end
			3'b001: begin //sh
				case(wr_addr[0])
					1'b0: data_ram[word_addr][15:  0] = wr_data[15:0];
					1'b1: data_ram[word_addr][31: 15] = wr_data[15:0];
				endcase
			end
			3'b010: data_ram[word_addr] <= wr_data; //sw
			default:data_ram[word_addr] <= 32'b0;   // default
		endcase		
	 end
end

// combinational read logic
assign rd_data_mem = 
    (funct3 == 3'b000) ? // lb
        (wr_addr[1:0] == 2'b00) ? {{24{data_ram[word_addr][ 7]}}, data_ram[word_addr][ 7: 0]} :
        (wr_addr[1:0] == 2'b01) ? {{24{data_ram[word_addr][15]}}, data_ram[word_addr][15: 8]} :
        (wr_addr[1:0] == 2'b10) ? {{24{data_ram[word_addr][23]}}, data_ram[word_addr][23:16]} :
                                   {{24{data_ram[word_addr][31]}}, data_ram[word_addr][31:24]} :
    (funct3 == 3'b001) ? // lh
        (wr_addr[0] == 1'b0) ? {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]} :
                                {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]} :
    (funct3 == 3'b010) ? data_ram[word_addr] : // lw
    (funct3 == 3'b100) ? // lbu
        (wr_addr[1:0] == 2'b00) ? {24'b0, data_ram[word_addr][ 7:0]} :
        (wr_addr[1:0] == 2'b01) ? {24'b0, data_ram[word_addr][15:8]} :
        (wr_addr[1:0] == 2'b10) ? {24'b0, data_ram[word_addr][23:16]} :
                                   {24'b0, data_ram[word_addr][31:24]} :
    (funct3 == 3'b101) ? // lhu
        (wr_addr[0] == 1'b0) ? {16'b0, data_ram[word_addr][15:0]} :
                                {16'b0, data_ram[word_addr][31:16]} :
    32'b0;

endmodule

