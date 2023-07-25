module edge_detector (clk, inp, neg, pos, rst);
    input clk, inp, rst;
    output neg, pos;

    reg q2;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            // q1 <= 0;
            q2 <= 0;
        end
        else begin
            // q1 <= inp;
            q2 <= inp;
        end
    end
    assign neg = q2 & ~inp;
    assign pos = ~q2 & inp;
endmodule