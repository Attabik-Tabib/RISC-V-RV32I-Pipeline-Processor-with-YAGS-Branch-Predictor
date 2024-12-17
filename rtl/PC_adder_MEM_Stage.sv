`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 12:55:46 AM
// Design Name: 
// Module Name: PC_adder
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


module PC_adder_MEM_Stage #(parameter size = 32) (
    input [size - 1: 0] PC_out,
    output logic [size - 1: 0] adder_PC_out 
    );
    
    always_comb
        begin
            adder_PC_out = PC_out[31:0] + 4;
        end
endmodule
