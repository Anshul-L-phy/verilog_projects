
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero,                   // zero flag
	 output      less_than,              // less than flag
	 output      unsigned_less_than      // less than (unsigned) flag
);

always @(a, b, alu_ctrl) begin
		alu_out = 0;
    case (alu_ctrl)
        4'b0000:  alu_out <= a + b;       // ADD, ADDI
        4'b0001:  alu_out <= a - b;       // SUB
        4'b0010:  alu_out <= a & b;       // AND, ANDI
        4'b0011:  alu_out <= a | b;       // OR, ORI
		  4'b0100:  alu_out <= a ^ b;       // XOR
        4'b0101:  begin                   // SLT, SLTI
                     alu_out = ($signed(a) < $signed(b)) ? {{(WIDTH-1){1'b0}},1'b1} : {WIDTH{1'b0}};
                 end
        4'b0110:  alu_out <= a << b;      // SLL, SLLI
		  4'b0111:  alu_out <= a >> b;      // SRL, SRLI
		  4'b1000:  alu_out <= $signed(a) >>> b[4:0]; // SRL, SRLI
		  
		  4'b1101: begin                    // SLTU, SLTIU
                     alu_out = (a < b) ? {{(WIDTH-1){1'b0}},1'b1} : {WIDTH{1'b0}};
                 end 
   	  

		  default: alu_out = 0;
    endcase
end

assign zero               = ~(|alu_out);                // ZERO flag
assign less_than          = ($signed(a) < $signed(b));  // signed comparison
assign unsigned_less_than = (a < b);                    // unsigned comparison

endmodule

