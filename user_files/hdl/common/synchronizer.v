module synchronizer# (
parameter DEFAULT_VAL = 1'b0
)(
    input clk,
    input rst_n,
    input s_i,
    output s_o
    );
    
reg r_1;
reg r_2;
always @(posedge clk)
begin
    if(~rst_n)
    begin
        r_1 <= DEFAULT_VAL;
        r_2 <= DEFAULT_VAL;
    end
    else
    begin
        r_1 <= s_i;
        r_2 <= r_1;
    end
end


assign s_o = r_2;
endmodule
