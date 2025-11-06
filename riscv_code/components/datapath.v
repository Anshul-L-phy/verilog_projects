
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [3:0]   ALUControl,
	 input			jalr,
    output        Zero, less_than, unsigned_less_than,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget, AuiPC, AuiPCResult;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult;
wire [1:0] PCSel;

assign PCSel = {jalr, PCSrc}; // mux select for Jalr/Branch/PC+4

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4); // PC+4
adder          pcoffsetbranch(PC, ImmExt, PCTarget); // PC+ branch offset
mux3 #(32)     pc_mux (PCPlus4, PCTarget, ALUResult, PCSel, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero, less_than, unsigned_less_than);

//result source
adder #(32)    auipcadder ({Instr[31:12], 12'b0}, PC, AuiPC); // PC + imm
mux2 #(32)     auipc_lui_mux (AuiPC, {Instr[31:12], 12'b0}, Instr[5], AuiPCResult); // Select between auipc and lui 
mux4 #(32)     resultmux(ALUResult, ReadData, PCPlus4, AuiPCResult, ResultSrc, Result); // Select between ALUResult, Readdata, PC+4, auipc


assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;
endmodule

