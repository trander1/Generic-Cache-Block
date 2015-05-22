`timescale 1ns / 1ps
`include "cache_defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:33:56 03/01/2015 
// Design Name: 
// Module Name:    cache 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cache(
    data_out, data_out_miss, tag_out_miss, hit_miss_out,    
    vector_in, clk, enable    
    );
// parameters for the module	
parameter TAG_WIDTH = 16;			// width of the tag
parameter DATA_WIDTH = 32;			// width of the data
parameter ENTRIES_WIDTH = 128;	// # of entries
parameter OPCODE_WIDTH = 2;		// width of opcode
parameter LINE_WIDTH = TAG_WIDTH+DATA_WIDTH+OPCODE_WIDTH; // length of the input vector 
parameter ENTRIES_BIT_WIDTH = `LOG2(ENTRIES_WIDTH); // length of the input vector 
// outputs of the module
output reg [DATA_WIDTH-1:0]data_out;// final output of the block
output reg [DATA_WIDTH-1:0]data_out_miss;// final output of the block
output reg [TAG_WIDTH-1:0]tag_out_miss;			// tag bits miss in the write task
output reg hit_miss_out;				// outputs the hit/miss of the block
// inputs of the module
input [LINE_WIDTH-1:0]vector_in;		// input vector
input clk;									// input clk 
input enable;								// input enable
// the final cache block vector array
reg [DATA_WIDTH-1:0]cache_block[ENTRIES_WIDTH-1:0];
// cache tag entries
reg [TAG_WIDTH-1:0]tag_entries[ENTRIES_WIDTH-1:0];
// cache valid bit entries
reg [ENTRIES_WIDTH-1:0]tag_valid_invalid_bit;
// local module variables
reg [OPCODE_WIDTH-1:0]control_in;				// control bits for the module obtained from the input vector
reg [TAG_WIDTH-1:0]tag_in;		// tag bits for the module obtained from the input vector
reg [DATA_WIDTH-1:0]data_in;	// data bits for the module obtained from the input vector
reg [DATA_WIDTH-1:0]temp_data_out;	// data bits for the module obtained from the input vector
reg hit_entry;						// internal hit/miss entry used between tasks
reg [ENTRIES_BIT_WIDTH:0]mru_entry;		// tag bits for replacement policy
// count variable
reg [ENTRIES_BIT_WIDTH:0]for_cnt_entries;	// general variable for the FOR loop
// initialize the variables
initial 
begin
	// initializing the outputs
	data_out = {DATA_WIDTH-1{1'b0}};
	temp_data_out = {DATA_WIDTH-1{1'b0}};
	data_out_miss = {DATA_WIDTH-1{1'b0}};
	tag_out_miss = {TAG_WIDTH-1{1'b0}};
//	hit_miss_out = 1'b0;
	control_in = {OPCODE_WIDTH-1{1'b0}};
	tag_in = {TAG_WIDTH-1{1'b0}};
	data_in = {DATA_WIDTH{1'b0}};
	for_cnt_entries = {ENTRIES_BIT_WIDTH{1'b0}};
	mru_entry = {ENTRIES_WIDTH-1{1'b0}};	
	// initializing the various required regs
	for(for_cnt_entries = {ENTRIES_WIDTH-1{1'b0}}; for_cnt_entries < ENTRIES_WIDTH; for_cnt_entries = for_cnt_entries + 1)
	begin
//		tag_entries[for_cnt_entries]={TAG_WIDTH-1{1'b0}};
		cache_block[for_cnt_entries]={DATA_WIDTH-1{1'b0}};
		tag_valid_invalid_bit[for_cnt_entries]=1'b0;
	end	
	$display("TAG:%d, DATA:%d, ENTRIES:%d, LINE: %d",TAG_WIDTH,DATA_WIDTH,ENTRIES_WIDTH,LINE_WIDTH);
end

// task for reading the cache entries
task cache_read_task;
	output [DATA_WIDTH-1:0]data_task_out;
	output hit_miss;
	output [ENTRIES_BIT_WIDTH:0]hit_cache_entry;
	input [TAG_WIDTH-1:0]tag_check;
	
	// loop variable
	reg [ENTRIES_BIT_WIDTH:0]entries_count;

	begin: label_cache_read
		entries_count = {ENTRIES_WIDTH-1{1'b0}};
		data_task_out = {DATA_WIDTH-1{1'b0}};
		hit_miss = `MISS;
		hit_cache_entry = {ENTRIES_BIT_WIDTH{1'b0}};
		// loop for going through the cache tag entries
		repeat(ENTRIES_WIDTH)
		begin
			$display("entries_count:%d, tag_entries:%d, tag_check:%d",entries_count,tag_entries[entries_count],tag_check);					
			// check tag entry first
			if(tag_entries[entries_count] == tag_check)
			begin
				// tag match, check the line validity/invalidity
				$display("READ TASK, tag_valid_invalid_bit:%d",tag_valid_invalid_bit[entries_count]);
				if(tag_valid_invalid_bit[entries_count] == `TAG_ENTRY_VALID)
				begin				
					// line valid, give out the data, the cache entry, generate a hit and disable the loop
					data_task_out = cache_block[entries_count];
					mru_entry = entries_count;
					hit_cache_entry = entries_count;					
					hit_miss = `HIT;
					$display("DISABLED READ REPEAT, valid hit_cache_entry:%d",hit_cache_entry);
					disable label_cache_read;
				end else
					begin
						// line invalid, generate a hit and disable the loop
//						data_task_out = cache_block[entries_count];
						mru_entry = entries_count;
						hit_cache_entry = entries_count;						
						hit_miss = `HIT;
						$display("DISABLED READ REPEAT, invalid hit_cache_entry:%d",hit_cache_entry);
						disable label_cache_read;
					end
			end // tag not present		
			entries_count = entries_count + 1;
		end
	end
endtask

// task for searching available cache entry
task cache_search_task;
	output [DATA_WIDTH-1:0]data_task_out;
	output hit_miss;
	output [ENTRIES_BIT_WIDTH:0]hit_cache_entry;
	input [TAG_WIDTH-1:0]tag_check;
	
	// loop variable
	reg [ENTRIES_BIT_WIDTH:0]entries_count;

	begin: label_cache_read
		entries_count = {ENTRIES_WIDTH-1{1'b0}};
		data_task_out = {DATA_WIDTH-1{1'b0}};
		hit_miss = 1'b0;
		hit_cache_entry = {ENTRIES_BIT_WIDTH{1'b0}};
		// loop for going through the cache tag entries
		repeat(ENTRIES_WIDTH)
		begin
			$display("entries_count:%d, tag_entries:%d, tag_check:%d",entries_count,tag_entries[entries_count],tag_check);					
			// check the line validity/invalidity
			if(tag_valid_invalid_bit[entries_count] == tag_check)
			begin				
				// line invalid, give out the data, the cache entry, generate a hit and disable the loop
//				data_task_out = cache_block[entries_count];
				mru_entry = entries_count;				
				hit_cache_entry = entries_count;
				hit_miss = `HIT;
				$display("DISABLED READ REPEAT, hit_cache_entry:%d",hit_cache_entry);
				disable label_cache_read;
			end else
				begin
					// line invalid, generate a hit and disable the loop
//						data_task_out = cache_block[entries_count];
					if(entries_count > ENTRIES_WIDTH)
					begin
						hit_cache_entry = entries_count;
						hit_miss = `MISS;
//					$display("DISABLED READ REPEAT, hit_cache_entry:%d",hit_cache_entry);
//					disable label_cache_read;
					end
				end
			entries_count = entries_count + 1;
		end
	end
endtask

// task for writing a cache entry
task cache_write_task;
output [DATA_WIDTH-1:0]data_task_out;
output [DATA_WIDTH-1:0]data_miss_out;
output [TAG_WIDTH-1:0]tag_miss_out;
output hit_miss;
output [ENTRIES_BIT_WIDTH:0]hit_cache_entry;
input [TAG_WIDTH-1:0]tag_check;
input [ENTRIES_WIDTH-1:0]tag_replacement_entry;
input [DATA_WIDTH-1:0]data_task_in;

begin	
	data_miss_out = {DATA_WIDTH-1{1'b0}};
	tag_miss_out = {TAG_WIDTH-1{1'b0}};
	hit_miss = 1'b0;
	hit_cache_entry = {ENTRIES_BIT_WIDTH{1'b0}};	
	// check the cache for the validity of the tag to be written
	cache_read_task(data_task_out,hit_miss,hit_cache_entry,tag_check);
	if(hit_miss == `HIT)
	begin
		// HIT: cache entry available, data overwritten in the cache entry
		$display("Cache Read HIT, hit_miss:%d, hit_cache_entry:%d, tag_check:%d, data_task_in:%d",hit_miss, hit_cache_entry, tag_check, data_task_in);
//		tag_valid_invalid_bit[hit_cache_entry] = `TAG_ENTRY_VALID;		
		cache_block[hit_cache_entry] = data_task_in;		
	end else 
		begin			
			// MISS: cache entry not-available, find the next available location
//			tag_miss_out = tag_entries[mru_entry];
//			data_miss_out = cache_block[mru_entry];
			$display("Cache Read MISS");
			cache_search_task(data_task_out,hit_miss,hit_cache_entry,`TAG_ENTRY_INVALID);			
			if(hit_miss == `HIT)
			begin
				// HIT: cache has an availalbe entry, use that location for storing new data
				$display("Cache Search HIT, hit_miss:%d, hit_cache_entry:%d, tag_check:%d, data_task_in:%d",hit_miss, hit_cache_entry, tag_check, data_task_in);
				tag_valid_invalid_bit[hit_cache_entry] = `TAG_ENTRY_VALID;
				tag_entries[hit_cache_entry] = tag_check;
				cache_block[hit_cache_entry] = data_task_in;
			end else	
				begin
					// MISS: cache full, DO SOMETHING BETTER THAN THIS
					// currently filling a single location of the cache
					$display("Cache Full MISS, hit_miss:%d, hit_cache_entry:%d, tag_replacement_entry:%d, data_task_in:%d",hit_miss, hit_cache_entry, tag_replacement_entry, data_task_in);
					tag_valid_invalid_bit[tag_replacement_entry] = `TAG_ENTRY_VALID;
					tag_entries[tag_replacement_entry] = tag_check;
					cache_block[tag_replacement_entry] = data_task_in;
				end
		end	
	tag_miss_out = tag_entries[mru_entry];
	data_miss_out = cache_block[mru_entry];
	data_task_out = {DATA_WIDTH-1{1'b0}};	
	$display("Cache out, tag_miss_out:%d, data_miss_out:%d", tag_miss_out, data_miss_out);
end	
endtask

always @(posedge clk)
begin
	if(enable == `CACHE_ENABLE)begin
		control_in = vector_in[LINE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH];
		tag_in = vector_in[LINE_WIDTH-OPCODE_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH-TAG_WIDTH];
		data_in = vector_in[LINE_WIDTH-OPCODE_WIDTH-TAG_WIDTH-1:LINE_WIDTH-OPCODE_WIDTH-TAG_WIDTH-DATA_WIDTH];
		$display("control: %d,tag_in: %d,data_in: %d",control_in, tag_in, data_in);
		case(control_in)
			`FLASH: 
					begin
						$display("FLASH");
						for(for_cnt_entries = {ENTRIES_WIDTH-1{1'b0}}; for_cnt_entries < ENTRIES_WIDTH; for_cnt_entries = for_cnt_entries + 1)
						begin
							tag_entries[for_cnt_entries]={TAG_WIDTH-1{1'b0}};						
							tag_valid_invalid_bit[for_cnt_entries]=`TAG_ENTRY_INVALID;
						end
					end	
			`READ: 
					begin
						$display("CACHE READ");
						cache_read_task(data_out,hit_miss_out,hit_entry,tag_in);					
						$display("READ DATA %d", data_out);
					end	
			`WRITE: 
					begin					
						$display("WRITE DATA %d", data_in);
						cache_write_task(data_out,data_out_miss,tag_out_miss,hit_miss_out,hit_entry,tag_in,mru_entry,data_in);						
						$display("CACHE WRITE");
					end
			`INVALID: $display("INVLAID");
			default: $display("WRONG VALUE");
		endcase
	end	
end	

endmodule

