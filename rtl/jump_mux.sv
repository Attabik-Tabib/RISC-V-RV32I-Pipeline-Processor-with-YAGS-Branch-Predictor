`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 12:54:41 AM
// Design Name: 
// Module Name: jump_mux
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

module jump_mux #(parameter size = 32) (
    input [size - 1: 0] PC_out,
    input YAGS_prediction,
    input [size - 1 : 0] branch_comp_MUX_out_EX,
    input [size - 1: 0] imm_YAGS,
    input PHT_prediction,
    // Output
    output logic [size - 1: 0] jump_mux_out 
    );
    
    always_comb
        begin
        	if(YAGS_prediction)				// Here we need YAGS_Prediction
            		jump_mux_out = PC_out + imm_YAGS;
    		else
    			jump_mux_out = branch_comp_MUX_out_EX;
        end
endmodule
/*
module jump_mux #(parameter size = 32) (
    input jump_flag,
    input branch_jump_flag,
    input [size - 1  : 0] PC_adder_out,
    input [size - 1 : 0] ALU_out,		// ALU used for operations
    output logic [size - 1 : 0] jump_mux_out	// 
    );
    
    always_comb
        begin
            if(branch_jump_flag==1'b1 || jump_flag == 1'b1)
                jump_mux_out = ALU_out;
            else
                jump_mux_out = PC_adder_out;
        end
endmodule
*/
