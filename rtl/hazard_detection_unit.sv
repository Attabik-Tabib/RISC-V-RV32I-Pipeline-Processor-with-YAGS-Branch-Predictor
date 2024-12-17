`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 03:46:38 AM
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazard_detection_unit #(parameter size = 32) (
    input [size-1:0] instruction_ID_in,
    input [size-1:0] instruction_EX_in,
    input DMemWR_EX_in,
    input [1:0] WB_Sel_EX_in,
    input reg_wr_en_EX_in,
    input load_hazard_EX,
    
    // Outputs  
    output logic PC_write,
    output logic IF_ID_reg_write_en,
    output logic stall_mux_Sel

    );
    
    logic [4:0] rd_EX_in, rs1_ID_in, rs2_ID_in;
    logic [6:0] opcode_EX_in;
    assign rd_EX_in = instruction_EX_in[11:7];
    assign rs1_ID_in = instruction_ID_in [19:15];
    assign rs2_ID_in = instruction_ID_in [24:20];
    assign opcode_EX_in = instruction_EX_in [6:0];
    
    always_comb
        begin
            // load condition rd dependence on next instructioin rs1 or rs2
            if(rd_EX_in == rs1_ID_in  && WB_Sel_EX_in == 0 && reg_wr_en_EX_in == 1) 	// && DMemWR_EX_in == 0 && opcode_EX_in == 3 && load_hazard_EX == 1'b1)   
                begin
                    PC_write = 1'b0;                // disable program counter
                    IF_ID_reg_write_en = 1'b0;      // disable IF_ID register
                    stall_mux_Sel = 1'b1;            // mux selc = 1 to select control signals for stall
                end
            else if(rd_EX_in == rs2_ID_in && WB_Sel_EX_in == 0 && reg_wr_en_EX_in == 1) 	// && DMemWR_EX_in == 0  && opcode_EX_in == 3 && load_hazard_EX == 1'b1) // && (instruction_EX_in[6:0]==35 || instruction_EX_in[6:0]==51 || instruction_EX_in[6:0]==99))   
                begin
                    PC_write = 1'b0;                // disable program counter
                    IF_ID_reg_write_en = 1'b0;      // disable IF_ID register
                    stall_mux_Sel = 1'b1;            // mux selc = 1 to select control signals for stall
                end
            else
                begin
                    PC_write = 1'b1;
                    IF_ID_reg_write_en = 1'b1; 
                    stall_mux_Sel = 1'b0;            // mux sel = 0 to to let original control signals pass
                end
        end
endmodule
