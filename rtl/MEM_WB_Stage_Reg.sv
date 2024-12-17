`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2024 05:19:32 AM
// Design Name: 
// Module Name: MEM_WB_Stage_Reg
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


module MEM_WB_Stage_Reg #(parameter size = 32) (
    input clk,
    input reset,
    input [size-1:0] PC_MEM_in,
    input [size-1 : 0] PC_adder_out_MEM,
    input [size-1 : 0] ALU_out_MEM_in,
    input [size-1 : 0] DMEM_out_MEM,
    input [size-1 : 0] data1_MEM_in,
    input [size-1 : 0] data2_MEM_in,
    //input [4:0] rd_MEM_in,
    input [size-1:0] instruction_MEM_in,
    input reg_wr_en_MEM_in,
    input [1:0] WB_Sel_MEM_in,
    
    // outputs
    output logic [size-1:0] PC_WB_in,
    output logic  [size-1 : 0] PC_adder_out_WB_in,
    output logic [size-1 : 0] ALU_out_WB_in,
    output logic  [size-1 : 0] DMEM_out_WB_in,
    output logic [size-1 : 0] data1_WB_in,
    output logic [size-1 : 0] data2_WB_in,
    //output logic [4:0] rd_WB_in,
    output logic [size-1:0] instruction_WB_in,
    output logic reg_wr_en_WB_in,
    output logic [1:0] WB_Sel_WB_in
    );
    
     always_ff @(posedge clk or negedge reset)
    begin
        if(!reset)
            begin
                PC_WB_in <= 32'd0;
                PC_adder_out_WB_in <= 32'd0;
                ALU_out_WB_in <= 32'd0;
                DMEM_out_WB_in <= 32'd0;
                data1_WB_in <= 32'd0;
                data2_WB_in <= 32'd0;
                //rd_WB_in <= 5'd0;
                instruction_WB_in <= 32'd0;
                reg_wr_en_WB_in <= 1'b0;
                WB_Sel_WB_in <= 2'd0;        
            end
        else
            begin
                PC_WB_in <= PC_MEM_in;
                PC_adder_out_WB_in <= PC_adder_out_MEM;
                ALU_out_WB_in <= ALU_out_MEM_in;
                DMEM_out_WB_in <= DMEM_out_MEM;
                data1_WB_in <= data1_MEM_in;
                data2_WB_in <= data2_MEM_in;
                //rd_WB_in <= rd_MEM_in;
                instruction_WB_in <= instruction_MEM_in;
                reg_wr_en_WB_in <= reg_wr_en_MEM_in;
                WB_Sel_WB_in <= WB_Sel_MEM_in;      
            end
    end
endmodule
