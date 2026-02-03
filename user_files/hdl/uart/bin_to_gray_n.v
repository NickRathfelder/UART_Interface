`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2026 11:56:21 AM
// Design Name: 
// Module Name: gray_code_n
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


module  bin_to_gray_n #(
    parameter n = 4
    )(
        input [n-1:0] in_b,
        output [n-1:0] out_g
    );
    
    genvar i;
    
    generate for (i=0; i < n-1; i = i+1) 
    begin
        assign out_g[i] = in_b[i] ^ in_b[i+1];
    end
    endgenerate
    assign out_g[n-1] = in_b[n-1];
endmodule
