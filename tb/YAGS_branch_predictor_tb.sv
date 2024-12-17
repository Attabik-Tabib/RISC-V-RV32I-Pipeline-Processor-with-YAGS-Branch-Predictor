`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2024 11:56:42 PM
// Design Name: 
// Module Name: test_bench
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


module YAGS_branch_predictor_tb();
logic clk;
logic reset;
//logic out;

top t(
    .clk(clk),
    .reset(reset)
    //.out(out)     
    );
    
    initial
	    begin
		clk = 1'b0;
		forever #5 clk = ~ clk;
	    end
    
    initial 
	begin
	    reset = 1'b0;
	    #4 reset = 1'b1;
	    #1000000;
	    $stop();
	end

endmodule
