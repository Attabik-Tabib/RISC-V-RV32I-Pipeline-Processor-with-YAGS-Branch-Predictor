
module top #(parameter size = 32, GHR_size = 10, PC_size = 10) (
    input clk,
    input reset
    //output logic out     
    );
    
    /************************************************************* IF Satge *******************************************************************/
    
    logic [size - 1 : 0] PC_out;
    logic [size - 1: 0] jump_mux_out;
    logic PC_write;
    
    // Instentiating Program Counter Module
    program_counter pc(
    .clk(clk),
    .reset(reset),
    .PC_write(PC_write),
    .jump_mux_out(jump_mux_out),
    // Output
    .PC_out(PC_out) 
    );
    
    logic [size - 1 : 0] PC_adder_mux_out;
    logic [size-1 : 0] PC_EX_in;		// Program counetr from EX stage
    logic [size-1 : 0] ALU_out_EX;
    logic jump_flag_EX_in;
    logic [1:0] branch_comp_MUX_select_EX;
    logic [size-1 : 0] imm_EX_in;
    logic branch_signal;
    
    // Instentiating PC+4 adder Module
    PC_adder_MUX_IF_Stage pc_add_IF(
    .jump_flag_EX_in(jump_flag_EX_in),
    .PC_adder_mux_select(branch_comp_MUX_select_EX),
    .PC_out(PC_out),
    .ALU_out(ALU_out_EX),
    .PC_plus_offset_from_EX(PC_EX_in + imm_EX_in),
    .PC_EX(PC_EX_in),
    // Output
    .PC_adder_mux_out(PC_adder_mux_out)
    );
    
       
    //logic jump_flag;        
    //assign jump_flag_ID = IF_data_out[64];  // Jump Mux control signal generagted in the ID stage and stored in the ID/IF pipeline register
    
    logic jump_flag_MEM_in;
    logic branch_jump_flag;		// Actual branch signal form branch comparators
    logic [size-1 : 0] ALU_out_MEM_in;
    //logic [size - 1 : 0] ALU_in_MEM;       // output of ALU
     
    //assign out =  jump_flag  ;
      
    // Intentiating Mux module to comtrol jump
    
    logic YAGS_prediction;			// branch predictor output (1 for taken, 0 for not taken)
    logic [size - 1 : 0] branch_comp_MUX_out_EX;
    logic [size - 1: 0] imm_YAGS;
    logic PHT_prediction;
    
    // Jump MUX
    jump_mux jal(
    .PC_out(PC_out),
    .YAGS_prediction(YAGS_prediction),
    .branch_comp_MUX_out_EX(PC_adder_mux_out),
    .imm_YAGS(imm_YAGS),
    .PHT_prediction(PHT_prediction),
    // Output
    .jump_mux_out(jump_mux_out)
    );
    
    logic [size-1 : 0] IMem_Intruction;
    //logic [63:0] IF_data_out;  // Output of IF Stage (65-bit)
    logic branch_check;
    
    // Instentiating Instruction Memeory Module
    inst_mem IMem(
	    .PC_in(PC_out),
	    // Output
	    .instruction(IMem_Intruction),
	    .branch_check(branch_check),
	    .imm_YAGS(imm_YAGS)
	    );
    
    	// Pattern History tabke Output	(1 for taken, 0 for not taken)
    logic PHT_conflict;	// Flag to check whether the actual prediction macthes the PHT prediction (1 for match, 0 for mismatch) 
    logic [ GHR_size - 1 : 0 ] GHR;
    logic PHT_prediction_EX;
    logic Taken_Arr_prediction;
    logic Taken_Arr_hit;
    logic Not_Taken_Arr_prediction;
    logic Not_Taken_Arr_hit; 
    logic [ PC_size - 1 : 0 ] Taken_Arr_Index;
    logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index;
    logic [ PC_size - 1 : 0 ] Taken_Arr_Index_EX;
    logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_EX;
    logic YAGS_prediction_EX;
    
    logic T_NT_Arr_hit_IF;
    logic T_NT_Arr_hit_ID;
    logic T_NT_Arr_hit_EX;
    
    logic Taken_Arr_prediction_IF;
    logic Not_Taken_Arr_prediction_IF;
    logic Taken_Arr_prediction_ID;
    logic Not_Taken_Arr_prediction_ID;
    logic Taken_Arr_prediction_EX;
    logic Not_Taken_Arr_prediction_EX;
    logic Taken_Arr_hit_EX;
    logic Not_Taken_Arr_hit_EX;
    
    Taken_Array T_cache ( 
	.clk(clk),
	.rst(reset),
	.Current_PC(PC_out[PC_size-1:0]),
	.PC_from_branch_comp(PC_EX_in[PC_size-1:0]),
	.GHR(GHR),
	.PHT_prediction_EX(PHT_prediction_EX),
	.PHT_prediction(PHT_prediction),
	.actual_prediction(branch_jump_flag),
	.branch_signal(branch_signal),
	.Taken_Arr_Index_EX(Taken_Arr_Index_EX),
	.branch(branch_check),
	.Taken_Arr_hit_EX(Taken_Arr_hit_EX),
	// outputs
	.Taken_Arr_Index(Taken_Arr_Index),
	.Taken_Arr_prediction(Taken_Arr_prediction_IF),
	.Taken_Arr_hit(Taken_Arr_hit)
	 ); 
	 
    Not_Taken_Array NT_cache ( 
	.clk(clk),
	.rst(reset),
	.Current_PC(PC_out[PC_size-1:0]),
	.PC_from_branch_comp(PC_EX_in[PC_size-1:0]),
	.GHR(GHR),
	.PHT_prediction_EX(PHT_prediction_EX),
	.PHT_prediction(PHT_prediction),
	.actual_prediction(branch_jump_flag),
	.branch_signal(branch_signal),
	.Not_Taken_Arr_Index_EX(Not_Taken_Arr_Index_EX),
	.branch(branch_check),
	.Not_Taken_Arr_hit_EX(Not_Taken_Arr_hit_EX),
	// outputs
	.Not_Taken_Arr_Index(Not_Taken_Arr_Index),
	.Not_Taken_Arr_prediction(Not_Taken_Arr_prediction_IF),
	.Not_Taken_Arr_hit(Not_Taken_Arr_hit)
	 );
	 
	  
    // Instantiating branch Predictor
    YAGS_branch_predictor YAGS_Predictor (
	.clk(clk), 
	.rst(reset), 
	.actual_prediction(branch_jump_flag), 
	.branch(branch_check), 
	.branch_signal(branch_signal),  //this is for the BRANCH signal from ex stage to initiate the history register
	.PHT_conflict(PHT_conflict),
	.PC(PC_out[PC_size-1:0]), 
	.PC_from_branch_comp(PC_EX_in[PC_size-1:0]),
	.GHR(GHR),
	.Taken_Arr_prediction(Taken_Arr_prediction_IF),
	.Taken_Arr_hit(Taken_Arr_hit),
	.Not_Taken_Arr_prediction(Not_Taken_Arr_prediction_IF),
	.Not_Taken_Arr_hit(Not_Taken_Arr_hit),
	.T_NT_Arr_hit_EX(T_NT_Arr_hit_EX),
	.Taken_Arr_prediction_EX(Taken_Arr_prediction_EX),
	.NOT_Taken_Arr_prediction_EX(Not_Taken_Arr_prediction_EX),
	// outputs
	.PHT_prediction(PHT_prediction),
	.YAGS_prediction(YAGS_prediction) ,
	.T_NT_Arr_hit(T_NT_Arr_hit_IF)
	);
	 	  
    /************************************************************* IF / ID Satge Register *******************************************************************/   
    logic [31:0] PC_in_ID, instruction_in_ID;
    logic IF_ID_reg_write_en;
    logic flush;
    logic YAGS_prediction_ID;
    logic PHT_prediction_ID;
    logic YAGS_conflict;
    logic [ PC_size - 1 : 0 ] Taken_Arr_Index_ID;
    logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_ID;
    logic jump_instruction_EX;
    logic Taken_Arr_hit_ID;
    logic Not_Taken_Arr_hit_ID;
    
    // If/ID Stage Register
    IF_ID_Stage_Reg REG_IF_ID(
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .PHT_conflict(PHT_conflict),
    .IF_ID_reg_write_en(IF_ID_reg_write_en),
    .PC_out_IF(PC_out),
    .instruction_out_IF(IMem_Intruction),
    .YAGS_prediction_IF(YAGS_prediction),
    .PHT_prediction_IF(PHT_prediction),
    .Taken_Arr_Index_IF(Taken_Arr_Index),
    .Not_Taken_Arr_Index_IF(Not_Taken_Arr_Index),
    .YAGS_conflict(YAGS_conflict),
    .T_NT_Arr_hit_IF(T_NT_Arr_hit_IF),
    .Taken_Arr_prediction_IF(Taken_Arr_prediction_IF),
    .Not_Taken_Arr_prediction_IF(Not_Taken_Arr_prediction_IF),
    .jump_instruction_EX(jump_instruction_EX),
    .Taken_Arr_hit_IF(Taken_Arr_hit),
    .Not_Taken_Arr_hit_IF(Not_Taken_Arr_hit),
    // outputs of ID/EX Register
    .PC_in_ID(PC_in_ID),
    .instruction_in_ID(instruction_in_ID),
    .YAGS_prediction_ID(YAGS_prediction_ID),
    .PHT_prediction_ID(PHT_prediction_ID),
    .Taken_Arr_Index_ID(Taken_Arr_Index_ID),
    .Not_Taken_Arr_Index_ID(Not_Taken_Arr_Index_ID),
    .T_NT_Arr_hit_ID(T_NT_Arr_hit_ID),
    .Taken_Arr_prediction_ID(Taken_Arr_prediction_ID),
    .Not_Taken_Arr_prediction_ID(Not_Taken_Arr_prediction_ID),
    .Taken_Arr_hit_ID(Taken_Arr_hit_ID),
    .Not_Taken_Arr_hit_ID(Not_Taken_Arr_hit_ID)
    );
     
    /************************************************************* ID Satge *******************************************************************/

    logic [4:0] rs1_ID, rs2_ID, rd_ID;
    logic [size-1 : 0] data1_ID_out, data2_ID_out;
    
    assign rs1_ID = instruction_in_ID[19:15];
    assign rs2_ID = instruction_in_ID[24:20];
    assign rd_ID = instruction_in_ID[11:7];
    
    logic [size - 1 : 0] imm_ID;    // immediate output from immediate generator
    
    imm_gen im_gen(
    .instruction_in(instruction_in_ID),
    // Output
    .imm_out(imm_ID)
    );
    
    
    logic reg_wr_en_ID_out;
    logic B_Sel_ID_out;
    logic [3:0] ALU_Sel_ID_out;
    logic DMemWR_ID_out;
    logic [1:0] WB_Sel_ID_out;
    logic [1:0] store_size_ID_out;
    logic [2:0] load_size_ID_out;
    logic jalr_flag_ID_out;
    logic jump_flag_ID_out;
    logic BrUn_ID_out;

    
    logic load_hazard_ID;
    
    control_logic cl( 
    .instruction(instruction_in_ID),
    //.BrEq(BrEq_ID_in),
    //.BrLt(BrLt_ID_in),
    // Outputs
    .reg_wr_en(reg_wr_en_ID_out),
    .BSel(B_Sel_ID_out),
    .DMemWR(DMemWR_ID_out),
    .jalr_flag(jalr_flag_ID_out),
    .jump_flag(jump_flag_ID_out),
    .BrUn(BrUn_ID_out),
    .WB_Sel(WB_Sel_ID_out),
    .store_size(store_size_ID_out),
    .load_size(load_size_ID_out),
    .ALU_Sel(ALU_Sel_ID_out),
    .load_hazard_ID(load_hazard_ID)
    );
      
    
    logic [size - 1:0] mux_wb_out;     // Output of last mux, data to be written into the register 
    logic [size-1:0] instruction_WB_in;
    logic [4:0] rd_WB_in;
    logic reg_wr_en_WB_in;
    assign rd_WB_in = instruction_WB_in[11:7];
 
        
    reg_file register_file(
    .clk(clk),
    .reg_wr_en(reg_wr_en_WB_in),
    .rs1(rs1_ID),
    .rs2(rs2_ID),
    .rd(rd_WB_in),
    .dataW_reg_file(mux_wb_out),
    .data1(data1_ID_out),
    .data2(data2_ID_out)
    );
    
