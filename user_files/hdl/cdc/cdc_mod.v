`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 08:59:34 PM
// Design Name: 
// Module Name: cdc_mod
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


module cdc_mod(
    input clk_core,
    input rst_async,
    input [3:0] sw_async,
    input [1:0] btn_async,
    
    output rst_n_filt,
    output [3:0] sw_filt,
    output [1:0] btn_filt 
    );

wire [3:0] sw_sync;
wire [1:0] btn_sync;

wire sw0_filt;
wire sw1_filt;
wire sw2_filt;
wire sw3_filt;

wire btn0_filt;
wire btn1_filt;

wire rst_filt;

//Synchronizers
synchronizer rst_synchronize(.clk(clk_core), .rst_n(1'b1), .s_i(rst_async), .s_o(rst_filt));
synchronizer #(.n(4)) sw_synchronize(.clk(clk_core), .rst_n(rst_filt), .s_i(sw_async), .s_o(sw_sync));
synchronizer #(.n(2)) btn_synchronize(.clk(clk_core), .rst_n(rst_filt), .s_i(btn_async), .s_o(btn_sync));

//Debouncers
debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) sw0_db(.clk(clk_core), .rst_n(rst_filt), .db_i(sw_sync[0]), .db_o(sw0_filt));
debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) sw1_db(.clk(clk_core), .rst_n(rst_filt), .db_i(sw_sync[1]), .db_o(sw1_filt));
debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) sw2_db(.clk(clk_core), .rst_n(rst_filt), .db_i(sw_sync[2]), .db_o(sw2_filt));
debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) sw3_db(.clk(clk_core), .rst_n(rst_filt), .db_i(sw_sync[3]), .db_o(sw3_filt));

debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) btn0_db(.clk(clk_core), .rst_n(rst_filt), .db_i(btn_sync[0]), .db_o(btn0_filt));
debouncer #(.DEBOUNCE_LENGTH_US(16'd10000)) btn1_db(.clk(clk_core), .rst_n(rst_filt), .db_i(btn_sync[1]), .db_o(btn1_filt));

assign sw_filt = {sw3_filt, sw2_filt, sw1_filt, sw0_filt};
assign btn_filt = {btn1_filt,btn0_filt};
assign rst_n_filt = rst_filt;

endmodule

