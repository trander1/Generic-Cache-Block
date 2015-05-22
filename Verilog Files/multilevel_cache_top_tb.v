`timescale 1ns / 1ps
`include "cache_defines.vh"
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:54:33 03/12/2015
// Design Name:   multilevel_cache_top
// Module Name:   D:/Modelsim Projects/Xilinx/cache_implementation/multilevel_cache_top_tb.v
// Project Name:  cache_implementation
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: multilevel_cache_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module multilevel_cache_top_tb;
// parameters for the module	
parameter CACHE_TAG_WIDTH = 4;			// width of the tag
parameter CACHE_DATA_WIDTH = 4;			// width of the data

parameter CACHE1_ENTRIES_WIDTH = 1;		// # of entries of cache 1
parameter CACHE2_ENTRIES_WIDTH = 16;	// # of entries of cache 2

parameter OPCODE_WIDTH = 2;		// width of opcode

parameter CACHE_LINE_WIDTH = CACHE_TAG_WIDTH+CACHE_DATA_WIDTH+OPCODE_WIDTH; // length of the input vector 

parameter CACHE1_ENTRIES_BIT_WIDTH = `LOG2(CACHE1_ENTRIES_WIDTH); // length of the input vector 
parameter CACHE2_ENTRIES_BIT_WIDTH = `LOG2(CACHE2_ENTRIES_WIDTH); // length of the input vector 
// outputs of the module
wire [CACHE_DATA_WIDTH-1:0]data_out;// final output of the block
wire hit_miss_out;				// outputs the hit/miss of the block
// inputs of the module
reg [CACHE_LINE_WIDTH-1:0]vector_in;		// input vector
reg clk;									// input clk
//reg enable;								// input enable
reg [CACHE_TAG_WIDTH-1:0]tag_count;
reg [CACHE_DATA_WIDTH-1:0]data_test;

// Instantiate the Unit Under Test (UUT)
multilevel_cache_top #(CACHE_TAG_WIDTH,CACHE_DATA_WIDTH,CACHE1_ENTRIES_WIDTH,CACHE2_ENTRIES_WIDTH) multilevel_cacheblock (
	.data_out(data_out), 
	.hit_miss_out(hit_miss_out), 
	.vector_in(vector_in), 
	.clk(clk)	
);

	initial begin
		// Initialize Inputs		
		clk = 0;
//		enable = 0;
		// Wait 100 ns for global reset to finish

		#15 vector_in = {2'b01,4'b1100,4'b1010};	// read initialize tag entry
		#15 vector_in = {2'b01,4'b0101,4'b1010};	// reads data from L2
		#25 vector_in = {2'b01,4'b1110,4'b1010};	// 		
		#15 vector_in = {2'b01,4'b0101,4'b1010};	//				
		#25 vector_in = {2'b01,4'b1100,4'b1010};
		#25 vector_in = {2'b01,4'b1110,4'b1010};
		#25 vector_in = {2'b01,4'b1100,4'b1010};
//		#4 tag_count = {CACHE_TAG_WIDTH{1'b1}}; vector_in = {2'b01,tag_count,data_test};	// read such tag entry
	//		repeat(ENTRIES_WIDTH)begin: bench3
	//			#2 vector_in = {2'b10,tag_count,data_test};	// write to a new tag entry every time
	//			#2 vector_in = {2'b01,tag_count,data_test};	// read such tag entry
	//			tag_count = tag_count + 1'b1;
	//			data_test = data_test + 1'b1;
	//		end 	// end repeat loop
		#50 $finish;
	end
      
	always begin
		#1 clk = ~clk; // Toggle clock every 1 ticks
	end		
endmodule

