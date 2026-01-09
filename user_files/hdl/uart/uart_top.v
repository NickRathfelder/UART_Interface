`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 11:07:03 PM
// Design Name: 
// Module Name: uart_top
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


module uart_top # (
parameter BAUD_DIV = 32'd54
)(
    input clk_main,
    input rst_n,
    input [7:0] wr_in,
    input wr_stb,
    input rd_stb,
    input rx_pad,
    
    output [7:0] rd_out,
    output tx_pad,
    output rf_empty,
    output tf_full

    );
//Baud Rate Generator
reg [31:0] baud_counter;
reg _baud_clk;

wire clk_baud;
wire rst_n_baud;

wire tf_wr_en;
wire tf_fifo_full;

wire rf_rd_en;
wire rf_fifo_empty;
wire [7:0] receiver_out;

uart_baud_div #(.DIV_VAL(BAUD_DIV)) baud_gen(
    .clk_in(clk_main),
    .rst_n_in(rst_n),
    .clk_out(clk_baud),
    .rst_n_out(rst_n_baud)
);

//Transmitter
uart_transmitter uart_tf_inst(
    .clk_main(clk_main),
    .clk_tf(clk_baud),
    .rst_main_n(rst_n),
    .rst_tf_n(rst_n_baud),
    .fifo_wr(tf_wr_en),
    .tf_in(wr_in),
    .tf_full(tf_fifo_full),
    .transmitter_tx(tx_pad)
);

uart_receiver uart_rf_inst(
    .clk_main(clk_main),
    .clk_rf(clk_baud),
    .rst_main_n(rst_n),
    .rst_rf_n(rst_n_baud),
    .fifo_rd(rf_rd_en),
    .rf_out(receiver_out),
    .rf_empty(rf_fifo_empty),
    .transmitter_rx(rx_pad)
);
assign rf_empty = rf_fifo_empty;
assign tf_full = tf_fifo_full;

assign rf_rd_en = rd_stb && !rf_fifo_empty;
assign tf_wr_en = wr_stb && !tf_fifo_full;

assign rd_out = rf_rd_en ? receiver_out : 8'h0;

endmodule
