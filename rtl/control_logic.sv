`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 07:46:56 PM
// Design Name: 
// Module Name: control_logic
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


module control_logic #(parameter size = 32) ( 
    input [size - 1 : 0] instruction,
    //input BrEq,                                 // beq branch flag
    //input BrLt,                                 // blt branch flag
    output logic load_hazard_ID,                          // to check for load_type instruction
    output logic reg_wr_en,                     // register write enable
    output logic BSel,                          // immediate select fot BSel = 1
    output logic DMemWR,                      // Read/Write enable fr data memeory 1 to write, 0 to read
    output logic jalr_flag,                     // jalr instrcution flag
    output logic BrUn,                          // unsigned branch flag
    output logic [1:0] WB_Sel,                  // slect between ALU result and data mmeory result. 1 for ALU, 0 for data meomory
    output logic [1:0] store_size,              // defining size of data to be stored in case of store instruction
    output logic [2:0] load_size,               // defining size of data to be loaded in case of store instruction    
    output logic [3:0] ALU_Sel,                  // ALU operation select based upon func3 bits and bit 6 of funct7
    output logic jump_flag
    );
    
      
    always_comb
        begin
   
           // control logic for R-type instructions  
           if(instruction[6:0] == 51)   // R-type instructions opcode
                begin
                    ALU_Sel = {instruction[30],instruction[14:12]};
                    DMemWR = 1'b0;
                    WB_Sel = 2'b01;
                    BSel = 1'b0;
                    jalr_flag = 1'b0;  //changes done
                    reg_wr_en = 1'b1;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b0;
                end
                              
            // control logic for I-type immediate instructions  
            else if(instruction[6:0] == 19)   // I-type immediate instructions opcode
                begin
                    if(instruction[14:12] == 5 && instruction[30] == 1)
                        begin
                            ALU_Sel = {1'b1,instruction[14:12]};
                            DMemWR = 1'b0;
                            WB_Sel = 2'b01;
                            BSel = 1'b1;
                            reg_wr_en = 1'b1;
                            jalr_flag = 1'b0;
                            load_hazard_ID = 1'b0;
                            jump_flag = 1'b0;
                        end
                    else
                        begin
                            ALU_Sel = {1'b0,instruction[14:12]};
                            DMemWR = 1'b0;
                            WB_Sel = 2'b01;
                            BSel = 1'b1;
                            reg_wr_en = 1'b1; 
                            jalr_flag = 1'b0;
                            load_hazard_ID = 1'b0;
                            jump_flag = 1'b0;
                        end
                end
                
            // control logic for S-type instructions  
            else if(instruction[6:0] == 35)   // S-type instructions opcode
                begin
                   casex(instruction[13:12])    // check on func3 first 2 bits
                       2'b00:   store_size = 2'd0;  // Store byte
                       2'b01:   store_size = 2'd1;  // Store half word
                       2'b10:   store_size = 2'd2;  // Store word
                       default: store_size = 2'dx;  
                   endcase
    
                    ALU_Sel = 4'b0000;
                    DMemWR = 1'b1;
                    WB_Sel = 2'b01;
                    BSel = 1'b1;
                    reg_wr_en = 1'b0;
                    jalr_flag = 1'b0;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b0;
                end
             
            // control logic for I-type laod instructions      
            else if(instruction[6:0] == 3)   // I-type Load Instructions opcode
                begin
                   casex(instruction[14:12])    // check on func3 bits
                       3'b000:  load_size = 3'd0;  // laod byte
                       3'b001:  load_size = 3'd1;  // laod half word
                       3'b010:  load_size = 3'd2;  // laod word
                       3'b100:  load_size = 3'd4;  // laod byte unsigned
                       3'b101:  load_size = 3'd5;  // laod word unsigned                  
                       default: load_size = 3'dx;  
                   endcase
    
                    ALU_Sel = 4'b0000;
                    DMemWR = 1'b0;
                    WB_Sel = 2'b00;
                    BSel = 1'b1;
                    reg_wr_en = 1'b1; 
                    jalr_flag = 1'b0;
                    load_hazard_ID = 1'b1;
                    jump_flag = 1'b0;
                end
                
              // control logic for jalr-type instructions  
            else if(instruction[6:0] == 103)   // Jalr-type Instructions opcode
                begin
                    ALU_Sel = 4'b0000;
                    WB_Sel = 2'b10;
                    DMemWR = 1'b0; 
                    BSel = 1'b1;
                    jalr_flag = 1'b0;
                    reg_wr_en = 1'b1;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b1;
                end
                
             else if(instruction[6:0] == 111)   // Jal-type Instructions
                begin
                    ALU_Sel = 4'b0000;
                    WB_Sel = 2'b10;
                    DMemWR = 1'b0; 
                    BSel = 1'b1;
                    jalr_flag = 1'b1;
                    reg_wr_en = 1'b1;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b1;
                end
                
             // Branch intructions check based on opcode and func3
             else if(instruction[6:0] == 99)            // B-type instructions opcode
                    begin
                        case(instruction[14:12])       // Checking funct3 bits for branch condition   
                            
                            3'b100: 
                                begin
                                    BrUn = 1'b0;        // blt (signed comparison)
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end
                                
                            3'b101: 
                                begin
                                    BrUn = 1'b0;        // bge (signed comparison)
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end
                            
                            3'b110: 
                                begin
                                    BrUn = 1'b1;        // bltu (unsigned comparison)
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;     
                                end
                            
                            3'b111: 
                                begin
                                    BrUn = 1'b1;        // bgeu (unsigned comparison)
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end
                            
                            3'b000:
                                begin
                                    BrUn = 1'b0;        //beq
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end
                            
                             3'b001:
                                begin
                                    BrUn = 1'b0;        //bne control signals
                                    ALU_Sel = 4'b0000;
                                    //WB_Sel = 2'b10;
                                    DMemWR = 1'b0; 
                                    BSel = 1'b1;
                                    jalr_flag = 1'b1;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end
                            
                            default: 
                                begin
                                    BrUn = 1'b0;        //changes made
                                    ALU_Sel = 4'bx;
                                    WB_Sel = 2'bxx;
                                    DMemWR = 1'b0; 
                                    BSel = 1'bx;
                                    jalr_flag = 1'b0;
                                    reg_wr_en = 1'b0;
                                    load_hazard_ID = 1'b0;
                                    jump_flag = 1'b0;
                                end    
                        
                        endcase
                    end                        
        
//                else 
//                    jump_flag = 1'b0; 

            else if (instruction[6:0] == 23)        // U-type Instruction (auipc) Check
                begin
                    ALU_Sel = 4'b0000;
                    WB_Sel = 2'b01;
                    DMemWR = 1'b0; 
                    BSel = 1'b1;
                    jalr_flag = 1'b1;
                    reg_wr_en = 1'b1;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b0;
                end
                
            
            else if (instruction[6:0] == 55)    // U-type Instruction (lui) Check
                begin
                    ALU_Sel = 4'b1111;
                    WB_Sel = 2'b01;
                    DMemWR = 1'b0; 
                    BSel = 1'b1;
                    jalr_flag = 1'b1;       // Don't care in this case
                    reg_wr_en = 1'b1;
                    load_hazard_ID = 1'b0;
                    jump_flag = 1'b0;
                end
 /*             
            else 
            	begin
                    //ALU_Sel = 4'b0000;
                    //WB_Sel = 2'b00;
                    //DMemWR = 1'b0; 
                    //BSel = 1'b0;
                    //jalr_flag = 1'b0;   // Don't care in this case
                    //reg_wr_en = 1'b0;
                    //load_hazard_ID = 1'b0;
                    //jump_flag = 1'b0;
                    //store_size = 0;
                    //load_size= 0;
            	end
  */                                                                                   
        end

endmodule
    

//  else if(instruction[6:0] == 99)            // B-type instructions opcode
//                    begin
//                        casex(instruction[14:12])       // Chenking funct3 bits for branch condition   
//                            3'b100: BrUn = 1'b0;        // blt (signed comparison)
//                            3'b101: BrUn = 1'b0;        // bge (signed comparison)
//                            3'b110: BrUn = 1'b1;        // bltu (unsigned comparison)
//                            3'b100: BrUn = 1'b1;        // bgeu (unsigned comparison)
//                            default: BrUn = 1'bx;      
//                        endcase                        
//                    end
                    
            
//               else if(BrUn == 0)
//                   begin                        
                        
//                            ALU_Sel = 4'b0000;
//                            //WB_Sel = 2'b10;
//                            DMemWR = 1'b0; 
//                            BSel = 1'b1;
//                            jalr_flag = 1'b1;
//                            reg_wr_en = 1'b0;      
                
//                        if(BrLt == 1'b1 && BrEq == 1'b0)            // blt (signed)
//                            jump_flag = 1'b1;
                        
//                        else  if((BrLt == 1'b0 || BrEq == 1'b1))      // bge (signed)
//                            jump_flag = 1'b1;
                        
//                        else 
//                             jump_flag = 1'b0;
                                     
//                   end
                   
//               else if(BrUn == 1) 
//               begin
//                    ALU_Sel = 4'b0000;
//                    //WB_Sel = 2'b10;
//                    DMemWR = 1'b0; 
//                    BSel = 1'b1;
//                    jalr_flag = 1'b1;
//                    reg_wr_en = 1'b0;
       
//                    if(BrLt == 1'b1 && BrEq == 1'b0)      // bltu (unsigned)
//                        jump_flag = 1'b1;
                    
//                    else  if((BrLt == 1'b0) || BrEq == 1'b1)      // bgeu (signed)
//                        jump_flag = 1'b1;
                    
//                    else 
//                             jump_flag = 1'b0;
                        
//                end
                
//                else if(BrEq == 1'b1)   // beq
//                    begin
//                        ALU_Sel = 4'b0000;
//                        //WB_Sel = 2'b10;
//                        DMemWR = 1'b0; 
//                        BSel = 1'b1;
//                        jalr_flag = 1'b1;
//                        reg_wr_en = 1'b0;
//                        jump_flag = 1'b1;
//                    end
                        
//                else if(BrEq == 1'b0)   // bne
//                    begin
//                        ALU_Sel = 4'b0000;
//                        //WB_Sel = 2'b10;
//                        DMemWR = 1'b0; 
//                        BSel = 1'b1;
//                        jalr_flag = 1'b1;
//                        reg_wr_en = 1'b0;
//                        jump_flag = 1'b1;
//                    end
                            
//                else 
//                             jump_flag = 1'b0;  
             
