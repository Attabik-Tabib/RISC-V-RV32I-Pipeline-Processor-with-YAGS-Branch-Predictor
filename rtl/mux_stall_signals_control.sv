`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 04:40:28 AM
// Design Name: 
// Module Name: mux_stall_signals_control
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


module mux_stall_signals_control #(parameter size = 32) (
    input stall_mux_Sel,
    
    input reg_wr_en,                     // register write enable
//    input BSel,                          // immediate select fot BSel = 1
    input DMemWR,                        // Read/Write enable fr data memeory 1 to write, 0 to read
//    input jalr_flag,                     // jalr instrcution flag
//    input jump_flag,                     //  jal flag
//    input BrUn,                          // unsigned branch flag
//    input [1:0] WB_Sel,                  // slect between ALU result and data mmeory result. 1 for ALU, 0 for data meomory
//    input [1:0] store_size,              // defining size of data to be stored in case of store instruction
//    input [2:0] load_size,               // defining size of data to be loaded in case of store instruction    
//    input [3:0] ALU_Sel,                  // ALU operation select based upon func3 bits and bit 6 of funct7
    //input [1:0] read_write_disable
    
    //Outputs
    output logic stall_reg_wr_en,
//    output logic stall_BSel,
    output logic stall_DMemWR
//    output logic stall_jalr_flag,
//    output logic stall_jump_flag,
//    output logic stall_BrUn,
//    output logic [1:0] stall_WB_Sel,
//    output logic [1:0] stall_store_size,
//    output logic [2:0] stall_load_size,
//    output logic [3:0] stall_ALU_Sel
    );
    
    always_comb
        begin
            if(stall_mux_Sel == 1)
                begin
                    stall_reg_wr_en = 0;
//                    stall_BSel = BSel;
                    stall_DMemWR = 0;
//                    stall_jalr_flag = jalr_flag;
//                    stall_jump_flag = jump_flag;
//                    stall_BrUn = BrUn;
//                    stall_WB_Sel = WB_Sel;
//                    stall_store_size = store_size;
//                    stall_load_size = load_size;
//                    stall_ALU_Sel = ALU_Sel;                
                    end
            else
                begin
                    stall_reg_wr_en = reg_wr_en;
//                    stall_BSel = BSel;
                    stall_DMemWR = DMemWR;
//                    stall_jalr_flag = jalr_flag;
//                    stall_jump_flag = jump_flag;
//                    stall_BrUn = BrUn;
//                    stall_WB_Sel = WB_Sel;
//                    stall_store_size = store_size;
//                    stall_load_size = load_size;
//                    stall_ALU_Sel = ALU_Sel;
                end
        end
endmodule
