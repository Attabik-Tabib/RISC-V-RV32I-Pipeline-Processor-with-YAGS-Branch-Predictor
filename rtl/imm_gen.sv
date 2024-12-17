`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:47:04 PM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen #(parameter size = 32) (
    input [size - 1: 0] instruction_in,
    // Output
    output logic [size - 1: 0]imm_out 
    );
    
    logic [6:0] opcode;
    assign opcode = instruction_in [6:0];
    logic [11:0] imm_I_temp;
    logic [11:0] imm_S_temp;
    logic [12:0] imm_B_temp;
    logic [19:0] imm_U_temp;
    logic [20:0] imm_J_temp;  
    //logic [4:0]temp;
    always_comb
    begin
         if(opcode == 19 || opcode == 3 || opcode == 103)            // generating immediate value for I-type (Immediate, Load, Jalr)
             begin
                imm_I_temp = instruction_in[31:20];
                imm_out = {{20{imm_I_temp[11]}},imm_I_temp};
                //temp <=1;
             end
         
         else if(opcode == 35)      // generating immediate value for S-type
             begin
                imm_S_temp = {instruction_in[31:25],instruction_in[11:7]};
                imm_out = {{20{imm_S_temp[11]}},imm_S_temp};
             //temp <=2;
             end
             
         else if(opcode == 99)      // generating immediate value for B-type
             begin
                imm_B_temp = {instruction_in[31],instruction_in[7],instruction_in[30:25],instruction_in[11:8],1'b0};
                imm_out = {{19{imm_B_temp[12]}},imm_B_temp};
             //temp <=3;
             end
             
         else if(opcode == 55 || opcode == 23)                  // generating immediate value for U-type
             begin
                imm_out = {(instruction_in[31:12]),12'd0};    // Upper 29 bits contain the immediate value
               // temp <=4;
             end
             
          else if(opcode == 111)      // generating immediate value for J-type
             begin
                imm_J_temp = {instruction_in[31],instruction_in[19:12],instruction_in[20],instruction_in[30:21],1'b0};
                imm_out = {{11{imm_J_temp[20]}},imm_J_temp};    // 21-bit immediate value
             //temp <=5;
             end
             
         else
            imm_out = 32'd0;
             //temp <=6;
             
    end
   
    
endmodule
