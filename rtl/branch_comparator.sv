`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 04:51:58 AM
// Design Name: 
// Module Name: branch_comparator
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


module branch_comparator #(parameter size = 32) (
    input [size-1:0] data1,
    input [size-1:0] data2,
    input BrUn,
    // outputs
    output logic BrLt,
    output logic BrEq
    );
    

    
    always_comb
        begin
           
            if(data1 != data2)
               
                begin
                    //$display("Entered Branch Comparator check for data1 != data2");
                    BrEq = 1'b0;    // data1 != data2
                     
                     casex(BrUn)
                        
                       1'b0:       // for signed numbers
                            begin
                                if($signed(data1) < $signed(data2))     // data1 < data2
                                    begin
                                        BrLt = 1'b1;    // data1 < data2
                                    end
                                else                    
                                    begin 
                                        BrLt = 1'b0;    // data1 > data2
                                    end
                            end
                                     
                        
                       1'b1:       // for unsigned numbers
                            begin
                                if(data1 < data2)    
                                    begin
                                        BrLt = 1'b1;     // data1 < data2
                                    end
                                else                    
                                    begin
                                        //$display("Error"); 
                                        BrLt = 1'b0;    // data1 > data2

                                    end
                            end

                            
                            default:
                                begin
                                    BrLt = 1'bx;
                                end 
                    endcase
                 
                 end       
            
            else
                begin
                    //$display("Numbers are Equal!");
                    BrEq = 1'b1;            // data1 = data2
                end
        end
                 
endmodule
