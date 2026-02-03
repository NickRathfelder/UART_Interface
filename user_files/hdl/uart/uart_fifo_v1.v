`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 07:07:19 PM
// Design Name: 
// Module Name: fifo
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

module uart_fifo(
    input wr_clk,
    input rd_clk,
    input rst_wr_n,
    input rst_rd_n,
    input [7:0] din ,
    input wr_en,
    input rd_en,
    
    output reg full,
    output reg empty,
    output reg [7:0] dout

    );
    
    (* ram_style = "distributed" *) reg [7:0] ram [2047:0];
    
    wire wr_stb;
    wire rd_stb;
    
    reg [10:0] rd_addr;
    reg [10:0] wr_addr;
    wire [10:0] rd_addr_nxt;
    wire [10:0] wr_addr_nxt;
    
    wire [10:0] rd_addr_g;
    wire [10:0] wr_addr_g;
    wire [10:0] rd_addr_g_nxt;
    wire [10:0] wr_addr_g_nxt;
    
    wire [10:0] rd_addr_g_sync;
    wire [10:0] wr_addr_g_sync;
      
    gray_code_n #(.n(11)) rd_addr_g_inst (.in_b(rd_addr),.out_g(rd_addr_g));
    gray_code_n #(.n(11)) wr_addr_g_inst (.in_b(wr_addr),.out_g(wr_addr_g));
    
    gray_code_n #(.n(11)) rd_addr_g_nxt_inst (.in_b(rd_addr_nxt),.out_g(rd_addr_g_nxt));
    gray_code_n #(.n(11)) wr_addr_g_nxt_inst (.in_b(wr_addr_nxt),.out_g(wr_addr_g_nxt));
    
    synchronizer #(.n(11)) wr_addr_synchronize(.clk(rd_clk), .rst_n(rst_rd_n), .s_i(wr_addr_g), .s_o(wr_addr_g_sync));
    synchronizer #(.n(11)) rd_addr_synchronize(.clk(wr_clk), .rst_n(rst_wr_n), .s_i(rd_addr_g), .s_o(rd_addr_g_sync));
   
    
    always @(posedge wr_clk)
    begin
        if (rst_wr_n)
        begin
            if (wr_stb) ram[wr_addr] <=  din;
        end
    end
    always @(posedge rd_clk)
    begin
        if (rst_rd_n)
        begin
            dout <= ram[rd_addr];
        end
    end
    
    always @(posedge wr_clk)
    begin
       if (~rst_wr_n)
       begin
            full <= 1'b0;
            wr_addr <= 11'b0;
       end
       else
       begin
            if(wr_stb)
            begin
                if(rd_addr_g_sync == wr_addr_g_nxt) full <= 1'b1;
                wr_addr <= wr_addr + 1;
            end
            else if (rd_addr_g_sync != wr_addr_g) full <= 1'b0;
       end
    end
    
    always @(posedge rd_clk)
    begin
       if (~rst_rd_n)
       begin
            empty <= 1'b1;
            rd_addr <= 11'b0;
       end
       else
       begin
            if(rd_stb)
            begin
                if(wr_addr_g_sync == rd_addr_g_nxt) empty <= 1'b1;
                rd_addr <= rd_addr + 1;
            end
            else if (wr_addr_g_sync != rd_addr_g) empty <= 1'b0;
       end
    end
    
    assign wr_addr_nxt = wr_addr + 1;
    assign rd_addr_nxt = rd_addr + 1;
    
    assign wr_stb = wr_en && !full;
    assign rd_stb = rd_en && !empty;
    
endmodule
