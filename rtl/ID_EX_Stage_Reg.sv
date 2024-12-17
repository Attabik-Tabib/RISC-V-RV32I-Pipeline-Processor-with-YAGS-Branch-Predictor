`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2024 02:04:28 AM
// Design Name: 
// Module Name: ID_EX_Satge_Reg
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


module ID_EX_Stage_Reg #(parameter size = 32, PC_size = 10) (
    input clk,
    input reset,
    input flush,
    input PHT_conflict,
    input [size-1 : 0] instruction_ID_in,
    //input [4:0] rs1_ID,
    //input [4:0] rs2_ID,
    input [size-1 : 0] PC_ID_out,
    input [size-1 : 0] data1_ID_out,
    input [size-1 : 0] data2_ID_out,
    input [size-1 : 0] imm_ID_out,
    // input [4 : 0] rd_ID_out,
    input reg_wr_en_ID_out,
    input B_Sel_ID_out,
    input [3:0] ALU_Sel_ID_out,
    input DMemWR_ID_out,
    input [1:0] WB_Sel_ID_out,
    input [1:0] store_size_ID_out,
    input [2:0] load_size_ID_out,
    input jalr_flag_ID_out,
    input jump_flag_ID_out,
    input BrUn_ID_out,
    //input BrLt_ID_in,
    //input BrEq_ID_in,
    input load_hazard_ID,
    input YAGS_prediction_ID,
    input PHT_prediction_ID,
    input [ PC_size - 1 : 0 ] Taken_Arr_Index_ID,
    input [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_ID,
    input YAGS_conflict,
    input T_NT_Arr_hit_ID,
    input Taken_Arr_prediction_ID,
    input Not_Taken_Arr_prediction_ID,
    input jump_instruction_EX,
    input Taken_Arr_hit_ID,
    input Not_Taken_Arr_hit_ID,
    // Outputs
    //output logic [4:0] rs1_EX_in,
    //output logic [4:0] rs2_EX_in,
    output logic [size-1 : 0] PC_EX_in,
    output logic [size-1 : 0] data1_EX_in,
    output logic [size-1 : 0] data2_EX_in,
    output logic [size-1 : 0] imm_EX_in,
    //output logic [4:0] rd_EX_in,
    output logic [size-1 : 0] instruction_EX_in,
    output logic reg_wr_en_EX_in,
    output logic B_Sel_EX_in,
    output logic [3:0] ALU_Sel_EX_in,
    output logic DMemWR_EX_in,
    output logic [1:0] WB_Sel_EX_in,
    output logic [1:0] store_size_EX_in,
    output logic [2:0] load_size_EX_in,
    output logic jalr_flag_EX_in,
    output logic jump_flag_EX_in,
    output logic BrUn_EX_in,
    output logic load_hazard_EX,
    output logic YAGS_prediction_EX,
    output logic PHT_prediction_EX,
    output logic [ PC_size - 1 : 0 ] Taken_Arr_Index_EX,
    output logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_EX,
    output logic T_NT_Arr_hit_EX,
    output logic Taken_Arr_prediction_EX,
    output logic NOT_Taken_Arr_prediction_EX,
    output logic Taken_Arr_hit_EX,
    output logic Not_Taken_Arr_hit_EX
    //output logic BrLt_EX_out,
    //output logic BrEq_EX_out   
    );
    
    always_ff @(posedge clk or negedge reset) // or posedge jump_instruction_EX or posedge YAGS_conflict)
        begin
            if( !reset || YAGS_conflict || jump_instruction_EX)
                begin
                    //rs1_EX_in <= 5'b0;
                    //rs2_EX_in <= 5'b0;
                    PC_EX_in <= 32'd0;
                    data1_EX_in <= 32'd0;
                    data2_EX_in <= 32'd0;
                    imm_EX_in <= 32'd0;
                    instruction_EX_in <= 32'd0;
                    reg_wr_en_EX_in <= 1'b0;
                    B_Sel_EX_in <= 1'b0;
                    ALU_Sel_EX_in <= 4'd0;
                    DMemWR_EX_in <= 1'b0;
                    WB_Sel_EX_in <= 2'd0;
                    store_size_EX_in <= 2'd0;
                    load_size_EX_in <= 3'd0;
                    jalr_flag_EX_in <= 1'b0;
                    jump_flag_EX_in <= 1'b0;
                    BrUn_EX_in <= 1'b0;
                    load_hazard_EX <= 1'b0;
                    YAGS_prediction_EX <= 1'b0;
                    PHT_prediction_EX <= 1'b0;
                    Taken_Arr_Index_EX <= 'h0;
                    Not_Taken_Arr_Index_EX <= 'h0;
                    //BrLt_EX_out <= 1'b0;
                    //BrEq_EX_out <= 1'b0;
                    T_NT_Arr_hit_EX <= 1'b0;
                    Taken_Arr_prediction_EX <= 1'b0;
                    NOT_Taken_Arr_prediction_EX <= 1'b0;
                    Taken_Arr_hit_EX <= 1'b0;
                    Not_Taken_Arr_hit_EX <= 1'b0;
                end
            else
                begin
                    //rs1_EX_in <= rs1_ID;
                    //rs2_EX_in <= rs2_ID;
                    PC_EX_in <= PC_ID_out;
                    data1_EX_in <= data1_ID_out;
                    data2_EX_in <= data2_ID_out;
                    imm_EX_in <= imm_ID_out;
                    instruction_EX_in <= instruction_ID_in;
                    reg_wr_en_EX_in <= reg_wr_en_ID_out;
                    B_Sel_EX_in <= B_Sel_ID_out;
                    ALU_Sel_EX_in <= ALU_Sel_ID_out;
                    DMemWR_EX_in <= DMemWR_ID_out;
                    WB_Sel_EX_in <= WB_Sel_ID_out;
                    store_size_EX_in <= store_size_ID_out;
                    load_size_EX_in <= load_size_ID_out;
                    jalr_flag_EX_in <= jalr_flag_ID_out;
                    jump_flag_EX_in <= jump_flag_ID_out;
                    BrUn_EX_in <= BrUn_ID_out;
                    load_hazard_EX <= load_hazard_ID;
                    YAGS_prediction_EX <= YAGS_prediction_ID; 
                    PHT_prediction_EX <= PHT_prediction_ID;
                    Taken_Arr_Index_EX <= Taken_Arr_Index_ID;
                    Not_Taken_Arr_Index_EX <= Not_Taken_Arr_Index_ID;
                    T_NT_Arr_hit_EX <= T_NT_Arr_hit_ID;
                    Taken_Arr_prediction_EX <= Taken_Arr_prediction_ID;
                    NOT_Taken_Arr_prediction_EX <= Not_Taken_Arr_prediction_ID;
                    Taken_Arr_hit_EX <= Taken_Arr_hit_ID;
                    Not_Taken_Arr_hit_EX <= Not_Taken_Arr_hit_ID;
                    //BrLt_EX_out <= BrLt_ID_in;
                    //BrEq_EX_out <= BrEq_ID_in;               
                end
        end
endmodule
