`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2024 04:31:02 AM
// Design Name: 
// Module Name: mux_forward_A
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


module mux_forward_A #(parameter size =32) (
    input [size-1 : 0] input1,
    input [size-1 : 0] input2,
    input [size-1 : 0] input3,
    input [1:0] mux_sel_forwars_A,
    output logic [size-1 : 0] mux_out_A
    );
    
    always_comb
        begin
            case(mux_sel_forwars_A)
                    2'b00: mux_out_A = input1;
                    2'b01: mux_out_A = input2;
                    2'b10: mux_out_A = input3;
                    default: mux_out_A = input1;
            endcase
        end
endmodule
