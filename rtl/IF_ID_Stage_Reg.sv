`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2024 01:10:23 AM
// Design Name: 
// Module Name: IF_ID_Stage_Reg
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


module IF_ID_Stage_Reg #(parameter size = 32, PC_size = 10) (
    input clk,
    input reset,
    input flush,
    input PHT_conflict,
    input IF_ID_reg_write_en,
    input [size-1 :0] PC_out_IF,
    input [size-1 :0] instruction_out_IF,
    input YAGS_prediction_IF,
    input PHT_prediction_IF,
    input [ PC_size - 1 : 0 ] Taken_Arr_Index_IF,
    input [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_IF,
    input YAGS_conflict,
    input T_NT_Arr_hit_IF,
    input Taken_Arr_prediction_IF,
    input Not_Taken_Arr_prediction_IF,
    input jump_instruction_EX,
    input Taken_Arr_hit_IF,
    input Not_Taken_Arr_hit_IF,
    // outputs
    output logic [size-1 :0] PC_in_ID,
    output logic [size-1 :0] instruction_in_ID,
    output logic YAGS_prediction_ID,
    output logic PHT_prediction_ID,
    output logic [ PC_size - 1 : 0 ] Taken_Arr_Index_ID,
    output logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_ID,
    output logic T_NT_Arr_hit_ID,
    output logic Taken_Arr_prediction_ID,
    output logic Not_Taken_Arr_prediction_ID,
    output logic Taken_Arr_hit_ID,
    output logic Not_Taken_Arr_hit_ID
    );
    
    
    always_ff @(posedge clk or negedge reset ) // or posedge YAGS_conflict or posedge jump_instruction_EX)
    begin
        if(!reset || YAGS_conflict || jump_instruction_EX)	//flush == 1)
            begin
                PC_in_ID <= 32'd0;
                instruction_in_ID <= 32'd0;
                YAGS_prediction_ID <= 1'b0;
                PHT_prediction_ID <= 1'b0;
                Taken_Arr_Index_ID <= 10'd0;
                Not_Taken_Arr_Index_ID <= 10'd0;
                T_NT_Arr_hit_ID <= 1'b0;
                Not_Taken_Arr_prediction_ID <= 1'b0;
                Taken_Arr_prediction_ID <= 1'b0;
                Taken_Arr_hit_ID <= 1'b0;
                Not_Taken_Arr_hit_ID <= 1'b0;           
            end
        
        else if(IF_ID_reg_write_en == 0)
            begin
                PC_in_ID <= PC_out_IF;
                instruction_in_ID <= instruction_in_ID;
                // YAGS_prediction_ID <= YAGS_prediction_ID;
                // PHT_prediction_ID <= PHT_prediction_ID;
            end
        
        else
            begin
                PC_in_ID <= PC_out_IF;
                instruction_in_ID <= instruction_out_IF;
                YAGS_prediction_ID <= YAGS_prediction_IF;
                PHT_prediction_ID <= PHT_prediction_IF;
                Taken_Arr_Index_ID <= Taken_Arr_Index_IF;
                Not_Taken_Arr_Index_ID <= Not_Taken_Arr_Index_IF;
                T_NT_Arr_hit_ID <= T_NT_Arr_hit_IF;
                Taken_Arr_prediction_ID <= Taken_Arr_prediction_IF;
                Not_Taken_Arr_prediction_ID <= Not_Taken_Arr_prediction_IF;
                Taken_Arr_hit_ID <= Taken_Arr_hit_IF;
                Not_Taken_Arr_hit_ID <= Not_Taken_Arr_hit_IF; 
            end
    end
    
endmodule
