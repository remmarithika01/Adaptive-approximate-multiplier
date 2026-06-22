`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2026 22:29:09
// Design Name: 
// Module Name: compressor
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


module FA(input [2:0]p, output [2:1]w   );  // w[2] = carry ;  w[1] =sum
   xor sum(w[1], p[2],p[1],p[0]);
   wire ab,bc,ca;
   and a1(ab,p[2],p[1]);
   and a2(bc,p[1],p[0]);
   and a3(ca,p[0],p[2]);
   or carry(w[2], ab,bc,ca);
endmodule

module HA(input [1:0]p, output [2:1]w);
    xor sum(w[1],p[0],p[1]);
    and carry(w[2],p[0],p[1]);
endmodule

module full_adder(input a,input b, input c_in ,output sum,output carry); //dadda8
assign sum = a ^ b ^ c_in;
assign carry = (a & b) +(b & c_in) + (a & c_in);
endmodule // full_adder

module half_adder(input a, input b,output  sum, output  carry); //dadda8
assign sum = a ^ b;
assign carry = a & b;
endmodule // half_adder

module compressor3_2(input [2:0]p, output [2:1]w); //  p2,p1,p0, output w1,w2);
   // wire a1;
    and u1(a1 , p[0] , p[1]); //assign a1 = p0 & p1;
    or  u2(w[2] , a1 , p[2]);  //assign w2 = a1 | p2;
    or  u3(w[1] , p[0] , p[1]);  //assign w1 = p0 |p1;
    //assign w[2][0] = p[2][0] | p[1][1] | p[0][2];
    // assign w[2][1] = 1'b0;  // kill carry

endmodule

module compressor4_2(input [3:0]p, output [2:1]w);  // p3,p2,p1,p0, output w2,w1);
    wire a1,a2;
    and u1(a1 , p[0] , p[1]);     //assign a1 = p0 & p1;
    and u2(a2 , p[2] , p[3]);     //assign a2 = p2 & p3;
    or u3(w[2] , a1 , p[2] , p[3]); //assign w2 = a1 | p2 | p3;
    or u4(w[1] , a2 , p[0] , p[1]); //assign w1 = a2 | p0 | p1;
   
endmodule

module compressor5_3(input [4:0]p, output [3:1]w); //  p4,p3,p2,p1,p0, output w3,w2,w1);
    wire a1,a2;
    and u1(a1 , p[0] , p[1]);      //assign a1 = p0 & p1;
    and u2(a2 , p[2] , p[3]);      //assign a2 = p2 & p3;
    or u3(w[3] , p[0] , p[1]);       //assign w3 = p0 | p1;
    or u4(w[1] , a1 , p[2] , p[3]);  //assign w1 = a1 | p2 | p3;
    or u5(w[2] , a2 , p[4]);       //assign w2 = a2 | p4;
endmodule

module compressor6_3(input [5:0]p, output [3:1]w); //  p5,p4,p3,p2,p1,p0, output w3,w2,w1);
    wire a1,a2,a3;
    and u1(a1 , p[0] , p[1]);      //assign a1 = p0 & p1;
    and u2(a2 , p[2] , p[3]);      //assign a2 = p2 & p3;
    and u3(a3 , p[4] , p[5]);      //assign a3 = p4 & p5;
    or u4(w[1] , a1 , p[2] , p[3]);  //assign w1 = a1 | p2 | p3;
    or u5(w[3] , a2 , p[4] , p[5]);  //assign w3 = a2 | p4 | p5;
    or u6(w[2] , a3 , p[0] , p[1]);  //assign w2 = a3 | p0 | p1;
endmodule


//////////////////////////////////////// higher order compressors //////////////////////

module compressor7_4(input [6:0]p, output [4:1]w);
    compressor4_2 u1(.p(p[6:3]), .w(w[4:3]));
    compressor3_2 u2(.p(p[2:0]), .w(w[2:1]));
endmodule

module compressor8_4(input [7:0]p, output [4:1]w);
    compressor4_2 u1(.p(p[7:4]), .w(w[4:3]));
    compressor4_2 u2(.p(p[3:0]), .w(w[2:1]));
endmodule
