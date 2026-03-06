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

// DUT
module uart_fifo_tb();
logic clk_wr_100mhz_t;
logic clk_rd_16mhz_t;
logic rst_wr_n_t;
logic rst_rd_n_t;
logic [7:0] din_t;
logic wr_en_t;
logic rd_en_t;

logic full_t;
logic almost_full_t;
logic empty_t;
logic almost_empty_t;
logic [7:0] dout_t;

initial
begin
    // Setup
    clk_wr_100mhz_t = 0;
    clk_rd_16mhz_t = 0;  
    rst_wr_n_t = 0;
    rst_rd_n_t = 0;
    wr_en_t = 0;
    rd_en_t = 0;
    din_t = 8'h00;
    reset_check();
    functional_check();
    empty_check();
    full_check();
end

task reset_check();
    begin
        @(posedge clk_wr_100mhz_t);
        rst_wr_n_t <= 1'b0;
        @(posedge clk_rd_16mhz_t);
        rst_rd_n_t <= 1'b0;   
        @(posedge clk_wr_100mhz_t);
        din_t <= 8'h01;
        wr_en_t <= 1'b1;
        @(posedge clk_wr_100mhz_t);
        wr_en_t <= 1'b0;
        repeat(2) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b1;
        @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b0;
        @(posedge clk_rd_16mhz_t);
    end
endtask

task functional_check();
    begin
        @(posedge clk_wr_100mhz_t);
        rst_wr_n_t <= 1'b1;
        @(posedge clk_rd_16mhz_t);
        rst_rd_n_t <= 1'b1;
        @(posedge clk_wr_100mhz_t);
        din_t <= 8'h02;
        wr_en_t <= 1'b1;
        @(posedge clk_wr_100mhz_t);
        wr_en_t <= 1'b0;
        repeat(2) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b1;
        @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b0;
        @(posedge clk_rd_16mhz_t);
    end
endtask

task empty_check();
    begin
        @(posedge clk_wr_100mhz_t);
        wr_en_t <= 1'b1;
        repeat(4) @(posedge clk_wr_100mhz_t);
        wr_en_t <= 1'b0;
        repeat(2) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b1;
        repeat(4) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b0;
        @(posedge clk_rd_16mhz_t);
    end
endtask

task full_check();
    begin
        @(posedge clk_wr_100mhz_t);
        din_t <= 8'h00;
        wr_en_t <= 1'b1;
        repeat(2048) begin
            @(posedge clk_wr_100mhz_t);
            din_t <= din_t +1;
        end
        wr_en_t <= 1'b0;
        repeat(2) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b1;
        repeat (2048) @(posedge clk_rd_16mhz_t);
        rd_en_t <= 1'b0;
        @(posedge clk_rd_16mhz_t);
    end
endtask
//Clock Generation
always #(5) clk_wr_100mhz_t= ~clk_wr_100mhz_t;
always #(31.25) clk_rd_16mhz_t= ~clk_rd_16mhz_t;

uart_fifo dut(
    .wr_clk(clk_wr_100mhz_t),
    .rd_clk(clk_rd_16mhz_t),
    .rst_wr_n(rst_wr_n_t),
    .rst_rd_n(rst_rd_n_t),
    .din(din_t),
    .wr_en(wr_en_t),
    .rd_en(rd_en_t),
    .full(full_t),
    .almost_full(almost_full_t),
    .empty(empty_t),
    .almost_empty(almost_empty_t),
    .dout(dout_t)
);

endmodule
