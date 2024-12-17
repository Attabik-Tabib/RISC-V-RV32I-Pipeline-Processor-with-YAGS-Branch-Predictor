
module Not_Taken_Array #(parameter PC_size = 10, GHR_size = 10, Tag_size = 9, valid_bit_position = 11) ( 
	input clk, rst,
	input [ PC_size - 1 : 0 ] Current_PC,
	input [ PC_size - 1 : 0 ] PC_from_branch_comp,
	input [ GHR_size - 1 : 0 ] GHR,
	input PHT_prediction_EX,
	input PHT_prediction,
	input actual_prediction,
	input branch_signal,
	input [ PC_size - 1 : 0 ] Not_Taken_Arr_Index_EX,
	input branch,		// branch instruction indication in Fetch Stage 
	input Not_Taken_Arr_hit_EX,
	// outputs
	output logic [ PC_size - 1 : 0 ] Not_Taken_Arr_Index,
	output logic Not_Taken_Arr_prediction,
	output logic Not_Taken_Arr_hit
	 );
	 
	logic [ Tag_size + 2 : 0 ] Not_Taken_Arr [ 0 : (2**Tag_size)-1 ];
	localparam [ 1:0 ]  strongly_not_taken_state = 0, weakly_not_taken_state = 1, weakly_taken_state = 2, strongly_taken_state = 3;
	logic valid_bit; 
	logic [ 1:0 ] NT_next_state; 
	//logic [ PC_size - 1 : 0 ] temp_Not_Taken_Arr_Index;
	logic [ Tag_size - 1 : 0 ] Not_Taken_Arr_Tag;
	int NT_hit_index;
	int T_replacment_index;
	
	assign Not_Taken_Arr_Tag = Current_PC;		// Array Tag = Address/PC
	assign Not_Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	// assign Not_Taken_Arr_Index = Current_PC ^ GHR;	// Array index
	assign valid_bit = 1;
	
	// Set Default values on reset.
	always_ff @(negedge clk or negedge rst) 
		begin
		    if(!rst)
			    begin

			    	for (int i = 0; i < 2**PC_size; i++)
					begin
						Not_Taken_Arr[i] <= {!valid_bit,{Tag_size{1'b0}}, weakly_not_taken_state};
					end 
					
					//the valid bit will go high once and and then therorughout the program it remains one; it means that the location was filled  once atleast thouthgpu the program
			    end
			    
		    else 
                begin	
			    	if( PHT_prediction_EX && !actual_prediction && branch_signal && Not_Taken_Arr_hit_EX) // || (Not_Taken_Arr_hit_EX && branch_signal) )
			    		begin
			    			Not_Taken_Arr[Not_Taken_Arr_Index_EX][Tag_size + 1 : 2] <= PC_from_branch_comp;
			    			Not_Taken_Arr[Not_Taken_Arr_Index_EX][1 : 0] <= NT_next_state;
			    			Not_Taken_Arr[Not_Taken_Arr_Index_EX][valid_bit_position] <= valid_bit;
			    		end
			    	
			    	// update on miss	
                    else if( PHT_prediction_EX && !actual_prediction && !Not_Taken_Arr_hit_EX && branch_signal) //|| (actual_prediction && branch_signal) )
                        begin
                            for(int i = 0; i < 2**Tag_size ; i++)
                                begin
                                    if(Not_Taken_Arr[i][valid_bit_position] == 1'b0)
                                            begin
                                                T_replacment_index =i;
                                                Not_Taken_Arr[i][Tag_size + 1 : 2] <= PC_from_branch_comp;  //PC form the execution stage
                                                Not_Taken_Arr[i][1 : 0] <= NT_next_state;
                                                Not_Taken_Arr[i][valid_bit_position] <= valid_bit;
                                                break;
                                            end
                                    else
                                        continue;
                                end   
                        end
                    
                    else
                            Not_Taken_Arr <= Not_Taken_Arr;
                        end
                end
	                                                                       
	// searching algorithm
	always_comb
		begin
		
			if(PHT_prediction && branch )	// PHT_prediction is not_taken   //is this needed?
				begin
					for(int i = 0; i < 2**Tag_size ; i++)
						begin
							if( Not_Taken_Arr[i][Tag_size + 1 : 2] == Not_Taken_Arr_Tag )
								
								begin
									NT_hit_index = i;
									Not_Taken_Arr_prediction = Not_Taken_Arr[i][1];
									Not_Taken_Arr_hit = 1;
									break;
								end
                            
                            else
                                begin 
                                    Not_Taken_Arr_prediction = Not_Taken_Arr_prediction;
                                    Not_Taken_Arr_hit = 0;
                                end
                        end
                end
        	
         /*   if( PHT_prediction && branch )	// PHT_prediction is not_taken   //is this needed?
                begin
                    if( Not_Taken_Arr[Not_Taken_Arr_Index][Tag_size + 1 : 2] == Not_Taken_Arr_Tag )
                        begin
                            Not_Taken_Arr_prediction = Not_Taken_Arr[Not_Taken_Arr_Index][1];
                            Not_Taken_Arr_hit = 1;
                        end
        */
 
			else	
				begin 
					Not_Taken_Arr_prediction = 1'bx;
					Not_Taken_Arr_hit = 1'b0;
					// break;
				end		
		end
		    	
    	always_comb
            begin
                case(Not_Taken_Arr[PC_from_branch_comp][1:0]) // This will be updated based on the value of array index from EX stage
                    
                    strongly_not_taken_state: 
                                begin
                                
                                    if( actual_prediction && branch_signal) 
                                        NT_next_state = weakly_not_taken_state;
                                    else if ( !actual_prediction && branch_signal )
                                        NT_next_state = strongly_not_taken_state;	
                                end						
                    weakly_not_taken_state: 
                                begin
                                    if( actual_prediction && branch_signal ) 
                                        NT_next_state = weakly_taken_state;
                                    else if ( !actual_prediction && branch_signal )
                                        NT_next_state = strongly_not_taken_state;				
                                end						
                    weakly_taken_state: 
                                begin
                                    if( actual_prediction && branch_signal )
                                        NT_next_state = strongly_taken_state;                
                                    else if ( !actual_prediction && branch_signal )
                                        NT_next_state = weakly_not_taken_state;							
                                end 						
                    strongly_taken_state:
                                begin
                                    if( actual_prediction && branch_signal ) 
                                        NT_next_state = strongly_taken_state;
                                    else if( !actual_prediction && branch_signal )
                                        NT_next_state = weakly_taken_state;							
                                end 			
                endcase
            end
endmodule
