`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:18:33
// Design Name: 
// Module Name: dadda8_CLA
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module dadda8_CLA(
	input [7:0] A,
	input [7:0] B,
	input [15:0] M,
	output [16:0] RES);
	
	genvar i;
	wire [7:0][7:0] P;
	wire [1:0][15:0] PRE;
	gen_part_products U1(A,B,P);
	dadda_processing_block_8 U2(P,M,PRE);
	CLA16 adder16_CLA (.sum(RES[15:0]), .cout(RES[16]), .a(PRE[1]), .b(PRE[0])); //CLA16 RCA16 CSelA16 CSkipA16 KSA16
	
endmodule
