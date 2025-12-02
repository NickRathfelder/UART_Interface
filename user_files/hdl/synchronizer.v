module synchronizer(
    input clk,
    input rst_n,
    input s_i,
    output s_o
    );
    
reg r_1;
reg r_2;
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        r_1 <= 1'b0;
        r_2 <= 1'b0;
    end
    else
    begin
        r_1 <= s_i;
        r_2 <= r_1;
    end
end


assign s_o = r_2;
endmodule
