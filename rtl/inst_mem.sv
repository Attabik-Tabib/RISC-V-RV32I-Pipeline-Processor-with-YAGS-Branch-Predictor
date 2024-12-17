`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:48:15 PM
// Design Name: 
// Module Name: inst_mem
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


module inst_mem #(parameter ins_size = 32) (
    input [ins_size-1 : 0] PC_in,
    // Output
    output logic [ins_size - 1 : 0] instruction,
    output logic branch_check,
    output logic [ins_size - 1 : 0 ]imm_YAGS
    );
    
   logic [31:0] instruction_memory [0 : (2**20)-1];
   logic [31:0] PC_temp;
   assign PC_temp = PC_in - 32'h00000000;
   
   logic [12:0] imm_temp_YAGS;
   logic [6:0] opcode;
   
   assign opcode = instruction[6:0];
  initial 
	begin
        	$readmemh("instruction_memory.mem", instruction_memory);   // For HEX File 
	end
/*initial begin
        instruction_memory[0] = 32'h00000313;      
        instruction_memory[1] = 32'h00628263;
        instruction_memory[2] = 32'd3;
        instruction_memory[3] = 32'd4;
        instruction_memory[4] = 32'd5;
        instruction_memory[5] = 32'd6;
    end
*/    
       
    always_comb
        begin
            instruction = instruction_memory [PC_temp[ins_size-1 : 2]];
            if(opcode == 99)
            	begin
            		branch_check = 1;
            	end	
            else
                begin
                    branch_check = 0;
                end
	    	
	    	
    	    imm_temp_YAGS = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            imm_YAGS = {{19{imm_temp_YAGS[12]}},imm_temp_YAGS};
            
        end
        
endmodule
