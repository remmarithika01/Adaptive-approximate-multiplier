`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:39:39
// Design Name: 
// Module Name: top8_step1
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
module top8_1step_CLA16( input [7:0]x, input [7:0]y, output [16:0]prod    );
    wire p[7:0][7:0];
    wire [15:0]PRE1;
    wire [15:0]PRE2;
    
    assign PRE1[15] = 1'b0;
    assign PRE2[15] = 1'b0;
    
    generate_partial_products_8 generate_partial_products_8(.x(x),.y(y),.P(p));  
    processing_block_8_1step processing_block_8_1step( .p(p), .out1(PRE1[14:0]) ,.out2(PRE2[14:0]));      
    CLA16 CLA16 (.sum(prod[15:0]), .cout(prod[16]), .a(PRE1), .b(PRE2)); //CLA16 RCA16 CSelA16 CSkipA16 KSA16
endmodule
