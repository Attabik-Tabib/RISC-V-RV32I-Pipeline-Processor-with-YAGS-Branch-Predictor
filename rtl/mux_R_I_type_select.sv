`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 06:44:31 PM
// Design Name: 
// Module Name: mux_immediate_select
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


module mux_R_I_type_select #(parameter size = 32) (
    input B_Sel,
    input [size - 1 : 0] data2,
    input [size - 1 : 0] imm,
    // Output
    output logic [size - 1 : 0] mux_IR_out
    );
    
    //assign imm_out = {{20{imm[11]}},imm};
    
    always_comb
        begin
            if(B_Sel == 1'b0)
                mux_IR_out = data2;
            else
                mux_IR_out = imm;
         end
         
endmodule