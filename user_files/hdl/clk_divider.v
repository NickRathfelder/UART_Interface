`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 01:38:43 AM
// Design Name: 
// Module Name: clk_divider
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


module clk_divider #(parameter DIV_VAL = 32'h2)
(
    input wire clk_in,
    input wire rst_n_in,
    
    output wire clk_out,
    output wire rst_n_out
    );
    
    reg _clk_out;
    reg [31:0] counter = 32'h0;
    
    always @(posedge clk_in)
    begin
        counter <= counter +32'b1;
        _clk_out <= (counter < DIV_VAL/2) ? 1'b1 : 1'b0;
        if(counter > DIV_VAL) counter <= 32'h0;
    end
    
    synchronizer rst_sync_inst (.clk(_clk_out), .rst_n(1'b1), .s_i(rst_n_in), .s_o(rst_n_out));
   
    assign clk_out = _clk_out;
    
endmodule
