`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 08:32:01 PM
// Design Name: 
// Module Name: message_fsm
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


module message_fsm(
    input clk,
    input rst_n,
    input send_msg,
    input wr_char,
    
    output ld_shift,
    output ld_char,
    output clr_shift
    );
    
parameter IDLE = 2'b00;
parameter LOAD_MSG = 2'b01;
parameter SEND_CHAR = 2'b10;
parameter CLEAR_REG = 2'b11;

//States
reg [1:0] cur_state, nxt_state;

//Output Registers
reg _ld_shift;
reg _ld_char;
reg _clr_shift;

//State Transition
always @(posedge clk)
begin
    if(~rst_n) cur_state <= IDLE;
    else cur_state <= nxt_state;
end

//Next State Decoder
always @(*)
begin
    if(~rst_n) nxt_state <= IDLE;
    else
    begin
        case(cur_state)
        IDLE:
        begin
            if(send_msg) nxt_state <= LOAD_MSG;
            else nxt_state <= IDLE;
        end
        LOAD_MSG:
        begin
            nxt_state <= SEND_CHAR;
        end
        SEND_CHAR:
        begin
            if(!wr_char) nxt_state <= CLEAR_REG;
            else nxt_state <= SEND_CHAR;
        end
        CLEAR_REG:
            nxt_state <= IDLE;
        
        endcase
    end
end

//State Outpute Decoder
always @(*)
begin
    if(~rst_n)
    begin
        _ld_shift <= 1'b0;
        _ld_char <= 1'b0;
        _clr_shift <= 1'b1;
    end
    else
    begin
        case(nxt_state)
        IDLE:
        begin
            _ld_shift <= 1'b0;
            _ld_char <= 1'b0;
            _clr_shift <= 1'b0;
        end
        LOAD_MSG:
        begin
            _ld_shift <= 1'b1;
            _ld_char <= 1'b0;
            _clr_shift <= 1'b0;
            end
        SEND_CHAR:
        begin
            _ld_shift <= 1'b0;
            _ld_char <= 1'b1;
            _clr_shift <= 1'b1;
        end
        CLEAR_REG:
        begin
            _ld_shift <= 1'b0;
            _ld_char <= 1'b0;
            _clr_shift <= 1'b1;
        end
        
        endcase
    end
end

assign ld_shift =_ld_shift;
assign ld_char = _ld_char;
assign clr_shift = _clr_shift;

endmodule
