module edge_detector (sys_clk, inp, neg, pos, sys_rst_n);
    input sys_clk, inp, sys_rst_n;
    output neg, pos;

    reg q2;

    always @ (posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
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