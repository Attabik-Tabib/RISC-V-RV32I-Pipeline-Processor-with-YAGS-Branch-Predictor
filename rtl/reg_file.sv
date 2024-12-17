`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:46:46 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file #(parameter reg_size = 32, width = 32, depth = 32) (
    input clk,
    input reg_wr_en,
    input [4:0] rs1, rs2, rd,
    input [reg_size - 1 : 0] dataW_reg_file,
    output logic [reg_size - 1 : 0] data1, data2
    );
    
    
    logic [width - 1 :0] registers [0 : depth - 1];
 /*   
    initial 
        $readmemh("register_file.mem", registers);   // For Binary File 
*/
    initial 
        begin
                registers[0] = 32'b0;
        end

    always_comb
        begin
            data1 =  registers[rs1];
            data2 =  registers[rs2];
        end
    
    //assign registers[0] = 0;

    always_ff @(negedge clk)
        begin
            if(reg_wr_en == 1'b1 && rd != 5'd0)
                  registers[rd] <= dataW_reg_file;
            else
                begin
                  registers[rd] <= registers[rd];
                end  
        end
    
endmodule

