
// Defning YAGS branch Predictor

/* GHS_size: Global History Register Size
   PC_size: Program Counter Address Size
   cache_depth
   cache_tag_width
*/

module YAGS_branch_predictor #(parameter GHR_size = 10, PC_size = 10) (
	input clk,	// system clock
	input rst,	// system reset
	input actual_prediction,			// autual prediction from branch comparator
	input branch,					// In fetch stage, if the current instruction is a bracnh instrutcion
	input PHT_conflict,				// to handle conflicts between actual and predicted branches in EX Stage 
	input [GHR_size - 1 : 0] PC,			// curretn PC (Address)
	input [GHR_size - 1 : 0] PC_from_branch_comp,	// Address from branch comparator
	input branch_signal,				// Branch instruction check in EX Stage
	input [ GHR_size - 1 : 0 ] GHR,			// Global Hisory Register
	input Taken_Arr_prediction,
	input Taken_Arr_hit,
	input Not_Taken_Arr_prediction,
	input Not_Taken_Arr_hit, 
	input T_NT_Arr_hit_EX,
	input Taken_Arr_prediction_EX,
	input NOT_Taken_Arr_prediction_EX,
	// outputts
	output bit PHT_prediction, 			// Intermediate prediction of paettern history table	
	output logic YAGS_prediction, 			// Final prediction
	output logic T_NT_Arr_hit			// YAGS Final output mux selection line
	);
	
	
	localparam [1:0]  strongly_not_taken_state = 0, weakly_not_taken_state = 1, weakly_taken_state = 2, strongly_taken_state = 3;
	logic [1:0] Choice_PHT [0 : (2**PC_size) -1];
	
	logic [1:0] next_state; 
	// logic T_NT_Arr_hit;			// Taken/Not Taken Array Hit Result
	logic T_NT_Arr_prediction_selection;	// To selectwhch Array decison will be forwarded to final selection mux
	
	// defining global history register
	always_ff @(negedge clk or negedge rst)
		begin
			if(!rst)
				begin
					//GHR <= 'h0;
					// PHT_prediction <= 0;
					
					// next_state <= strongly_not_taken_state;
					
					for (int i = 0; i < 2**PC_size; i++)
						begin
					//	  Choice_PHT[i] <= strongly_not_taken_state;
						
						
    /*                        if(i%2 == 0)
                                Choice_PHT[i] <= weakly_not_taken_state;
                            else
                                Choice_PHT[i] <= weakly_taken_state;
     */            
                  
							    if(i%3 == 0)							
                                    Choice_PHT[i] <= weakly_not_taken_state;
                                else if(i%5 == 0)							
                                    Choice_PHT[i] <= weakly_taken_state;
                                else if(i%7 == 0)							
                                    Choice_PHT[i] <= weakly_not_taken_state;
                                else if(i%9 == 0)
                                    Choice_PHT[i] <= weakly_taken_state;
                                else
                                    Choice_PHT[i] <= weakly_not_taken_state;    
						end
				end
            
			else 
                begin
                    if(!PHT_conflict && !T_NT_Arr_hit_EX && branch_signal) // && (actual_prediction == Taken_Arr_prediction_EX || actual_prediction == NOT_Taken_Arr_prediction_EX) )
				        begin
                            Choice_PHT[PC_from_branch_comp] <= next_state;  //PC form the execution stage
                            //PHT_prediction = Choice_PHT[PC][1];
				        end
                     
                    else if ( (!PHT_conflict && Taken_Arr_prediction_EX != actual_prediction && branch_signal) || (PHT_conflict && NOT_Taken_Arr_prediction_EX != actual_prediction && branch_signal)) 
                            Choice_PHT[PC_from_branch_comp] <= next_state;    
                    else
                            Choice_PHT[PC_from_branch_comp] <=  Choice_PHT[PC_from_branch_comp];
                end
               
										
		end
		
	// GHR Update
	always_comb
		begin				
			// PHT Prediction Logic
			if(branch)	// T_NT_Arr_prediction_selection
				begin
					//GHR <= { GHR[GHR_size - 2 : 0] , actual_prediction }; //removed from this place
					PHT_prediction = Choice_PHT[PC][1];		// Only MSB of states is used to make a decison either "taken" or "not taken"
					// $display("PATTERN_HISTORY_TABLE => INDEX: %d, STATE: %d", PC, next_state);
				end
			 else
			 	begin
			 		PHT_prediction = 1'bx;
			 	end
			 	
			 			
						
		end
		
	// 2bc state assignment
	always_comb
		begin
			case(Choice_PHT[PC_from_branch_comp]) //and here the state of previous 
				
				strongly_not_taken_state: 
							begin
								if( actual_prediction && branch_signal) 
									next_state = weakly_not_taken_state;
								else if (!actual_prediction && branch_signal)
									next_state = strongly_not_taken_state;
                                else
                                    next_state = next_state;
							end
							
				weakly_not_taken_state: 
							begin
								if( actual_prediction && branch_signal ) 
									next_state = weakly_taken_state;
								else if ( !actual_prediction && branch_signal )
									next_state = strongly_not_taken_state;
                                else
                                    next_state = next_state;
							end
							
				weakly_taken_state: 
							begin
								if( actual_prediction && branch_signal )
									next_state = strongly_taken_state;                
								else if ( !actual_prediction && branch_signal )
									next_state = weakly_not_taken_state;
                                else
                                    next_state = next_state;
							end 			
				
				strongly_taken_state:
							begin
								if( actual_prediction && branch_signal ) 
									next_state = strongly_taken_state;
								else if( !actual_prediction && branch_signal )
									next_state = weakly_taken_state;
                                else
                                    next_state = next_state;
							end 			
			endcase
		end
	
	// Control Logic for YAGS Branch Prediction
	always_comb
		begin
			if(PHT_prediction && branch)
				T_NT_Arr_hit = Not_Taken_Arr_hit;
			else 
				T_NT_Arr_hit = Taken_Arr_hit;
		end
	
	always_comb
		begin
			if(PHT_prediction && branch)
				begin
					T_NT_Arr_prediction_selection = Not_Taken_Arr_prediction;
				end
			else
				T_NT_Arr_prediction_selection = Taken_Arr_prediction;
		end
	
	always_comb
		begin
			if(T_NT_Arr_hit && branch)
				YAGS_prediction = T_NT_Arr_prediction_selection;
			else
				YAGS_prediction = PHT_prediction;
		end
/*		
	always_comb
	begin
		if(YAGS_prediction == actual_prediction)
			correct_branch_prediction ++ ;
		else
			incorrect_branch_prediction ++;
		
		$display("Total Branches = %0d, ", total_branches);
	end
*/	
	
endmodule
