`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:47:24 PM
// Design Name: 
// Module Name: alu_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_logic #(parameter ALU_bits = 32)(
    input [ALU_bits - 1 : 0] op1,
    input [ALU_bits - 1 : 0] op2,
    input [3:0] ALU_Select,
    output logic [ALU_bits - 1:0] ALU_out
    );
    
    //logic [31:0] temp, temp_op2;
    
    always_comb
        begin
            case(ALU_Select)    // {function7[6], func3}
                4'b0000: ALU_out = op1 + op2;                           // Add R-type, Add-Immediate
                4'b1000: ALU_out = op1 - op2;                           // subtract
                4'b0001: ALU_out = op1 << op2[4:0];                     // sll R-type and I-type
                4'b0010: ALU_out = $signed(op1) < $signed(op2);         // slt for R and I-type
                4'b0011: ALU_out = $unsigned(op1) < $unsigned(op2);     // slt for R and I-type
                4'b0100: ALU_out = op1 ^ op2;                           // XOR for both R and I-type 
                4'b0101: ALU_out = op1 >> op2[4:0];                     // srl and srli
                4'b1101: ALU_out = $signed(op1) >>> op2[4:0];           // sra and srai
                4'b0110: ALU_out = op1 | op2;                           // or and ori
                4'b0111: ALU_out = op1 & op2;                           // and and andi
                4'b1111: ALU_out = op2;                                 // implementing lui instruction
                
            endcase
        end
endmodule

