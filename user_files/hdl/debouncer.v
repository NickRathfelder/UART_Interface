`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 08:37:01 PM
// Design Name: 
// Module Name: debouncer
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

module debouncer #(
parameter DEBOUNCE_LENGTH_US = 16'd10000
) (
    input clk,
    input rst_n,
    input db_i,
    output db_o
    );

localparam [31:0] db_count = DEBOUNCE_LENGTH_US * 100; //10 ms
reg db_reg;
reg[19:0] db_timer;
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n) 
    begin
        db_timer <= db_count;
        db_reg <= db_i;
    end
    else
    begin
        if(db_i != db_reg)
        begin
            if(db_timer == 20'h0)
            begin
                db_reg <= db_i;
                db_timer <= db_count;
            end
            else db_timer <= db_timer -1;
        end
    end
    
end

assign db_o = db_reg;
    
endmodule


