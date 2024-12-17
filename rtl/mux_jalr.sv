`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 01:10:23 AM
// Design Name: 
// Module Name: mux_jalr
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


module mux_jalr #(parameter size = 32) (
    input jalr_flag,
    input [size -1: 0] PC_out,
    input [size -1: 0] data1,
    output logic [size -1: 0] mux_jalr_out
    );
    
    always_comb
        begin
            if(jalr_flag)
                mux_jalr_out = PC_out;
            else
                mux_jalr_out = data1;        
        end
endmodule
