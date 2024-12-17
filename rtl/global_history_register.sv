
module global_history_register #(parameter GHR_size = 10) ( 
	input clk,
	input rst,
	input branch_signal,
	input actual_prediction,
	output logic [ GHR_size - 1 : 0 ] GHR	
	);
		
	always_ff @(negedge clk or negedge rst)
		begin
			if (!rst)
				GHR <= 'h0;
			else 
				begin
					if(branch_signal)  
							//this was introduced here	
						GHR <= { GHR[GHR_size - 2 : 0] , actual_prediction };
					else 
						GHR <= GHR;
				end
		end		
endmodule