//    logic [size-1:0] mux_RAW_ID_data1_out;
//    logic forward_C;   // mux_RAW_rs1 select signal
    
//    mux_RAW_ID_rs1 RAW_ID_rs1(
//    .reg_out_data1(data1_ID_out),
//    .WB_out_data1(mux_wb_out),
//    .mux_Sel_RAW_ID_rs1(forward_C),
//    .mux_RAW_ID_data1_out(mux_RAW_ID_data1_out)
//    );
    
//    logic [size-1:0] mux_RAW_ID_data2_out;
//    logic forward_D;   // mux_RAW_rs2 select signal
    
//    mux_RAW_ID_rs2 RAW_ID_rs2(
//    .reg_out_data2(data2_ID_out),
//    .WB_out_data2(mux_wb_out),
//    .mux_Sel_RAW_ID_rs2(forward_D),
//    .mux_RAW_ID_data2_out(mux_RAW_ID_data2_out)
//    );
    
    //logic [4:0] rs1_EX_in;
    //logic [4:0] rs2_EX_in;
  
    logic [size-1 : 0] data1_EX_in;
    logic [size-1 : 0] data2_EX_in;
    //logic [4 : 0] rd_EX_in;
    logic [size-1 : 0] instruction_EX_in;
    logic reg_wr_en_EX_in;
    logic B_Sel_EX_in;
    logic [3:0] ALU_Sel_EX_in;
    logic DMemWR_EX_in;
    logic [1:0] WB_Sel_EX_in;
    logic [1:0] store_size_EX_in;
    logic [2:0] load_size_EX_in;
    logic jalr_flag_EX_in;
    //logic jump_flag_EX_in;
    logic BrUn_EX_in;
    //logic BrLt_EX_out;
    //logic BrEq_EX_out;
    
    
    
    logic stall_mux_Sel;
    logic load_hazard_EX;
    
    hazard_detection_unit hd(
    .instruction_ID_in(instruction_in_ID),
    .instruction_EX_in(instruction_EX_in),
    .DMemWR_EX_in(DMemWR_EX_in),
    .WB_Sel_EX_in(WB_Sel_EX_in),
    .reg_wr_en_EX_in(reg_wr_en_EX_in),
    .load_hazard_EX(load_hazard_EX),
    // Outputs
    .PC_write(PC_write),
    .IF_ID_reg_write_en(IF_ID_reg_write_en),
    .stall_mux_Sel(stall_mux_Sel)  
    );
    
    logic stall_reg_wr_en;
    logic stall_BSel;
    logic stall_DMemWR;
    logic stall_jalr_flag;
    logic stall_jump_flag;
    logic stall_BrUn;
    logic [1:0] stall_WB_Sel;
    logic [1:0] stall_store_size;
    logic [2:0] stall_load_size;
    logic [3:0] stall_ALU_Sel;
    
    mux_stall_signals_control stall(
    .stall_mux_Sel(stall_mux_Sel),
    .reg_wr_en(reg_wr_en_ID_out),                       // register write enable
//    .BSel(B_Sel_ID_out),                              // immediate select fot BSel = 1
    .DMemWR(DMemWR_ID_out),                             // Read/Write enable fr data memeory 1 to write, 0 to read
//    .jalr_flag(jalr_flag_ID_out),                     // jalr instrcution flag
//    .jump_flag(jump_flag_ID_out),                     //  jal flag
//    .BrUn(BrUn_ID_out),                               // unsigned branch flag
//    .WB_Sel(WB_Sel_ID_out),                           // slect between ALU result and data mmeory result. 1 for ALU, 0 for data meomory
//    .store_size(store_size_ID_out),                   // defining size of data to be stored in case of store instruction
//    .load_size(load_size_ID_out),                     // defining size of data to be loaded in case of store instruction    
//    .ALU_Sel(ALU_Sel_ID_out),                         // ALU operation select based upon func3 bits and bit 6 of funct7
    
    //Outputs
    .stall_reg_wr_en(stall_reg_wr_en),
//    .stall_BSel(stall_BSel),
    .stall_DMemWR(stall_DMemWR)
//    .stall_jalr_flag(stall_jalr_flag),
//    .stall_jump_flag(stall_jump_flag),
//    .stall_BrUn(stall_BrUn),
//    .stall_WB_Sel(stall_WB_Sel),
//    .stall_store_size(stall_store_size),
//    .stall_load_size(stall_load_size),
//    .stall_ALU_Sel(stall_ALU_Sel)
    );
    
    /************************************************************* ID/ EX Satge Register *******************************************************************/
     
    ID_EX_Stage_Reg REG_ID_EX(
    .clk(clk),
    .reset(reset),
    .flush(flush),
     .PHT_conflict(PHT_conflict),
    //.rs1_ID(rs1_ID),
    //.rs2_ID(rs2_ID),
    .instruction_ID_in(instruction_in_ID),      // INSTRUCTION ADDED
    .PC_ID_out(PC_in_ID),
    .data1_ID_out(data1_ID_out),
    .data2_ID_out(data2_ID_out),
    .imm_ID_out(imm_ID),
    //.rd_ID_out(rd_ID),
    .reg_wr_en_ID_out(stall_reg_wr_en),
    .B_Sel_ID_out(B_Sel_ID_out),
    .ALU_Sel_ID_out(ALU_Sel_ID_out),
    .DMemWR_ID_out(stall_DMemWR),
    .WB_Sel_ID_out(WB_Sel_ID_out),
    .store_size_ID_out(store_size_ID_out),
    .load_size_ID_out(load_size_ID_out),
    .jalr_flag_ID_out(jalr_flag_ID_out),
    .jump_flag_ID_out(jump_flag_ID_out),
    .BrUn_ID_out(BrUn_ID_out),
    .load_hazard_ID(load_hazard_ID),
    .YAGS_prediction_ID(YAGS_prediction_ID),
    .PHT_prediction_ID(PHT_prediction_ID),
    .Taken_Arr_Index_ID(Taken_Arr_Index_ID),
    .Not_Taken_Arr_Index_ID(Not_Taken_Arr_Index_ID),
    .YAGS_conflict(YAGS_conflict),
    .T_NT_Arr_hit_ID(T_NT_Arr_hit_ID),
    .Taken_Arr_prediction_ID(Taken_Arr_prediction_ID),
    .Not_Taken_Arr_prediction_ID(Not_Taken_Arr_prediction_ID),
    .jump_instruction_EX(jump_instruction_EX),
    .Taken_Arr_hit_ID(Taken_Arr_hit_ID),
    .Not_Taken_Arr_hit_ID(Not_Taken_Arr_hit_ID),
    //.BrLt_ID_in(BrLt_ID_in),
    //.BrEq_ID_in(BrEq_ID_in),
    
    // Outputs of ID/EX Register
    //.rs1_EX_in(rs1_EX_in),
    //.rs2_EX_in(rs2_EX_in),
    
    // outputs
    .PC_EX_in(PC_EX_in),
    .data1_EX_in(data1_EX_in),
    .data2_EX_in(data2_EX_in),
    .imm_EX_in(imm_EX_in),
    //.rd_EX_in(rd_EX_in),
    .instruction_EX_in(instruction_EX_in),      // INSTRUCTION ADDED
    .reg_wr_en_EX_in(reg_wr_en_EX_in),
    .B_Sel_EX_in(B_Sel_EX_in),
    .ALU_Sel_EX_in(ALU_Sel_EX_in),
    .DMemWR_EX_in(DMemWR_EX_in),
    .WB_Sel_EX_in(WB_Sel_EX_in),
    .store_size_EX_in(store_size_EX_in),
    .load_size_EX_in(load_size_EX_in),
    .jalr_flag_EX_in(jalr_flag_EX_in),
    .jump_flag_EX_in(jump_flag_EX_in),
    .BrUn_EX_in(BrUn_EX_in),
    .load_hazard_EX(load_hazard_EX),
    .YAGS_prediction_EX(YAGS_prediction_EX),
    .PHT_prediction_EX(PHT_prediction_EX),
    .Taken_Arr_Index_EX(Taken_Arr_Index_EX),
    .Not_Taken_Arr_Index_EX(Not_Taken_Arr_Index_EX),
    .T_NT_Arr_hit_EX(T_NT_Arr_hit_EX),
    .Taken_Arr_prediction_EX(Taken_Arr_prediction_EX),
    .NOT_Taken_Arr_prediction_EX(Not_Taken_Arr_prediction_EX),
    .Taken_Arr_hit_EX(Taken_Arr_hit_EX),
    .Not_Taken_Arr_hit_EX(Not_Taken_Arr_hit_EX)
    //.BrLt_EX_out(BrLt_EX_out),
    //.BrEq_EX_out(BrEq_EX_out) 
    );
    
    /************************************************************* EX Satge *******************************************************************/
    
    logic BrLt;
    logic BrEq;
    logic [size-1 : 0] mux_out_A;
    logic [size-1 : 0] mux_out_B;
       
    branch_comparator bcmp(
    .data1(mux_out_A),
    .data2(mux_out_B),
    .BrUn(BrUn_EX_in),
    // Outputs
    .BrLt(BrLt),      // output from EX satge and direct input to control logic in ID stage
    .BrEq(BrEq)       // output from EX satge and direct input to control logic in ID stage
    );
    
    branch_jump_decision branch( 
    .jump_flag_EX_in(jump_flag_EX_in),
    .instruction_EX_in(instruction_EX_in),
    .BrLt(BrLt),                                // beq branch flag
    .BrEq(BrEq),                                // blt branch flag                                
     // Outputs                       
    .branch_signal(branch_signal),             //this is for the BRANCH signal ti the IF stage to initiate the history register
    .branch_jump_flag(branch_jump_flag),       //  branch flag from comparator
    .jump_instruction_EX(jump_instruction_EX),
    .flush(flush)
    );
    
  
   signal_gen_for_branch_mux signal_gen(
   //INPUTS
   .PHT_prediction_EX(PHT_prediction_EX), 
   .actual_prediction(branch_jump_flag),
   .jump_flag_EX_in(jump_flag_EX_in),
   .YAGS_prediction_EX(YAGS_prediction_EX),
   .branch_signal(branch_signal),
   .clk(clk),
   //OUTPUTS
   .branch_comp_MUX_select_EX(branch_comp_MUX_select_EX),
   .PHT_conflict(PHT_conflict),
   .YAGS_conflict(YAGS_conflict)	// from EX Stage
   );
  
  
   global_history_register global_history( 
	.clk(clk),
	.rst(reset),
	.branch_signal(branch_signal),
	.actual_prediction(branch_jump_flag),
	.GHR(GHR)	
	);
    /*
    always_comb
	    begin
	    
		    if( YAGS_prediction_EX == 1 && branch_jump_flag == 0 )	// T/NT conflict
			    begin
			    	branch_comp_MUX_select_EX = 3;
			    	conflict = 1;
			    end
		    else if( YAGS_prediction_EX == 0 && branch_jump_flag == 1 )	// NT/T conflict
			    begin
			    	branch_comp_MUX_select_EX = 1;
			    	conflict = 1;
			    end
		    else if(jump_flag_EX_in)					// unconditional jump
			    begin
			    	branch_comp_MUX_select_EX = 2;
			    	conflict = 0;
			    end
		    else
			    begin
			    	branch_comp_MUX_select_EX = 0;			// normal operation
			    	conflict = 0;
			    end	
	    end	
	    
	*/    
	    
	    
	    
    logic [1:0] mux_sel_forwars_A;
    logic [1:0] mux_sel_forwars_B;
    logic [4:0] rd_MEM_in;
    logic reg_wr_en_MEM_in;
    logic data_hazard_MEM;
    logic data_hazard_WB; 
    logic [size-1:0] instruction_MEM_in;

    logic [1:0] store_data_hazard_sel;
    logic DMemWR_MEM_in;
    
    forwarding_unit fwd(
    //.rd_MEM_in(rd_MEM_in),
    //.rd_WB_in(rd_WB_in),
    .instruction_ID_in(instruction_in_ID),
    .instruction_EX_in(instruction_EX_in),
    .instruction_MEM_in(instruction_MEM_in),
    .instruction_WB_in(instruction_WB_in),
    .DMemWR_EX_in(DMemWR_EX_in),
    .DMemWR_MEM_in(DMemWR_MEM_in),
    //.rs1_EX_in(rs1_EX_in),
    //.rs2_EX_in(rs2_EX_in),
    .reg_wr_en_MEM_in(reg_wr_en_MEM_in),
    .reg_wr_en_WB_in(reg_wr_en_WB_in),
    
    // Outputs
    .forward_A(mux_sel_forwars_A),
    .forward_B(mux_sel_forwars_B),
    //.forward_C(forward_C),
    //.forward_D(forward_D),
    .data_hazard_MEM(data_hazard_MEM),
    .data_hazard_WB(data_hazard_WB),
    .store_data_hazard_sel(store_data_hazard_sel)
    );
    
 
    mux_forward_A forward_A(
    .input1(data1_EX_in),
    .input2(ALU_out_MEM_in),
    .input3(mux_wb_out),
    //outputs
    .mux_sel_forwars_A(mux_sel_forwars_A),
    .mux_out_A(mux_out_A)
    );
    
    logic [size - 1:0] mux_jalr_out_EX;
    
    mux_jalr jalr(
    .jalr_flag(jalr_flag_EX_in),
    .PC_out(PC_EX_in),
    .data1(mux_out_A),
    // Output
    .mux_jalr_out(mux_jalr_out_EX)  
    );
    
    logic [size - 1 : 0] mux_IR_out_EX;   // Output of Immediate select MUX

     
    logic [size - 1 : 0] store_data_hazard_mux_out;
    
    mux_forward_B forward_B(
    .input1(data2_EX_in),
    .input2(ALU_out_MEM_in),
    .input3(mux_wb_out),
    // outputs
    .mux_sel_forwars_B(mux_sel_forwars_B),
    .mux_out_B(mux_out_B)
    );
    
    mux_R_I_type_select m_I_R(
    .B_Sel(B_Sel_EX_in),
    .data2(mux_out_B),
    .imm(imm_EX_in),
    // Output
    .mux_IR_out(mux_IR_out_EX)
    );
    
    
    store_data_hazard_mux store_hazard(
    .store_data_hazard_mux_Sel(store_data_hazard_sel),
    .input1(data2_EX_in),
    .input2(ALU_out_MEM_in),
    .input3(mux_wb_out),
    .store_data_hazard_mux_out(store_data_hazard_mux_out)
    );
    
    
    //logic [size-1 : 0] ALU_out_EX;
    
    alu_logic alu(
    .op1(mux_jalr_out_EX),
    .op2(mux_IR_out_EX) ,
    .ALU_Select(ALU_Sel_EX_in),
    .ALU_out(ALU_out_EX)
    );
        
    logic [size-1 : 0] PC_MEM_in, data1_MEM_in, data2_MEM_in;

   
    logic [1:0] WB_Sel_MEM_in;
    logic [1:0] store_size_MEM_in;
    logic [2:0] load_size_MEM_in;
    logic [size-1:0] data2_EX_out_stored_hazard_mux;
    
    /************************************************************* EX / MEM Stage Register *******************************************************************/
    
    // EX/MEM Stage Register Iplementation
    EX_MEM_Stage_Reg REG_EX_MEM(
    .clk(clk),
    .reset(reset),
    .PC_EX_in(PC_EX_in),
    .ALU_out_EX(ALU_out_EX),
    .data1_EX_in(data1_EX_in),
    .data2_EX_in(data2_EX_in),
    .data2_EX_in_stored_hazard_mux(store_data_hazard_mux_out),
    //.imm_EX_in(imm_EX_in),
    .reg_wr_en_EX_in(reg_wr_en_EX_in),
    //.rd_EX_in(rd_EX_in),
    .instruction_EX_in(instruction_EX_in),
    .DMemWR_EX_in(DMemWR_EX_in),
    .WB_Sel_EX_in(WB_Sel_EX_in),
    .store_size_EX_in(store_size_EX_in),
    .load_size_EX_in(load_size_EX_in),
    //.jump_flag_EX_in(jump_flag_EX_in),
    
    // Outputs
    .PC_MEM_in(PC_MEM_in),
    .ALU_out_MEM_in(ALU_out_MEM_in),
    .data2_EX_out_stored_hazard_mux(data2_EX_out_stored_hazard_mux),
    .data1_MEM_in(data1_MEM_in),
    .data2_MEM_in(data2_MEM_in),
    //.rd_MEM_in(rd_MEM_in),
    .instruction_MEM_in(instruction_MEM_in),
    .DMemWR_MEM_in(DMemWR_MEM_in),
    .reg_wr_en_MEM_in(reg_wr_en_MEM_in),
    .WB_Sel_MEM_in(WB_Sel_MEM_in),
    .store_size_MEM_in(store_size_MEM_in),
    .load_size_MEM_in(load_size_MEM_in)
    //.jump_flag_MEM_in(jump_flag_MEM_in)
    );
    
    
    /************************************************************* MEM Satge *******************************************************************/
    
    logic [size-1 : 0] DMEM_out_MEM;
   
    
    data_mem DMem(
    .clk(clk),
    .address(ALU_out_MEM_in),
    .dataW_DMem(data2_EX_out_stored_hazard_mux),
    .DMemWR(DMemWR_MEM_in),
    .store_size(store_size_MEM_in),
    .load_size(load_size_MEM_in),
    // Output
    .dataR(DMEM_out_MEM) 
    );
    
    logic [size-1 : 0] PC_adder_out_MEM;
    
    PC_adder_MEM_Stage pc_adder_MEM(
    .PC_out(PC_MEM_in),
    // output
    .adder_PC_out(PC_adder_out_MEM) 
    );
    
    
    logic [size-1 : 0] PC_adder_out_WB_in;
    logic [size-1 : 0] ALU_out_WB_in;
    logic [size-1 : 0] DMEM_out_WB_in;
    logic [size-1 : 0] data1_WB_in;
    logic [size-1 : 0] data2_WB_in;
    
    logic [1:0] WB_Sel_WB_in;
    logic [size-1 : 0] PC_WB_in;
    
    /************************************************************* MEM / WB Satge Register *******************************************************************/
    
    // EX/MEM Stage Register Iplementation
    MEM_WB_Stage_Reg REG_MEM_WB(
    .clk(clk),
    .reset(reset),
    .PC_MEM_in(PC_MEM_in),
    .PC_adder_out_MEM(PC_adder_out_MEM),
    .ALU_out_MEM_in(ALU_out_MEM_in),
    .DMEM_out_MEM(DMEM_out_MEM),
    .data1_MEM_in(data1_MEM_in),
    .data2_MEM_in(data2_MEM_in),
    //.rd_MEM_in(rd_MEM_in),
    .instruction_MEM_in(instruction_MEM_in),
    .reg_wr_en_MEM_in(reg_wr_en_MEM_in),
    .WB_Sel_MEM_in(WB_Sel_MEM_in),
    
    // outputs
    .PC_WB_in(PC_WB_in),
    .PC_adder_out_WB_in(PC_adder_out_WB_in),
    .ALU_out_WB_in(ALU_out_WB_in),
    .DMEM_out_WB_in(DMEM_out_WB_in),
    .data1_WB_in(data1_WB_in),
    .data2_WB_in(data2_WB_in),
    //.rd_WB_in(rd_WB_in),
    .instruction_WB_in(instruction_WB_in),
    .reg_wr_en_WB_in(reg_wr_en_WB_in),
    .WB_Sel_WB_in(WB_Sel_WB_in)
    );
    
    /************************************************************* WB Satge *******************************************************************/    
   	
	logic [size-1:0] pc_4;
	assign pc_4 = PC_WB_in + 32'd4;

	mux_reg_write_back MUX(
	    .PC_adder_out(PC_adder_out_WB_in),
	    .ALU_out(ALU_out_WB_in),
	    .DMem_out(DMEM_out_WB_in),
	    .WB_Sel(WB_Sel_WB_in),
	    .MUX_WB_OUT(mux_wb_out) 
	    );
    
/*
	tracer tracer_ip (
	.clk_i(clk),
	.rst_ni(~reset),
	.hart_id_i(32'b0),
	.rvfi_valid(1'b1),
	.rvfi_insn_t(instruction_WB_in),
	.rvfi_rs1_addr_t(instruction_WB_in[19:15]),
	.rvfi_rs2_addr_t(instruction_WB_in[24:20]),
	.rvfi_rs1_rdata_t(data1_WB_in),
	.rvfi_rs2_rdata_t(data2_WB_in),
	.rvfi_rd_addr_t(instruction_WB_in[11:7]),
	.rvfi_rd_wdata_t(mux_wb_out),
	.rvfi_pc_rdata_t(PC_WB_in),
	.rvfi_pc_wdata_t(pc_4),
	.rvfi_mem_addr(0),
	.rvfi_mem_rmask(0),
	.rvfi_mem_wmask(0),
	.rvfi_mem_rdata(0),
	.rvfi_mem_wdata(0)
	);
 */   
endmodule

