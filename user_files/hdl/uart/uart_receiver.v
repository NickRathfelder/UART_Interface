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


module uart_receiver(
    input clk_main,
    input clk_rf,
    input rst_n_main,
    input rst_n_rf,
    input fifo_rd,
    input transmitter_rx,
    
    output [7:0] rf_out,
    output rf_empty

);

    //State Machine State Definitions
    parameter POLL = 2'b00;
    parameter RECV_START = 2'b01;
    parameter RECV_DATA = 2'b10;
    parameter RECV_STOP = 2'b11;
    
    //FIFO Signals
    wire fifo_wr;
    wire rf_full;
    wire transmitter_rx_sync;
    
    //State Machine States
    reg [1:0] cur_state;  
    //State Outputs
    reg _fifo_wr;
    reg [7:0] rf_shift_reg;
    reg [3:0] counter; 
    reg [2:0] bit_counter;
//Transmitter FIFO
uart_fifo rf_fifo(
    .wr_clk(clk_rf),
    .rd_clk(clk_main),
    .rst(~rst_n_main),
 
    .din(rf_shift_reg),
    .wr_en(fifo_wr),
    .full(tf_full),
    
    .dout(rf_out),
    .rd_en(fifo_rd),
    .empty(rf_empty)
);

// Synchronize RX to rf clock
synchronizer rx_synchronize(.clk(clk_rf), .rst_n(rst_n_rf), .s_i(transmitter_rx), .s_o(transmitter_rx_sync));
//New State machine
always @(posedge clk_rf or negedge rst_n_rf)
begin
    if(~rst_n_rf)
    begin
        cur_state <= POLL;
        _fifo_wr <= 1'b0;
        bit_counter <= 3'b0;
        counter <= 4'b0;
        rf_shift_reg <= 8'b0;
    end
    else
    begin
        case (cur_state)
        POLL:
        begin
            if(~tf_full && !transmitter_rx_sync)
            begin
                cur_state <= RECV_START;
                _fifo_wr <= 1'b0;
                bit_counter <= 3'b0;
                counter <= 4'b0;
                rf_shift_reg <= 8'b0;
            end
        end
        RECV_START:
        begin
            if(&counter)
            begin
                cur_state <= RECV_DATA;
                _fifo_wr <= 1'b0;
                bit_counter <= 3'b0;
                counter <= 4'b0;
                rf_shift_reg <= 8'b0;
            end
            counter <= counter +1;
        end
        RECV_DATA:
        begin
            if(&counter)
            begin
                if(&bit_counter)
                begin
                    cur_state <= RECV_STOP;
                    _fifo_wr <= 1'b1;
                    bit_counter <= 3'b0;
                    counter <= 4'b0;
                end
                else bit_counter <= bit_counter + 1;
            end
            else if(counter == 4'b0111) rf_shift_reg <= {transmitter_rx_sync, rf_shift_reg[7:1]};
            counter <= counter +1;
        end
        RECV_STOP:
        begin
            if(&counter)
            begin
                cur_state <= POLL;
                bit_counter <= 3'b0;
                counter <= 4'b0;
                rf_shift_reg <= 8'b0;
                _fifo_wr <= 1'b0;
            end
            else _fifo_wr <= 1'b0;
            counter <= counter +1;
        end
        default:
        begin
            cur_state <= POLL;
            _fifo_wr <= 1'b0;
            bit_counter <= 3'b0;
            counter <= 4'b0;
            rf_shift_reg <= 8'b0;
        end
        endcase
    end
end

assign fifo_wr = _fifo_wr;

endmodule
