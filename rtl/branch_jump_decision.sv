`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 12:08:25 AM
// Design Name: 
// Module Name: branch_jump_decision
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


module branch_jump_decision #(parameter size = 32) ( 
    input jump_flag_EX_in,
    input [size - 1 : 0] instruction_EX_in,
    input BrEq,                                 // beq branch flag
    input BrLt,                                 // blt branch flag  
    // Outputs
    output logic branch_signal,
    output logic branch_jump_flag,                     //  jal flag
    output logic jump_instruction_EX,
    output logic flush
    );
     
     
         always_comb
         begin
        // branch_signal = 0;
             // Branch intructions check based on opcode and func3
             if(instruction_EX_in[6:0] == 99)               // B-type instructions opcode
                    begin
                    	branch_signal = 1;
                        case(instruction_EX_in[14:12])       // Checking funct3 bits for branch condition   
                            
                            3'b100: 
                                begin
                                
                                   if(BrLt == 1'b1 && BrEq == 1'b0)            // blt (signed)
                                       begin
                                            //$display("Num1 < Num2 (signed))");
                                            branch_jump_flag = 1'b1;
                                            flush = 1'b1;
                                       end
                                   else
                                       begin 
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                       end
                                end
                                
                            3'b101: 
                                begin
                                   
                                    if(BrLt == 1'b0 || BrEq == 1'b0)            // bge (signed)
                                        begin
                                            //$display("Num1 > Num2 (signed))");
                                            branch_jump_flag = 1'b1;
                                            flush = 1'b1;
                                        end
                                    else
                                        begin 
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                        end
                                end
                            
                            3'b110: 
                                begin
    
                                    if(BrLt == 1'b1 && BrEq == 1'b0)            // bltu (unsigned)
                                        begin
                                            //$display("Num1 < Num2 (unsigned))");
                                            branch_jump_flag = 1'b1;
                                            flush = 1'b1;
                                        end
                                    else
                                        begin 
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                        end
                                    
                                end
                            
                            3'b111: 
                                begin

                                    if(BrLt == 1'b0 && BrEq == 1'b0)            // bgeu (unsigned)
                                        begin
                                            //$display("Num1 >= Num2 (unsigned))");
                                            branch_jump_flag = 1'b1;
                                            flush = 1'b1;
                                        end
                                    else
                                        begin 
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                        end
                                end
                            
                            3'b000:
                                begin
                                    if(BrEq == 1'b1)    // beq
                                        begin
                                            //$display("Num1 = Num2 ");
                                            flush = 1'b1;
                                            branch_jump_flag = 1'b1;
                                           
                                        end
                                    else
                                        begin
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                        end
                                        
                                end 
                            
                             3'b001:
                                 begin
                                    if(BrEq == 1'b0)   // bne check
                                        begin
                                            //$display("Num1 != Num2 ");
                                            branch_jump_flag = 1'b1;
                                            flush = 1'b1;
                                        end
                                    else 
                                        begin
                                            branch_jump_flag = 1'b0;
                                            flush = 1'b0;
                                        end
                                end
                            
                            default: 
                                begin
                                    branch_jump_flag = 1'b0;
                                    flush = 1'b0;
                                end    
                        
                        endcase
                    end                        
                               
            else
                begin
                    branch_signal = 1'b0;
                    branch_jump_flag = 1'b0;
                    flush = 1'b0;
                end
            
        end
        
        always_comb
            begin
                if(jump_flag_EX_in == 1'b1) 
                    begin
                        //$display("No branch condition met! ");
                        jump_instruction_EX = 1'b1;
                        //flush = 1'b1;
                    end
                else
                    begin
                        jump_instruction_EX = 1'b0;
                        //flush = 1'b0;
                    end
        
            end            
endmodule
