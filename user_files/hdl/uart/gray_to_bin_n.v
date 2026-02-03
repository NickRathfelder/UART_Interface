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


module  gray_to_bin_n #(
    parameter n = 4
    )(
        input [n-1:0] in_g,
        output [n-1:0] out_b
    );
    
    genvar i;
    
    generate for (i=n-1; i > 0; i = i-1) 
    begin
        assign out_b[i-1] = in_g[i-1] ^ out_b[i];
    end
    endgenerate
    
    assign out_b[n-1] = in_g[n-1];
endmodule
