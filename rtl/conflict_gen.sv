  
  module signal_gen_for_branch_mux(
  
  input YAGS_prediction_EX,
  input branch_jump_flag,
  output logic [1:0] branch_comp_MUX_select_EX,
  output logic conflict
  
  );
  
    always_comb
	    begin
	    
		    if( YAGS_prediction_EX == 1 && branch_jump_flag == 0 )	 // T/NT conflict
			    begin
			    	branch_comp_MUX_select_EX = 3;
			    	conflict = 1;
			    end
		    else if( YAGS_prediction_EX == 0 && branch_jump_flag == 1 )	 // NT/T conflict
			    begin
			    	branch_comp_MUX_select_EX = 1;
			    	conflict = 1;
			    end
		    else if(jump_flag_EX_in)					 // unconditional jump
			    begin
			    	branch_comp_MUX_select_EX = 2;
			    	conflict = 0;
			    end
		    else
			    begin
			    	branch_comp_MUX_select_EX = 0;			 // normal operation
			    	conflict = 0;
			    end	
	    end
	    
    endmodule
	    
