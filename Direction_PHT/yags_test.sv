
module yags_test;
timeunit 1ns;
timeprecision 1ns;
	// Define parameters
	localparam GHR_SIZE = 10;
	localparam PC_SIZE =  10;
                                                                                                                                                                                                                                                                                                                                                  
	// Test Bench Signals
	logic miss_predict;
	logic update;
	logic [PC_SIZE-1 : 0] address;
	logic [GHR_SIZE-1 : 0] history;
	logic [PC_SIZE-1 : 0]  read_address;
	logic [GHR_SIZE-1 : 0] read_history;
	logic [1:0] actual_prediction;
	logic out;
	logic hit;
	logic miss;

	// direction_pht instantiation
	direction_PHT dir_pht (.*);
	
	initial
	 begin
	 	address = 10'h011; history = 10'h001; read_address = 10'h012; read_history = 10'h001;  miss_predict = 1'b0; update = 1'b0; actual_prediction = 2'b01; 
	 	#10;
	 	address = 10'h0FE; history = 10'h001; read_address = 10'h000; read_history = 10'h000;  miss_predict = 1'b1; update = 1'b0; actual_prediction = 2'b10; 
	 	#10;
	 	address = 10'h011; history = 10'h001; read_address = 10'h0FE; read_history = 10'h001;  miss_predict = 1'b0; update = 1'b0; actual_prediction = 2'b01; 
	 	#10;
	 	address = 10'h0AB; history = 10'h001; read_address = 10'h12; read_history = 10'h001;   miss_predict = 1'b1; update = 1'b0; actual_prediction = 2'b11;
	 	#10;
	 	address = 10'h011; history = 10'h001; read_address = 10'h0AB; read_history = 10'h001;  miss_predict = 1'b0; update = 1'b0; actual_prediction = 2'b01; 
	 	#10;
	 	address = 10'h012; history = 10'h001; read_address = 10'h000; read_history = 10'h000;  miss_predict = 1'b1; update = 1'b0; actual_prediction = 2'b10; 
	 	#10;
	 	address = 10'h0AB; history = 10'h001; read_address = 10'h12; read_history = 10'h001;   miss_predict = 1'b0; update = 1'b0; actual_prediction = 2'b11;
	 	#10;
	 	address = 10'h012; history = 10'h001; read_address = 10'h000; read_history = 10'h000;  #2 miss_predict = 1'b0; update = 1'b1; actual_prediction = 2'b10; 
	 	#10;
	 	address = 10'h012; history = 10'h001; read_address = 10'h012;; read_history = 10'h001;  miss_predict = 1'b0; update = 1'b0; actual_prediction = 2'b10; 
	 	#50 $finish;
	 end

endmodule
