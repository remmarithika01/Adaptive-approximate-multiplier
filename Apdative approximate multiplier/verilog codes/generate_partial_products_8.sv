`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:22:46
// Design Name: 
// Module Name: generate_partial_products_8
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

module generate_partial_products_8(
	input [7:0]x,
	input [7:0]y,
	output P[7:0][7:0] ); 	//portlist can be 2D array in verilog 
	genvar i,j;
	generate
		for(i = 0; i < 8; i = i +1) begin:part_product
		  for(j = 0; j < 8; j = j +1) begin
			assign P[i][j] = x[j] & y[i] ;
		  end
		end
	endgenerate
endmodule
