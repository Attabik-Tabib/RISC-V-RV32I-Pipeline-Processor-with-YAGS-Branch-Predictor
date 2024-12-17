`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2024 03:49:50 AM
// Design Name: 
// Module Name: EX_MEM_Stage_Reg
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


module EX_MEM_Stage_Reg #(parameter size = 32) (
    input clk,
    input reset,
    input [size-1 : 0] PC_EX_in,
    input [size-1 : 0] ALU_out_EX,
    input [size-1 : 0] data2_EX_in_stored_hazard_mux,
    input [size-1 : 0] data1_EX_in,
    input [size-1 : 0] data2_EX_in,
    //input [size-1 : 0] imm_EX_in,
    input reg_wr_en_EX_in,
    //input [4:0] rd_EX_in,
    input [size-1 : 0] instruction_EX_in,
    input DMemWR_EX_in,
    input [1:0] WB_Sel_EX_in,
    input [1:0] store_size_EX_in,
    input [2:0] load_size_EX_in,
    //input jump_flag_EX_in,
    
    // Outputs
    output logic [size-1 : 0] PC_MEM_in,
    output logic [size-1 : 0] ALU_out_MEM_in,
    output logic [size-1:0] data2_EX_out_stored_hazard_mux,
    output logic [size-1 : 0] data1_MEM_in,
    output logic [size-1 : 0] data2_MEM_in,
    //output logic [4 : 0] rd_MEM_in,
    output logic [size-1:0] instruction_MEM_in,
    output logic DMemWR_MEM_in,
    output logic reg_wr_en_MEM_in,
    output logic [1 : 0] WB_Sel_MEM_in,
    output logic [1:0] store_size_MEM_in,
    output logic [2:0] load_size_MEM_in
    //output logic jump_flag_MEM_in
    );
    
    always_ff @(posedge clk or negedge reset)
    begin
        if(!reset)
            begin
                PC_MEM_in <= 32'd0;
                ALU_out_MEM_in <= 32'd0;
                data2_EX_out_stored_hazard_mux <= 32'd0;
                data1_MEM_in <=32'd0;
                data2_MEM_in <= 32'd0;
                //rd_MEM_in <= 5'd0;
                instruction_MEM_in <= 32'd0;
                DMemWR_MEM_in <=1'b0;
                reg_wr_en_MEM_in <= 1'b0;
                WB_Sel_MEM_in <= 2'd0;
                store_size_MEM_in <= 2'd0;
                load_size_MEM_in <= 3'd0;
                //jump_flag_MEM_in <= 1'b0;
            end
        else
            begin
                PC_MEM_in <= PC_EX_in;
                ALU_out_MEM_in <= ALU_out_EX;
                data2_EX_out_stored_hazard_mux <= data2_EX_in_stored_hazard_mux;
                data1_MEM_in <= data1_EX_in;
                data2_MEM_in <= data2_EX_in;
                //rd_MEM_in <= rd_EX_in;
                instruction_MEM_in <= instruction_EX_in;
                DMemWR_MEM_in <= DMemWR_EX_in;
                reg_wr_en_MEM_in <= reg_wr_en_EX_in;
                WB_Sel_MEM_in <= WB_Sel_EX_in;
                store_size_MEM_in <= store_size_EX_in;
                load_size_MEM_in <= load_size_EX_in;
                //jump_flag_MEM_in <= jump_flag_EX_in;
            end
    end
    
endmodule
