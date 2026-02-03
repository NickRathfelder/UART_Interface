module uart_fifo(
    input wr_clk,
    input rd_clk,
    input rst_wr_n,
    input rst_rd_n,
    input [7:0] din ,
    input wr_en,
    input rd_en,
    
    output full,
    output empty,
    output reg [7:0] dout

    );
    // R/W Pointers
    reg [11:0] rd_ptr;
    reg [11:0] wr_ptr;
    //Gray R/W Pointers
    wire [11:0] rd_ptr_g;
    wire [11:0] wr_ptr_g;
    // Synchronized Gray R/W Pointers
    wire [11:0] rd_ptr_g_sync;
    wire [11:0] wr_ptr_g_sync;
    // Synchronized Binary R/W Pointers
    wire [11:0] rd_ptr_b_sync;
    wire [11:0] wr_ptr_b_sync;
    // R/W Addresses
    wire [10:0] rd_addr;
    wire [10:0] wr_addr;
    // R/W Strobes
    wire rd_stb;
    wire wr_stb;
    
    (* ram_style = "distributed" *) reg [7:0] ram [2047:0];
    
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
       if (~rst_wr_n) wr_ptr <= 12'b0;
       else if(wr_stb) wr_ptr <= wr_ptr + 1;
    end
    
    always @(posedge rd_clk)
    begin
       if (~rst_rd_n) rd_ptr <= 12'b0;
       else if(rd_stb) rd_ptr <= rd_ptr + 1;
    end
    
    bin_to_gray_n #(.n(12)) rd_ptr_g_inst (.in_b(rd_ptr),.out_g(rd_ptr_g));
    bin_to_gray_n #(.n(12)) wr_ptr_g_inst (.in_b(wr_ptr),.out_g(wr_ptr_g));
    
    synchronizer #(.n(12)) rd_ptr_synchronize(.clk(wr_clk), .rst_n(rst_wr_n), .s_i(rd_ptr_g), .s_o(rd_ptr_g_sync));
    synchronizer #(.n(12)) wr_ptr_synchronize(.clk(rd_clk), .rst_n(rst_rd_n), .s_i(wr_ptr_g), .s_o(wr_ptr_g_sync));
    
    gray_to_bin_n #(.n(12)) rd_ptr_b_inst (.in_g(rd_ptr_g_sync),.out_b(rd_ptr_b_sync));
    gray_to_bin_n #(.n(12)) wr_ptr_b_inst (.in_g(wr_ptr_g_sync),.out_b(wr_ptr_b_sync));
    
    // Empty/Full Flags
    assign empty = (rd_ptr[10:0] == wr_ptr_b_sync[10:0]) && !(rd_ptr[11] ^ wr_ptr_b_sync[11]);
    assign full = (wr_ptr[10:0] == rd_ptr_b_sync[10:0]) && (wr_ptr[11] ^ rd_ptr_b_sync[11]);
    
    assign rd_stb = rd_en && !empty;
    assign wr_stb = wr_en && !full;
    
    assign rd_addr = rd_ptr[10:0];
    assign wr_addr = wr_ptr[10:0];
    
    endmodule