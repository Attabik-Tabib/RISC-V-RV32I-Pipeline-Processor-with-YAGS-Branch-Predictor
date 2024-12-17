`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2024 10:51:27 PM
// Design Name: 
// Module Name: store_data_hazard_mux
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


module store_data_hazard_mux #(parameter size = 32) (
    input [1:0] store_data_hazard_mux_Sel,
    input [size-1 : 0] input1,
    input [size-1 : 0] input2,
    input [size-1 : 0] input3,
    output logic [size-1 : 0] store_data_hazard_mux_out
    );
    
    always_comb
        begin
            case(store_data_hazard_mux_Sel)
                    2'b00: store_data_hazard_mux_out = input1;
                    2'b01: store_data_hazard_mux_out = input2;
                    2'b10: store_data_hazard_mux_out = input3;
                    default: store_data_hazard_mux_out = input1;
            endcase
        end
endmodule
