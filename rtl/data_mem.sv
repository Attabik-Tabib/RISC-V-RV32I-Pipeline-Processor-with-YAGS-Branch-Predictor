`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2024 06:47:57 PM
// Design Name: 
// Module Name: data_mem
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


module data_mem #(parameter size = 32)(
    input clk,
    input [size-1 : 0] address,
    input [size-1 : 0] dataW_DMem,
    input DMemWR,
    input [1:0] store_size,
    input [2:0] load_size,
    output logic [size-1 : 0] dataR
    );
    
    logic [1:0] byte_number;
    assign byte_number = address[1:0];
      
    logic [size-1 : 0] DataMem [0: 100000-1];
   
    initial 
        $readmemh("data_memory.mem", DataMem);   // For Binary File 
/*
	initial 
        begin
		  DataMem = '{default: 32'b0};
	    end
*/ 
       
//    integer i;
//    initial
//        begin
//            for(i=0; i < 1024; i++ )
//                begin
//                    if(i == 0 )
//                        DataMem[i] = 32'd0;
//                    else
//                        DataMem[i] = DataMem[i] + 1'b1;
//                end           
//        end
    
    always_ff @(posedge clk)
        begin
             if(DMemWR == 1)      // Write/Store data
                 begin
                    case(store_size)
                        2'b00:
                            begin
                                case(byte_number)
                                    2'b00: DataMem[address[31:2]][7:0] <= dataW_DMem[7:0];       // 0 for first byte select
                                    2'b01: DataMem[address[31:2]][15:8] <= dataW_DMem[7:0];      // 1 for 2nd byte select
                                    2'b10: DataMem[address[31:2]][23:16] <= dataW_DMem[7:0];     // 2 for 3rd byte seelct
                                    default: DataMem[address[31:2]][31:24] <= dataW_DMem[7:0];   // 3 for 4th byte select
                                endcase
                            end
                            
                        2'b01:
                            begin  
                                case(address[1])   // bit-1 of address is telling us about half word number, 0 for first, 1 for 2nd half word
                                    1'b0: DataMem[address[31:2]][15:0] <= dataW_DMem[15:0];
                                    default: DataMem[address[31:2]][31:16] <= dataW_DMem[15:0];
                                endcase
                            end
                            
                        2'b10:
                            begin  
                                  DataMem[address[31:2]] <= dataW_DMem;  // store full word         
                            end
                            
                        default: DataMem[address[31:2]] <= DataMem[address[31:2]];  // retain data for default case 
                    endcase
                end
                
            
            else
                DataMem[address[31:2]] <= DataMem[address[31:2]];       // reatin data if write enable if 0                          
        end
        
    // Load Data Implementation
    always_comb
            begin
                if(DMemWR == 0)
                    begin
                        casex(load_size)
                            3'b000:
                                begin
                                    case(byte_number)
                                        2'b00: dataR = {{24{DataMem[address[31:2]][7]}}, DataMem[address[31:2]][7:0]};      // load byte signed
                                        2'b01: dataR = {{24{DataMem[address[31:2]][15]}}, DataMem[address[31:2]][15:8]};    // load byte signed
                                        2'b10: dataR = {{24{DataMem[address[31:2]][23]}}, DataMem[address[31:2]][23:16]};   // load byte signed
                                        default: dataR = {{24{DataMem[address[31:2]][31]}}, DataMem[address[31:2]][31:24]};   // load byte signed
                                    endcase
                                end    
                            
                            3'b001: 
                                begin
                                    case(address[1])
                                        1'b0: dataR = {{16{DataMem[address[31:2]][15]}}, DataMem[address[31:2]][15:0]};  // load word signed
                                        default: dataR = {{16{DataMem[address[31:2]][31]}}, DataMem[address[31:2]][31:16]};  // load word signed
                                    endcase                                   
                                end
                            
                            3'b010: dataR = DataMem[address[31:2]];                                             // laod word
                            
                            3'b100:
                                 begin
                                        case(byte_number)
                                            2'b00: dataR = {24'd0, DataMem[address[31:2]][7:0]};      // load byte signed
                                            2'b01: dataR = {24'd0, DataMem[address[31:2]][15:8]};    // load byte signed
                                            2'b10: dataR = {24'd0, DataMem[address[31:2]][23:16]};   // load byte signed
                                            default: dataR = {24'd0, DataMem[address[31:2]][31:24]};   // load byte signed
                                        endcase
                                 end 
                                 
                            3'b101: 
                               begin
                                    case(address[1])
                                        1'b0: dataR = {16'd0, DataMem[address[31:2]][15:0]};  // load word signed
                                        default: dataR = {16'd0, DataMem[address[31:2]][31:16]};  // load word signed
                                    endcase                                   
                                end
                             
                            default:   dataR = 32'dx;
                        endcase
                    end
                else
                    dataR = dataR;
                       
            end
endmodule
