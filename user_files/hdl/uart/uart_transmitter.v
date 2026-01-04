`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2025 12:49:06 AM
// Design Name: 
// Module Name: uart_transmitter
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


module uart_transmitter(
    input clk_main,
    input clk_tf,
    input rst_n_main,
    input rst_n_tf,
    input fifo_wr,
    input [7:0] tf_in,
    
    output tf_full,
    output transmitter_tx

);

    //State Machine State Definitions
    parameter IDLE = 2'b00;
    parameter SEND_START = 2'b01;
    parameter SEND_DATA = 2'b10;
    parameter SEND_STOP = 2'b11;
    
    //FIFO Signals
    wire[7:0] tf_dout;
    wire fifo_rd;
    wire tf_empty;
    
    //State Machine States
    reg [2:0] cur_state,nxt_state;  
    
    //State Outputs
    reg _transmitter_tx;
    reg _fifo_rd;
    reg [7:0] tf_shift_reg;
    reg [3:0] counter; 
    reg [2:0] bit_counter;

//Transmitter FIFO
uart_fifo tf_fifo(
    .wr_clk(clk_main),
    .rd_clk(clk_tf),
    .rst(~rst_n_main),
 
    .din(tf_in),
    .wr_en(fifo_wr),
    .full(tf_full),
    
    .dout(tf_dout),
    .rd_en(fifo_rd),
    .empty(tf_empty)
);
//New State machine
always @(posedge clk_tf)
begin
    if(~rst_n_tf)
    begin
        cur_state <= IDLE;
        _fifo_rd <= 1'b0;
        _transmitter_tx <= 1'b1;
        bit_counter <= 3'b0;
        counter <= 4'b0;
        tf_shift_reg <= 8'b0;
    end
    else
    begin
        case (cur_state)
        IDLE:
        begin
            if(~tf_empty)
            begin
                cur_state <= SEND_START;
                _fifo_rd <= 1'b1;
                _transmitter_tx <= 1'b0;
                bit_counter <= 3'b0;
                counter <= 4'b0;
                tf_shift_reg <= tf_dout;
            end
        end
        SEND_START:
        begin
            if(&counter)
            begin
                cur_state <= SEND_DATA;
                _transmitter_tx <= tf_shift_reg[0];
                tf_shift_reg <= {1'b0,tf_shift_reg[7:1]};
                bit_counter <= 3'b0;
            end
            else _fifo_rd <= 1'b0;
            counter <= counter +1;
        end
        SEND_DATA:
        begin
            if(&counter)
            begin
                if(&bit_counter)
                begin
                    cur_state <= SEND_STOP;
                    _transmitter_tx <= 1'b1;
                    bit_counter <= 3'b0;
                end
                else 
                begin
                    bit_counter <= bit_counter +1; 
                    _transmitter_tx <= tf_shift_reg[0];
                    tf_shift_reg <= {1'b0,tf_shift_reg[7:1]};
                end
            end
            counter <= counter +1;
        end
        SEND_STOP:
        begin
            if(&counter)
            begin
                cur_state <= IDLE;
                _fifo_rd <= 1'b0;
                _transmitter_tx <= 1'b1;
                bit_counter <= 3'b0;
                counter <= 4'b0;
                tf_shift_reg <= 8'b0;
            end
            counter <= counter +1;
        
        end
        default:
        begin
            cur_state <= IDLE;
            _fifo_rd <= 1'b0;
            _transmitter_tx <= 1'b1;
            bit_counter <= 3'b0;
            counter <= 4'b0;
            tf_shift_reg <= 8'b0;
        end
        endcase
    end
end

assign transmitter_tx = _transmitter_tx;
assign fifo_rd = _fifo_rd;

endmodule
