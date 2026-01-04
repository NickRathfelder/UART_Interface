`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 10:05:44 PM
// Design Name: 
// Module Name: UART_Interface_top
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


module UART_Interface_top(
    input clk_100mhz,
    input sys_rst_i,
    input [3:0] sw_i,
    input [1:0] btn_i,
    
    input terminal_rx,
    output terminal_tx,
    output [3:0] led
    );
    
    
    //Filtered Inputs
    wire [3:0] sw;
    wire [1:0] btn;
    wire rst_main_n;
    
    //Message ROM
    reg [127:0] msg_cur = 128'h0;
    reg [3:0] addr;
    reg we;
    
    //Message Shift Register
    wire end_message;
    
    wire load_shift_reg;
    wire load_nxt_char;
    wire clear_shift_reg;
    
    reg [127:0] shift_reg;
    wire [7:0] cur_char;
    
    //UART
    reg [1:0] _btn;
    reg [1:0] __btn;
    wire btn0_pulse;
    wire btn1_pulse;
    reg [7:0] uart0_din;
    wire[7:0] uart0_dout;
    wire uart0_rf_empty;
    
    //LED Out
    reg[3:0] led_out;
    
    (* rom_style = "block" *) reg [127:0] msg_rom [0:15];
    
    //Initialize ROM
    initial
    begin
        msg_rom[0] = 128'h0d4d4553534147455f305f53454e5400;
        msg_rom[1] = 128'h0d4d4553534147455f315f53454e5400;
        msg_rom[2] = 128'h0d4d4553534147455f325f53454e5400;
        msg_rom[3] = 128'h0d4d4553534147455f335f53454e5400;
        msg_rom[4] = 128'h0d4d4553534147455f345f53454e5400;
        msg_rom[5] = 128'h0d4d4553534147455f355f53454e5400;
        msg_rom[6] = 128'h0d4d4553534147455f365f53454e5400;
        msg_rom[7] = 128'h0d4d4553534147455f375f53454e5400;
        msg_rom[8] = 128'h0d4d4553534147455f385f53454e5400;
        msg_rom[9] = 128'h0d4d4553534147455f395f53454e5400;
        msg_rom[10] = 128'h0d4d4553534147455f31305f53454e54;
        msg_rom[11] = 128'h0d4d4553534147455f31315f53454e54;
        msg_rom[12] = 128'h0d4d4553534147455f31325f53454e54;
        msg_rom[13] = 128'h0d4d4553534147455f31335f53454e54;
        msg_rom[14] = 128'h0d4d4553534147455f31345f53454e54;
        msg_rom[15] = 128'h0d4d4553534147455f31355f53454e54;
    end

    // ROM Reading
    always @(posedge clk_100mhz) 
    begin
        msg_cur <= msg_rom[sw];
    end
    
    cdc_mod cdc_main(
        .clk_core(clk_100mhz),
        .rst_async(sys_rst_i),
        .sw_async(sw_i),
        .btn_async(btn_i),
        .rst_n_filt(rst_main_n),
        .sw_filt(sw),
        .btn_filt(btn)
    );
    
    //Shift register logic
    always @(posedge clk_100mhz)
    begin
        if (~rst_main_n) shift_reg <= 128'h0;
        else
        begin
            if(load_shift_reg) shift_reg <= msg_cur;
            else if (load_nxt_char) shift_reg <= {shift_reg[119:0],8'h0};
            else if (clear_shift_reg) shift_reg <= 128'h0;
        end
    end
    
    //Shift Register Control FSM
    message_fsm shift_reg_controller(
        .clk(clk_100mhz),
        .rst_n(rst_main_n),
        .send_msg(btn0_pulse),
        .fifo_empty(uart0_rf_empty),
        .end_of_msg(end_message),
    
        .ld_shift(load_shift_reg),
        .ld_char(load_nxt_char),
        .clr_shift(clear_shift_reg)
    );
    //Read Logic
    always @(posedge clk_100mhz)
    begin
        if(~rst_main_n)
        begin
            led_out <= 4'b0;
        end
        else
        begin
            if(btn1_pulse) led_out <= uart0_dout[3:0];
        end
    end
    
    //Pulse Generator
    always @(posedge clk_100mhz)
    begin
    if(~rst_main_n)
        begin
            _btn <= 2'b0;
        end
    else
        begin
           _btn <= btn;
        end
    end
    

    //UART Core
    uart_top #(.BAUD_DIV(32'd54)) uart0_inst(
        .clk_main(clk_100mhz),
        .rst_n(rst_main_n),
        .wr_in(cur_char),
        .wr_stb(load_nxt_char),
        .rd_stb(btn1_pulse),
        .rx_pad(terminal_rx),
        .rd_out(uart0_dout),
        .tx_pad(terminal_tx),
        .rf_empty(uart0_rf_empty)
    );
    
    assign cur_char = shift_reg[127:120];
    assign end_message = (cur_char == 8'h0);
    
    assign btn0_pulse = btn[0] && ~_btn[0];
    assign btn1_pulse = btn[1] && ~_btn[1];
    assign led = led_out;
    
endmodule
