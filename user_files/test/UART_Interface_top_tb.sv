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

module UART_Interface_top_tb();
reg clk_100mhz_t;
reg sys_rst_i_t;
reg [3:0] sw_i_t;
wire terminal_rx_t;
reg [1:0] btn_i_t;

wire terminal_tx_t;
reg [3:0] led_t;

assign terminal_rx_t = 1'b1;

initial
begin
    clk_100mhz_t = 0;
    sys_rst_i_t = 0;
    sw_i_t = 4'b0000;
    btn_i_t = 2'b0;
    #10000    sys_rst_i_t = 1;
    #10000    sw_i_t = 4'b0010;
    #10000 btn_i_t = 2'b01;
    #5000000 btn_i_t = 2'b00;
    #20000000 btn_i_t = 2'b10;
    #2500000 btn_i_t = 2'b00;
    #2500000 btn_i_t = 2'b10;
    #2500000 btn_i_t = 2'b00;
    #2500000 btn_i_t = 2'b10;
    #2500000 btn_i_t = 2'b00;
    #2500000 btn_i_t = 2'b10;
    #2500000 btn_i_t = 2'b00;
    
end


always #(5) clk_100mhz_t= ~clk_100mhz_t;
UART_Interface_top dut(
    .clk_100mhz(clk_100mhz_t),
    .sys_rst_i(sys_rst_i_t),
    .sw_i(sw_i_t),
    .btn_i(btn_i_t),
    .terminal_rx(terminal_rx_t),
    .terminal_tx(terminal_tx_t),
    .led(led_t)
);


endmodule
