`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:48:40 PM
// Design Name: 
// Module Name: program_counter
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


module program_counter #(parameter mem_size = 32) (
    input clk,
    input reset,
    input PC_write,     // signal to control PC operation 
    input [mem_size-1: 0] jump_mux_out,
    // Output
    output logic [mem_size-1 : 0] PC_out 
    );
    
    //logic [mem_size-1 : 0] Updated_PC = 32'd0;
    
    always_ff @ (posedge clk or negedge reset)
        begin
        if(!reset)
            PC_out <= 32'h00000000;
        
        else if(PC_write == 0)
            PC_out <= PC_out;
             
        else
            PC_out <= jump_mux_out;
        end

endmodule
