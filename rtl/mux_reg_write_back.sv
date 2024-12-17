`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 10:21:04 PM
// Design Name: 
// Module Name: mux_reg_write_back
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


module mux_reg_write_back #(parameter size =32) (
    input [size-1 : 0] PC_adder_out,
    input [size-1 : 0] ALU_out,
    input [size-1 : 0] DMem_out,
    input [1:0] WB_Sel,
    output logic [size-1 : 0] MUX_WB_OUT 
    );
    
    always_comb
        begin
           casex(WB_Sel)
                2'b00: MUX_WB_OUT = DMem_out;
                2'b01: MUX_WB_OUT = ALU_out;
                2'b10: MUX_WB_OUT = PC_adder_out;
                default: MUX_WB_OUT = 32'dx;
            endcase     
        end
endmodule
