`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2024 02:17:48 AM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit #(parameter size = 32) (
    //input [4:0] rd_MEM_in,
    //input [4:0] rd_WB_in,
    input [size-1:0] instruction_ID_in,
    input [size-1:0] instruction_EX_in,
    input [size-1:0] instruction_MEM_in,
    input [size-1:0] instruction_WB_in,
    input DMemWR_EX_in,
    input DMemWR_MEM_in,
    //input [4:0] rs1_EX_in,
    //input [4:0] rs2_EX_in,
    input reg_wr_en_MEM_in,
    input reg_wr_en_WB_in,
    output logic [1:0] forward_A,   // mux_A select
    output logic [1:0] forward_B,    // mux_B select
    //output logic forward_C,   // mux_RAW_rs select signal
    //output logic forward_D,   // mux_RAW_rs select signal
    output logic data_hazard_MEM,
    output logic data_hazard_WB,
    output logic [1:0] store_data_hazard_sel
    );
    
    logic [4:0] rs1_EX_in, rs2_EX_in, rd_MEM_in, rd_WB_in, rs1_ID_in, rs2_ID_in;
    //assign rs1_ID_in = instruction_ID_in [19:15];
    //assign rs2_ID_in = instruction_ID_in [24:20];
    assign rs1_EX_in = instruction_EX_in [19:15];
    assign rs2_EX_in = instruction_EX_in [24:20];
    assign rd_MEM_in = instruction_MEM_in[11:7];
    assign rd_WB_in = instruction_WB_in[11:7];
    
    always_comb
            begin
                if(rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1) // && (instruction_EX_in[6:0] !=103 || instruction_EX_in[6:0]!=19 || instruction_EX_in[6:0]!=99))
                    begin
                        //$display("Data forwarding data from MEM to EX in case rd_MEM == rs1_EX ");
                        data_hazard_MEM = 1'b1;
                        forward_A = 2'b01;  // forwarding data from MEM to EX in case rd_MEM == rs1_EX
                    end
                else if(rd_WB_in == rs1_EX_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1)
                    begin
                        forward_A = 2'b10;  // forwarding data from WB to EX in case rd_MEM == rs1_EX
                        data_hazard_WB = 1'b1;
                    end
                else
                    begin
                        forward_A = 2'b00;
                        data_hazard_MEM = 1'b0;
            end
                    
    end
    
    always_comb
	    begin              
		        if(rd_MEM_in == rs2_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1 && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))
		            begin
		                //data_hazard_MEM = 1'b1;
		                forward_B = 2'b01;  // forwarding data from MEM to EX in case rd_MEM == rs2_EX
		            end 
		            
		        else if(rd_WB_in == rs2_EX_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1 && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))
		            begin
		                //data_hazard_WB = 1'b1;
		                forward_B = 2'b10;  // forwarding data from WB to EX in case rd_MEM == rs2_EX
		            end 
		        else
		            begin
		                forward_B = 2'b00;
		                //data_hazard_WB = 1'b0;
		            end
	    end
            
endmodule

//  // MEM to EX stage forwarding in case of R, I and J type instructions dependency
//                if(rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1) // && (instruction_EX_in[6:0] !=103 || instruction_EX_in[6:0]!=19 || instruction_EX_in[6:0]!=99))
//                    begin
//                        data_hazard_MEM = 1'b1;
//                        forward_A = 2'b01;  // forward ALU-out to data1
//                    end
                
//                 else if(rd_MEM_in == rs2_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1 && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))
//                    begin
//                        data_hazard_MEM = 1'b1;
//                        forward_B = 2'b01;  // forward ALU-out to data1
//                    end
                
//                else
//                    begin
//                        forward_A = 2'b00;
//                        forward_B = 2'b00;
//                        data_hazard_MEM = 1'b0;
//                    end     

            
//            // WB to EX stage forwarding in case of R, I and J type instructions dependency
//                if(rd_WB_in == rs1_EX_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1)
//                    begin
//                        forward_A = 2'b10;  // forward ALU-out to data2
//                        data_hazard_WB = 1'b1;
//                    end
                    
//                else if(rd_WB_in == rs2_EX_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1 && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))
//                    begin
//                        data_hazard_WB = 1'b1;
//                        forward_B = 2'b10;  // forward ALU-out to data1
//                    end

//                else
//                    begin
//                        forward_A = 2'b00;
//                        forward_B = 2'b00;
//                        data_hazard_WB = 1'b0;
//                    end
         
         
//            // MEM to ID stage forwarding in case of R, I and J type instructions dependency  

//            if(rd_WB_in == rs1_ID_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1 && ! (rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1))
//                begin
//                    forward_A = 2'b10;  // forward ALU-out to data1
//                    data_hazard_WB = 1'b1;
//                end
                
//            else if(rd_WB_in == rs2_ID_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1 /*&& (instruction_ID_in[6:0]==35 || instruction_ID_in[6:0]==51 || instruction_ID_in[6:0]==99)*/ && !(rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1))
//                begin
//                    forward_B = 2'b10;  // forward ALU-out to data1
//                    data_hazard_WB = 1'b1;
//                end     
//            else 
//                begin
//                    forward_A = 1'b0;
//                    forward_B = 1'b0;  // forward ALU-out to data1
//                    data_hazard_WB = 1'b0;
//                end 
                
        
//        // store is followed by load comamnd with dependency  
//            if(rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && DMemWR_MEM_in == 1)
//                begin
//                    data_hazard_MEM = 1'b1;
//                    forward_A = 2'b01;  // forward ALU-out to data1
//                end
                
//             else if(rd_MEM_in == rs2_EX_in && rd_MEM_in !=0 && DMemWR_MEM_in == 1 && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))
//                begin
//                    data_hazard_MEM = 1'b1;
//                    forward_B = 2'b01;  // forward ALU-out to data1
//                end
//             else
//                begin
//                    forward_A = 2'b00;
//                    forward_B = 2'b00;
//                    data_hazard_MEM = 1'b0;
//                end   
                
//        end
        
//    // store command dependency in execution satge 
//    always_comb 
//        begin
//            if((rd_MEM_in == rs1_EX_in || rd_MEM_in == rs2_EX_in) && rd_MEM_in !=0 && DMemWR_EX_in == 1 && instruction_EX_in[6:0]==35)
//                store_data_hazard_sel = 2'b01;
                
//            else if((rd_WB_in == rs1_EX_in || rd_MEM_in == rs2_EX_in) && rd_WB_in !=0 && DMemWR_EX_in == 1 && instruction_EX_in[6:0]==35)
//                store_data_hazard_sel = 2'b10;
                
//            else
//                store_data_hazard_sel = 2'b00;
//        end
        
     
//     // WB to ID stage data forwarding     
     
//     always_comb
//        begin
//            if(rd_WB_in == rs1_ID_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1)   //  && ! (rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1))
//                begin
//                    forward_C = 1'b1;  // forward ALU-out to data1
//                    //data_hazard_WB = 1'b1;
//                end
                
//            else if(rd_WB_in == rs2_ID_in && rd_WB_in !=0 && reg_wr_en_WB_in == 1 ) ///*&& (instruction_ID_in[6:0]==35 || instruction_ID_in[6:0]==51 || instruction_ID_in[6:0]==99)*/ && !(rd_MEM_in == rs1_EX_in && rd_MEM_in !=0 && reg_wr_en_MEM_in == 1))
//                begin
//                    forward_D = 1'b1;  // forward ALU-out to data1
//                    //data_hazard_WB = 1'b1;
//                end     
//            else 
//                begin
//                    forward_C = 1'b0;   // forward ALU-out to data1
//                    forward_D = 1'b0;   // forward ALU-out to data2
//                    //data_hazard_WB = 1'b0;
//                end  
//        end
