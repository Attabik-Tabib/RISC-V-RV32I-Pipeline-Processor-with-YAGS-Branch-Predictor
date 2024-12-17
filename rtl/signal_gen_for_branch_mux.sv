  
  module signal_gen_for_branch_mux(
	  input PHT_prediction_EX,
	  input actual_prediction,
	  input jump_flag_EX_in,
	  input YAGS_prediction_EX,
	  input branch_signal,
	  input clk,
	  // outputs
	  output logic [1:0] branch_comp_MUX_select_EX,
	  output logic PHT_conflict,
	  output logic YAGS_conflict
  	);
    
    int correct_branch_prediction, incorrect_branch_prediction, total_branches, actual_branches_taken, actual_branches_not_taken;
    always_comb
	    begin
	    
		    if( PHT_prediction_EX == 1 && actual_prediction == 0  && branch_signal)	// T/NT conflict
			    begin
			    	branch_comp_MUX_select_EX = 3;
			    	PHT_conflict = 1;
			    end
/*		    else
		    	conflict = 0;
*/		    	
		    else if( PHT_prediction_EX == 0 && actual_prediction == 1 && branch_signal)	// NT/T conflict
			    begin
			    	branch_comp_MUX_select_EX = 1;
			    	PHT_conflict = 1;
			    end
/*		    else
		    	conflict = 0;
*/		    	
		    else if(jump_flag_EX_in)						// unconditional jump
			    begin
			    	branch_comp_MUX_select_EX = 2;
			    	PHT_conflict = 0;
			    end
		    else
			    begin
			    	branch_comp_MUX_select_EX = 0;			// normal operation
			    	PHT_conflict = 0;
			    end
			
	    end
	    
    always_comb
	    begin
	    	if(YAGS_prediction_EX != actual_prediction && branch_signal)
		    	begin
		    		YAGS_conflict = 1;
		    		// total_branches ++ ;
	    		        //incorrect_branch_prediction ++ ;			
		    	end	
	    	else //if(YAGS_prediction_EX == actual_prediction && branch_signal)
		    	
		    	begin
		    		YAGS_conflict = 0 ;
		    	//	total_branches++ ;
		    	//	correct_branch_prediction++ ;	
		    	end
    	    end
    	  
    	    	    
	always_ff @(negedge clk)
		begin
			
            if(branch_signal && YAGS_prediction_EX == actual_prediction)
                correct_branch_prediction ++ ;
                
            else if(branch_signal &&  YAGS_prediction_EX != actual_prediction)
                incorrect_branch_prediction ++ ;
				
			
	        if(branch_signal && actual_prediction)
                actual_branches_taken ++ ;
                
            else if(branch_signal && !actual_prediction)
                actual_branches_not_taken ++ ;
				
				
				$display("Total Branches = %0d, Branches Actually Taken = %0d, Branches Actually Not Taken = %0d, Correct Branches Predicted = %0d, Incorrect Braches Predicted = %0d \n", correct_branch_prediction + incorrect_branch_prediction, actual_branches_taken, actual_branches_not_taken, correct_branch_prediction, incorrect_branch_prediction);   

		end
		
		
	
	
endmodule    
	    
