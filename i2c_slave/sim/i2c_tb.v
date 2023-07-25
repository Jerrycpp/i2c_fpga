`timescale 1ns/10ps

module i2c_tb();
    reg SCL, clk, rst, bit_en;
    wire SDA;
    reg [7:0] DATA_IN;
    wire [7:0] DATA_OUT;
    assign SDA = bit_en ? 1'b1 : 1'b0;
    
    i2c UUT (.clk(clk), .SCL(SCL), .SDA(SDA), .DATA_IN(DATA_IN), .DATA_OUT(DATA_OUT), .rst(rst));
    initial begin
        clk = 0;
        forever begin
            clk = #1 !clk;
        end
        
    end
    
    initial begin
        rst = 0;
        #0.2 rst = 1;
        #0.2 rst = 0;
    end
    
    initial begin
        SCL = 1;
        forever begin
            #10 SCL = ~SCL;
        end
    end
    
    initial begin
        bit_en = 1;
        #5 bit_en = 0;
        #134 bit_en = 1;
        #20 bit_en = 0;
        #38 bit_en = 1;
        #160 bit_en = 0;
        #20 bit_en = 1;
        
        

    end

    
endmodule