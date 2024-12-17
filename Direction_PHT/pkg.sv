package types;
	// Declare an enum type for saturated counter states
	typedef enum bit[1:0] {strongly_not_taken = 2'b00, weakly_not_taken = 2'b01, weakly_taken = 2'b10, strongly_taken = 2'b11} counter_states;
endpackage
