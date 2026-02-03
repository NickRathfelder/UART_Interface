`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 12:16:11 PM
// Design Name: 
// Module Name: digital_oscilloscope_top_tb
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
`timescale 1ns / 1ps

module uart_fifo_tb();
reg clk_100mhz_t;
reg clk_16mhz_t;
reg rst_wr_n_t;
reg rst_rd_n_t;
reg [7:0] din_t;
reg wr_en_t;
reg rd_en_t;

wire full_t;
wire empty_t;
wire [7:0] dout_t;

initial
begin
    clk_100mhz_t = 0;
    rst_wr_n_t = 0;
    din_t = 8'h00;
    wr_en_t = 0;

    clk_16mhz_t = 0;  
    rst_rd_n_t = 0;
    rd_en_t = 0;
    #1000;
    @(posedge clk_100mhz_t);
    rst_wr_n_t = 1;
    @(posedge clk_16mhz_t);
    rst_rd_n_t = 1;
    repeat (5) @(posedge clk_100mhz_t);
    din_t = 8'h10;
    wr_en_t = 1;
    @(posedge clk_100mhz_t);
    din_t = 8'h11;
    @(posedge clk_100mhz_t);
    din_t = 8'h12;
    @(posedge clk_100mhz_t);
    din_t = 8'h13;
    wr_en_t = 0;
    @(posedge clk_100mhz_t);
    @(posedge clk_16mhz_t);
    rd_en_t = 1;
    repeat (5) @(posedge clk_16mhz_t);
    rd_en_t = 0;
    @(posedge clk_100mhz_t);
    wr_en_t = 1;
    din_t = 8'hab;
    repeat (2047) @(posedge clk_100mhz_t);
    din_t = 8'h11;
    @(posedge clk_100mhz_t);
    wr_en_t = 0;
end

always #(5) clk_100mhz_t= ~clk_100mhz_t;
always #(31.25) clk_16mhz_t= ~clk_16mhz_t;
uart_fifo_v2 dut(
    .wr_clk(clk_100mhz_t),
    .rd_clk(clk_16mhz_t),
    .rst_wr_n(rst_wr_n_t),
    .rst_rd_n(rst_rd_n_t),
    .din(din_t),
    .wr_en(wr_en_t),
    .rd_en(rd_en_t),
    .full(full_t),
    .empty(empty_t),
    .dout(dout_t)
);

endmodule
