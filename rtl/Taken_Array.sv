
module Taken_Array #(parameter PC_size = 10, GHR_size = 10, Tag_size = 9, valid_bit_position = 11) ( 
	input clk, rst,
	input [ PC_size - 1 : 0 ] Current_PC,
	input [ PC_size - 1 : 0 ] PC_from_branch_comp,
	input [ GHR_size - 1 : 0 ] GHR,
	input PHT_prediction_EX,
	input PHT_prediction,
	input actual_prediction,
	input branch_signal,
	input [ PC_size - 1 : 0 ] Taken_Arr_Index_EX,
	input branch,		// branch instruction indication in Fetch Stage 
	input Taken_Arr_hit_EX,
	// outputs
	output logic [ PC_size - 1 : 0 ] Taken_Arr_Index,
	output logic Taken_Arr_prediction,
	output logic Taken_Arr_hit
	 );
	 
	logic [ Tag_size + 2 : 0 ] Taken_Arr [ 0 : (2**Tag_size)-1 ];
	localparam [ 1:0 ]  strongly_not_taken_state = 0, weakly_not_taken_state = 1, weakly_taken_state = 2, strongly_taken_state = 3;
	logic valid_bit; 
	logic [ 1:0 ] T_next_state; 
	//logic [ PC_size - 1 : 0 ] temp_Taken_Arr_Index;
	logic [ Tag_size - 1 : 0 ] Taken_Arr_Tag;
	int T_hit_index;
	int NT_replacment_index;

	assign Taken_Arr_Tag = Current_PC;		// Array Tag = Address/PC
	assign Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	assign valid_bit = 1;
	
	// assign temp_Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	
	// Set Default values on reset.
	always_ff @(negedge clk or negedge rst) 
		begin
		    if(!rst)
			    begin

			    	for (int i = 0; i < 2**PC_size; i++)
					begin
						Taken_Arr[i] <= {!valid_bit, {Tag_size{1'b0}}, weakly_taken_state};
					end 
					
					//the valid bit will go high once and and then therorughout the program it remains one; it means that the location was filled  once atleast thouthgpu the program
			    end
			    
		    else 
                begin	
			    	if( !PHT_prediction_EX && actual_prediction && branch_signal && Taken_Arr_hit_EX) // || Taken_Arr_hit_EX && branch_signal) ) 
			    		begin
			    			Taken_Arr[Taken_Arr_Index_EX][Tag_size + 1 : 2] <= PC_from_branch_comp;
			    			Taken_Arr[Taken_Arr_Index_EX][1 : 0] <= T_next_state;
			    			Taken_Arr[Taken_Arr_Index_EX][valid_bit_position] <= valid_bit;
			    		end
			    	
			    	// update on miss	
                    else if( !PHT_prediction_EX && actual_prediction && !Taken_Arr_hit_EX && branch_signal ) //|| (actual_prediction && branch_signal) )
                        begin
                            for(int i = 0; i < 2**Tag_size ; i++)
                                begin
                                    if(Taken_Arr[i][valid_bit_position] == 1'b0)
                                            begin
                                                NT_replacment_index = i;
                                                Taken_Arr[i][Tag_size + 1 : 2] <= PC_from_branch_comp;  //PC form the execution stage
                                                Taken_Arr[i][1 : 0] <= T_next_state;
                                                Taken_Arr[i][valid_bit_position] <= valid_bit;
                                                break;
                                            end
                                    else
                                        continue;
                                end   
                        end
                        
                    else
                            Taken_Arr <= Taken_Arr;
                        end
                end
	                                                                       
	// searching algorithm
	always_comb
		begin
		
			if(!PHT_prediction && branch )	// PHT_prediction is not_taken   //is this needed?
				begin
					for(int i = 0; i < (2**Tag_size); i++)
						begin
							if( Taken_Arr[i][Tag_size + 1 : 2] == Taken_Arr_Tag )
								
								begin
									T_hit_index = i;
									Taken_Arr_prediction = Taken_Arr[i][1];
									Taken_Arr_hit = 1;
									break;
								end
                            
                            else
                                begin 
                                    Taken_Arr_prediction = Taken_Arr_prediction;
                                    Taken_Arr_hit = 0;
                                    continue;
                                end
                        end
                end
          
        /*    if(!PHT_prediction && branch )	// PHT_prediction is not_taken   //is this needed?
                begin
                    if( Taken_Arr[Taken_Arr_Index][Tag_size + 1 : 2] == Taken_Arr_Tag )
                        
                        begin
                            Taken_Arr_prediction = Taken_Arr[Taken_Arr_Index][1];
                            Taken_Arr_hit = 1;
                        end					
          */         
			else	
				begin 
					Taken_Arr_prediction = 1'bx;
					Taken_Arr_hit = 1'b0;
					// break;
				end		
		end
		    	
    	always_comb
		begin
			case(Taken_Arr[PC_from_branch_comp][1:0]) // This will be updated based on the value of array index from EX stage
				
				strongly_not_taken_state: 
							begin
							
								if( actual_prediction && branch_signal) 
									T_next_state = weakly_not_taken_state;
								else if ( !actual_prediction && branch_signal )
									T_next_state = strongly_not_taken_state;	
							end						
				weakly_not_taken_state: 
							begin
								if( actual_prediction && branch_signal ) 
									T_next_state = weakly_taken_state;
								else if ( !actual_prediction && branch_signal )
									T_next_state = strongly_not_taken_state;				
							end						
				weakly_taken_state: 
							begin
								if( actual_prediction && branch_signal )
									T_next_state = strongly_taken_state;                
								else if ( !actual_prediction && branch_signal )
									T_next_state = weakly_not_taken_state;							
							end 						
				strongly_taken_state:
							begin
								if( actual_prediction && branch_signal ) 
									T_next_state = strongly_taken_state;
								else if( !actual_prediction && branch_signal )
									T_next_state = weakly_taken_state;							
							end 			
			endcase
		end
endmodule
/*

module Taken_Array #(parameter PC_size = 6, GHR_size = 6, Tag_size = 6) ( 
	input clk, rst,
	input [ PC_size - 1 : 0 ] Current_PC,
	input [ PC_size - 1 : 0 ] PC_from_branch_comp,
	input [ GHR_size - 1 : 0 ] GHR,
	input PHT_prediction_EX,
	input PHT_prediction,
	input actual_prediction,
	input branch_signal,
	input [ PC_size - 1 : 0 ] Taken_Arr_Index_EX,
	input branch,		// branch instruction indication in Fetch Stage 
	// outputs
	output logic [ PC_size - 1 : 0 ] Taken_Arr_Index,
	output logic Taken_Arr_prediction,
	output logic Taken_Arr_hit
	 );
	 
	logic [ PC_size + 1 : 0 ] Taken_Arr [ 0 : (2**PC_size)-1 ];
	localparam [ 1:0 ]  strongly_not_taken_state = 0, weakly_not_taken_state = 1, weakly_taken_state = 2, strongly_taken_state = 3;
	logic valid_bit; 
	logic [ 1:0 ] T_next_state; 
	//logic [ PC_size - 1 : 0 ] temp_Taken_Arr_Index;
	logic [ Tag_size - 1 : 0 ] Taken_Arr_Tag;
	int T_hit_index;
	
	assign Taken_Arr_Tag = Current_PC;		// Array Tag = Address/PC
	assign Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	assign valid_bit = 1;
	
	// assign temp_Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	
	// Set Default values on reset.
	always_ff @(negedge clk or negedge rst) 
		begin
		    if(!rst)
			    begin

			    	for (int i = 0; i < 2**PC_size; i++)
					begin
						Taken_Arr[i] <= {!valid_bit, {Tag_size{1'b0}}, weakly_taken_state};
					end 
					
					//the valid bit will go high once and and then therorughout the program it remains one; it means that the location was filled  once atleast thouthgpu the program
			    end
			    
		    else 
		    	begin	
			    	if(Taken_Arr[Taken_Arr_Index_EX][8] == !valid_bit && PHT_prediction_EX == actual_prediction && actual_prediction && branch_signal)
			    		begin
			    			Taken_Arr[Taken_Arr_Index_EX][Tag_size + 1 : 2] <= PC_from_branch_comp;
			    			Taken_Arr[Taken_Arr_Index_EX][1 : 0] <= T_next_state;
			    			Taken_Arr[Taken_Arr_Index_EX][8] <= valid_bit;
			    		end
			    		
			    		
			    	// choice PHT = NT, actual outcome  = taken   
			    	// Taken Array used	
			    	// Taken Array prediction equals actual outcome
		    		//if( ((!PHT_prediction_EX && actual_prediction) || Taken_Arr_hit || (actual_prediction == Taken_Arr_prediction) || actual_prediction) && branch_signal)	
		    		else if( !PHT_prediction_EX && actual_prediction && branch_signal) //|| (actual_prediction && branch_signal) )
				   	begin
						Taken_Arr[Taken_Arr_Index_EX][Tag_size + 1 : 2] <= PC_from_branch_comp;  //PC form the execution stage
						Taken_Arr[Taken_Arr_Index_EX][1 : 0] <= T_next_state;
						Taken_Arr[Taken_Arr_Index_EX][8] <= valid_bit;
				    	end
		    		else
		    				Taken_Arr <= Taken_Arr;
		    	end
	    	end
	                                                                       
	// searching algorithm
	always_comb
		begin
			if(!PHT_prediction && branch)	// PHT_prediction is not_taken   //is this needed?
				begin
					for(int i = 0; i < (2**PC_size); i++)
						begin
							if( Taken_Arr[i][Tag_size + 1 : 2] == Taken_Arr_Tag )
								
								begin
									T_hit_index = i;
									Taken_Arr_prediction = Taken_Arr[i][1];
									Taken_Arr_hit = 1;
									break;
								end
								
							else
								begin 
									Taken_Arr_prediction = Taken_Arr_prediction;
									Taken_Arr_hit = 0;
									continue;
								end
						end
				end
	
			else	
				begin 
					Taken_Arr_prediction = 1'bx;
					Taken_Arr_hit = 1'b0;
					// break;
				end		
		end
		    	
    	always_comb
		begin
			case(Taken_Arr[PC_from_branch_comp][1:0]) // This will be updated based on the value of array index from EX stage
				
				strongly_not_taken_state: 
							begin
							
								if( actual_prediction && branch_signal) 
									T_next_state = weakly_not_taken_state;
								else if ( !actual_prediction && branch_signal )
									T_next_state = strongly_not_taken_state;	
							end						
				weakly_not_taken_state: 
							begin
								if( actual_prediction && branch_signal ) 
									T_next_state = weakly_taken_state;
								else if ( !actual_prediction && branch_signal )
									T_next_state = strongly_not_taken_state;				
							end						
				weakly_taken_state: 
							begin
								if( actual_prediction && branch_signal )
									T_next_state = strongly_taken_state;                
								else if ( !actual_prediction && branch_signal )
									T_next_state = weakly_not_taken_state;							
							end 						
				strongly_taken_state:
							begin
								if( actual_prediction && branch_signal ) 
									T_next_state = strongly_taken_state;
								else if( !actual_prediction && branch_signal )
									T_next_state = weakly_taken_state;							
							end 			
			endcase
		end
endmodule
*/