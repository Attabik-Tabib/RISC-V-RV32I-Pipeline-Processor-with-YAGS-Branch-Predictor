import types::*;
// Cache (PHT) specs: Associativity => 2-way 
// No. of sets = 32, No. of blocks = 64, No. of words/block = 8, WordSize = 2b
// DEPTH specifies the total blocks in the Direction Pattern History Table (PHT) cache
// GHR_SIZE is the total bits in the Global History Register
// PC_SIZE specifies the Program Counter bits

module direction_PHT #(parameter DEPTH = 64, parameter GHR_SIZE = 10, parameter PC_SIZE = 10)
(                                                                                                                                                                                                                                                                                                                                                                    
	input bit miss_predict,
	input bit update,
	input [PC_SIZE-1 : 0] address,
	input [GHR_SIZE-1 : 0] history,
	input [PC_SIZE-1 : 0]  read_address,
	input [GHR_SIZE-1 : 0] read_history,
	input [1:0] actual_prediction,
	output bit out,
	output bit hit,
	output bit miss
);
timeunit 1ns;
timeprecision 1ns;
	
	// Compute minimum ghr register 
	localparam ghr_index = $clog2(DEPTH); 
	
	// Compute tag size
	localparam tag_size  = $clog2(GHR_SIZE - ghr_index);
	
	// Generate effective addresses to index into the tag_store and data_store for write and update
	logic [ghr_index-1 : 0] effective_addr_tag;
	logic [GHR_SIZE-2  : 0] effective_addr_data;
	logic [ghr_index-1 : 0] next_effective_addr_tag;
	
	assign effective_addr_tag  = address[ghr_index+1 : 2] ^ history[ghr_index-1 : 0];
	assign effective_addr_data = address[PC_SIZE-2   : 0] ^ history[GHR_SIZE-2  : 0];
	
	// Generate effective addresses to index into the tag_store and data_store for read operation
	logic [ghr_index-1 : 0] effective_addr_tag_r;
	logic [GHR_SIZE-2  : 0] effective_addr_data_r;
	logic [ghr_index-1 : 0] next_effective_addr_tag_r;
	
	assign effective_addr_tag_r  = read_address[ghr_index+1 : 2] ^ read_history[ghr_index-1 : 0];
	assign effective_addr_data_r = read_address[PC_SIZE-2   : 0] ^ read_history[GHR_SIZE-2  : 0];
	
	// Local variables
	bit [tag_size-1 : 0] tag, tag_r;
	bit LRU;
	bit valid;
	bit dirty;
	bit[ghr_index-1:0] write_addr;
	bit[ghr_index-1:0] read_addr;
	bit[ghr_index-2:0] mask = 1;
	bit[ghr_index-2:0] entry, entry_r, entry_write, entry_read;
	counter_states prediction, curr_state, next_state, correct_prediction;
	bit buffer;
	buf (buffer, miss_predict);

	
	// For a 10-bit PC; the address is divided as:
	//		  - 2-tag bits 
	//		  - 5-bits for set index
	//		  - 3-bits for byte offset
	
	// Tag store entry comprises:
	//		  - 1 Valid bit
	//		  - 1 LRU bit
	//   		  - 1 dirty bit
	//		  - 2-tag bits 
	
	// Array declaration for tag store 
	logic [ghr_index-2 : 0] tag_store [DEPTH-1 : 0];
	
	// Array declaration for data store
	counter_states data_store [2**(GHR_SIZE-1)-1 : 0];
	
	// Store those instances in the dir PHT which donot agree with the prediction from choice PHT
	always_comb
	begin   // Check if the current instance is not already in the DIR PHT and a miss-prediction occurs
		if (!((tag == entry[tag_size-1:0] || tag == entry_write[tag_size-1:0]) && (entry != 0 || entry_write != 0)) && buffer)
		begin
			valid = 1'b1;
			dirty = 1'b0;
			LRU   = 1'b0;
			
			// If the block selected by GHR is empty, then write to this block 
			if (entry[ghr_index-2] == 1'b0)  
			begin
				tag_store[effective_addr_tag] = {valid, LRU, dirty, tag};
				
				// set the other block as victim if valid
				if (entry_write[ghr_index-2] == 1'b1)
					tag_store[write_addr] |=  mask << (GHR_SIZE - ghr_index - 1); 	
			end // Otherwise write to the remaining block if empty
			else if (entry_write[ghr_index-2] == 1'b0) 
			begin	
				tag_store[write_addr] = {valid, LRU, dirty, tag};	
				
				// set the first block as victim
				tag_store[effective_addr_tag] |= mask << (GHR_SIZE - ghr_index - 1); 
			end // Apply LRU to overwrite victim block
			else 
			begin
				if (entry[ghr_index-3] == 1'b1) 
				begin
					tag_store[effective_addr_tag] = {valid, LRU, dirty, tag};
					
					// make this as victim block
					tag_store[write_addr] |=  mask << (GHR_SIZE - ghr_index - 1); 
				end
				else begin
					tag_store[write_addr] = {valid, LRU, dirty, tag};
					
					// set the remaining block as victim 
					tag_store[effective_addr_tag] |= mask << (GHR_SIZE - ghr_index - 1); 
				end	
			end
			
			// Write to the corresponding block location in the data store 
			data_store[effective_addr_data] = correct_prediction;
		end
	end
	
	// Check for cache HIT/MISS
	always_comb
	begin
		// Check for tag match
		// Access prediction at hit location
		if ((tag_r == entry_r[tag_size-1:0] || tag_r == entry_read[tag_size-1:0]) && (entry_r != 0 || entry_read != 0)) 
		begin
			hit = 1'b1;
			miss = 1'b0;
			prediction = data_store[effective_addr_data_r];
		end
		else 
		begin
			miss = 1'b1;
			hit  = 1'b0;
		end	
	end

	// casting enum type
	assign correct_prediction = counter_states'(actual_prediction);
	
	// Local variable assingnment for block address calculation 
	assign next_effective_addr_tag = effective_addr_tag + 1;
	assign next_effective_addr_tag_r = effective_addr_tag_r + 1;
		
	// Compute tag from current read address 
	assign tag_r = read_address[GHR_SIZE-1 : GHR_SIZE-tag_size];
		
	// Access the read address tag_store entry
	assign entry_r = tag_store[effective_addr_tag_r];
	
	// Compute read address for the other block in the set
	assign read_addr =  next_effective_addr_tag_r[ghr_index-1 : 1] == effective_addr_tag_r[ghr_index-1 : 1] ? effective_addr_tag_r + 1 : effective_addr_tag_r - 1;
	
	// Compute tag from current write address 
	assign tag = address[GHR_SIZE-1 : GHR_SIZE-tag_size];
		
	// Access the write address tag_store entry
	assign entry = tag_store[effective_addr_tag];
	
	// Compute write address for the other block in the set
	assign write_addr = next_effective_addr_tag[ghr_index-1 : 1] == effective_addr_tag[ghr_index-1 : 1] ? effective_addr_tag + 1 : effective_addr_tag - 1;
	
	assign entry_read = tag_store[read_addr];
	
	assign entry_write = tag_store[write_addr];
	
	// Update DIR PHT only after branch outcome is finalised
	always_comb
	begin   // Check if the instance to update is already in the (DIR PHT) cache and update is asserted
		if ((entry != 0 || entry_write != 0) && (tag == entry[tag_size-1:0] || tag == entry_write[tag_size-1:0]) && update)
		begin   
			// Obtain current state of addressed branch instance
			curr_state = data_store[effective_addr_data];
			
			// state transition
			if (!miss_predict)
			begin
				if (curr_state == strongly_not_taken)
					next_state = strongly_not_taken;
				else if (curr_state == weakly_not_taken)
					next_state = strongly_not_taken;
				else if (curr_state == weakly_taken)
					next_state = strongly_taken;
				else if (curr_state == strongly_taken)
					next_state = strongly_taken;	
			end
			else 
			begin
				if (curr_state[1] == 1'b0)
					next_state = weakly_taken;
				else 
					next_state = weakly_not_taken;
			end
			
			// Write back to the data_store
			data_store[effective_addr_data] = next_state;
		end
	end
	
	// Out only the MSB
	assign out = prediction[1:1];
	
endmodule
