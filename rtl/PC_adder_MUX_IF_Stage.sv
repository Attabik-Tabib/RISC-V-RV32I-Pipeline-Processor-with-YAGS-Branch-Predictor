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

/*
module PC_adder_IF_Stage #(parameter size = 32) (
    input [size - 1: 0] PC_out,
    input YAGS_prediction,
    input [1:0] branch_comp_MUX_out_EX;
    input [size - 1: 0] imm_YAGS,
    output logic [size - 1: 0] adder_PC_out 
    );
    
    always_comb
        begin
        	if(YAGS_prediction)
            		adder_PC_out = PC_out + imm_YAGS;
    		else
    			adder_PC_out = branch_comp_MUX_out_EX;
        end
endmodule
*/
module PC_adder_MUX_IF_Stage #(parameter size = 32) (
    input jump_flag_EX_in,
    input [1:0] PC_adder_mux_select,
    input [size - 1  : 0] PC_out,			// Current PC
    input [size - 1 : 0] ALU_out,			// ALU used for operations
    input [size - 1 : 0] PC_plus_offset_from_EX,	// in case of NT/T conflict
    input [size - 1  : 0] PC_EX,			// in case of T/NT conflict
    // outputs
    output logic [size - 1 : 0] PC_adder_mux_out		// output
    );
    
    
    always_comb
        begin
            if(PC_adder_mux_select == 2'b00)
                PC_adder_mux_out = PC_out + 4;
                
            else if (PC_adder_mux_select == 2'b01)
                PC_adder_mux_out = PC_plus_offset_from_EX;
                
            else if (PC_adder_mux_select == 2'b10 && jump_flag_EX_in)
                PC_adder_mux_out = ALU_out;
		        
            else if (PC_adder_mux_select == 2'b11)
                PC_adder_mux_out = PC_EX + 4;
		        	
            else
                PC_adder_mux_out = 32'd0;
        end
endmodule
