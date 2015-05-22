`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:33:08 03/01/2015 
// Design Name: 
// Module Name:    cache_defines 
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
`define FLASH		2'b00
`define READ		2'b01
`define WRITE		2'b10
`define INVALID	2'b11

`define MISS	1'b0
`define HIT		1'b1

`define CACHE_ENABLE		1'b0
`define CACHE_DISABLE	1'b1

`define TAG_ENTRY_INVALID	1'b0
`define TAG_ENTRY_VALID		1'b1

`define L1_CACHE_ACCESS	0
`define L2_CACHE_ACCESS	1
`define CACHE_SWAP		3
`define CACHE_SWAP_WAIT	4
`define NON_CACHED_DATA	5

`define LOG2(width) 	(width<=2)?1:\
							(width<=4)?2:\
							(width<=8)?3:\
							(width<=16)?4:\
							(width<=32)?5:\
							(width<=64)?6:\
							(width<=128)?7:\
							(width<=256)?8:\
							-1;
							
							
							