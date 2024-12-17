`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 02:06:26 AM
// Design Name: 
// Module Name: mux_RAW_ID_rs2
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


module mux_RAW_ID_rs2 #(parameter size = 32) (
    input [size-1: 0] reg_out_data2,
    input [size-1: 0] WB_out_data2,
    input mux_Sel_RAW_ID_rs2,
    output logic [size-1:0] mux_RAW_ID_data2_out
    );
    
    always_comb
        begin
            if(mux_Sel_RAW_ID_rs2 == 1'b0)                  // control signal 1 for hazard
                mux_RAW_ID_data2_out = reg_out_data2;
            else
                mux_RAW_ID_data2_out = WB_out_data2;
        end
endmodule
