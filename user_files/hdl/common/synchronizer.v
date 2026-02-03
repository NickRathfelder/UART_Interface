module synchronizer# (
parameter DEFAULT_VAL = 1'b0,
parameter n = 1
)(
    input clk,
    input rst_n,
    input [n-1:0] s_i,
    output [n-1:0] s_o
    );
    
reg [n-1:0] r_1;
reg [n-1:0] r_2;

genvar i;
generate
    for(i = 0; i < n; i = i+1)
    begin
        always @(posedge clk)
        begin
            if(~rst_n)
                begin
                    r_1[i] <= DEFAULT_VAL;
                    r_2[i] <= DEFAULT_VAL;
                end
            else
            begin
                r_1[i] <= s_i[i];
                r_2[i] <= r_1[i];
            end
        end
        assign s_o[i] = r_2[i];
    end
endgenerate

endmodule
