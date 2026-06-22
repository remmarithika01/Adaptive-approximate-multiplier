
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:35:29
// Design Name: 
// Module Name: tb_values
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
`timescale 1ns/1ps

module tb_processing_block;

//--------------------------------
// Image size
//--------------------------------
parameter IMG_SIZE = 571590;


//--------------------------------
// Pixel memories
//--------------------------------
reg [7:0] R_mem [0:IMG_SIZE-1];
reg [7:0] G_mem [0:IMG_SIZE-1];
reg [7:0] B_mem [0:IMG_SIZE-1];


//--------------------------------
// Exact output image
//--------------------------------
reg [7:0] exact_R [0:IMG_SIZE-1];
reg [7:0] exact_G [0:IMG_SIZE-1];
reg [7:0] exact_B [0:IMG_SIZE-1];


//--------------------------------
// Approx output image
//--------------------------------
reg [7:0] approx_R [0:IMG_SIZE-1];
reg [7:0] approx_G [0:IMG_SIZE-1];
reg [7:0] approx_B [0:IMG_SIZE-1];


//--------------------------------
// Multiplier inputs
//--------------------------------
reg [7:0] A;
reg [7:0] GAIN;


//--------------------------------
// Approx multiplier output
//--------------------------------
wire [16:0] prod_top1;

integer i;


//--------------------------------
// Error metrics
//--------------------------------
integer exact_val;
integer error1;
integer abs_error1;

integer total_tests;
integer error_count1;

integer sum_abs_error1;
integer sum_sq_error1;

real MAE1;
real MSE1;
real ER1;


//--------------------------------
// File for metrics
//--------------------------------
integer metrics_file;


//--------------------------------
// DUT
//--------------------------------
top8_1step_CLA16 DUT1 (
    .x(A),
    .y(GAIN),
    .prod(prod_top1)
);


//--------------------------------
// Simulation
//--------------------------------
initial begin

//--------------------------------
// Initialize
//--------------------------------
GAIN = 8'd7;

$readmemh("R.mem",R_mem);
$readmemh("G.mem",G_mem);
$readmemh("B.mem",B_mem);


//--------------------------------
// Metrics init
//--------------------------------
total_tests = 0;
error_count1 = 0;

sum_abs_error1 = 0;
sum_sq_error1 = 0;


//--------------------------------
// Process pixels
//--------------------------------
for(i=0;i<IMG_SIZE;i=i+1)
begin

//--------------------------------
// R channel
//--------------------------------
A = R_mem[i];
#1;

exact_val = A * GAIN;

exact_R[i]  = (exact_val > 255) ? 255 : exact_val[7:0];
approx_R[i] = (prod_top1 > 255) ? 255 : prod_top1[7:0];

error1 = exact_val - prod_top1;
abs_error1 = (error1 < 0) ? -error1 : error1;

sum_abs_error1 = sum_abs_error1 + abs_error1;
sum_sq_error1  = sum_sq_error1 + (error1*error1);

if(error1 != 0)
error_count1 = error_count1 + 1;

total_tests = total_tests + 1;


//--------------------------------
// G channel
//--------------------------------
A = G_mem[i];
#1;

exact_val = A * GAIN;

exact_G[i]  = (exact_val > 255) ? 255 : exact_val[7:0];
approx_G[i] = (prod_top1 > 255) ? 255 : prod_top1[7:0];

error1 = exact_val - prod_top1;
abs_error1 = (error1 < 0) ? -error1 : error1;

sum_abs_error1 = sum_abs_error1 + abs_error1;
sum_sq_error1  = sum_sq_error1 + (error1*error1);

if(error1 != 0)
error_count1 = error_count1 + 1;

total_tests = total_tests + 1;


//--------------------------------
// B channel
//--------------------------------
A = B_mem[i];
#1;

exact_val = A * GAIN;

exact_B[i]  = (exact_val > 255) ? 255 : exact_val[7:0];
approx_B[i] = (prod_top1 > 255) ? 255 : prod_top1[7:0];

error1 = exact_val - prod_top1;
abs_error1 = (error1 < 0) ? -error1 : error1;

sum_abs_error1 = sum_abs_error1 + abs_error1;
sum_sq_error1  = sum_sq_error1 + (error1*error1);

if(error1 != 0)
error_count1 = error_count1 + 1;

total_tests = total_tests + 1;

end


//--------------------------------
// Write output images
//--------------------------------
$writememh("exact_R.mem",exact_R);
$writememh("exact_G.mem",exact_G);
$writememh("exact_B.mem",exact_B);

$writememh("approx_R.mem",approx_R);
$writememh("approx_G.mem",approx_G);
$writememh("approx_B.mem",approx_B);


//--------------------------------
// Metrics calculation
//--------------------------------
MAE1 = sum_abs_error1 * 1.0 / total_tests;
MSE1 = sum_sq_error1 * 1.0 / total_tests;
ER1  = error_count1 * 1.0 / total_tests;


//--------------------------------
// Write metrics to file
//--------------------------------
metrics_file = $fopen("metrics_results.txt","w");

$fdisplay(metrics_file,"=================================");
$fdisplay(metrics_file,"TOTAL TESTS = %d",total_tests);
$fdisplay(metrics_file,"APPROX MULTIPLIER RESULTS");
$fdisplay(metrics_file,"MAE = %f",MAE1);
$fdisplay(metrics_file,"MSE = %f",MSE1);
$fdisplay(metrics_file,"ER  = %f",ER1);
$fdisplay(metrics_file,"=================================");

$fclose(metrics_file);


//--------------------------------
// Display in console
//--------------------------------
$display("=================================");
$display("TOTAL TESTS = %d",total_tests);
$display("APPROX MULTIPLIER RESULTS");
$display("MAE = %f",MAE1);
$display("MSE = %f",MSE1);
$display("ER  = %f",ER1);
$display("=================================");

$finish;                                                                             

end

endmodule
