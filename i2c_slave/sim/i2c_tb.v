`timescale 1ns/1ps

module i2c_tb();
    reg SCL_in, SDA_in, clk, rst, master_2_slave;
    wire SDA_input;
    //wire bit_en;
    reg [7:0] DATA_IN;
    wire [7:0] DATA_OUT;
    //assign SDA_in = bit_en ? 1'b1 : 1'b0;
    assign SDA_input = master_2_slave ? SDA_in : 1'bz;
    i2c UUT (.sys_clk(clk), .SCL_in(SCL_in), .SDA_in(SDA_input), .DATA_IN(DATA_IN), .DATA_OUT(DATA_OUT), .sys_rst_n(rst));
    initial DATA_IN = 8'b1;
    initial begin
        clk = 0;
        forever begin
            clk = #0.02 !clk;
        end
        
    end
    
    initial begin
        rst = 1;
        #0.2 rst = 0;
        #0.2 rst = 1;
    end
    
    initial begin
        SCL_in = 1;
        forever begin
            #5 SCL_in = ~SCL_in;
        end
    end
    
    initial begin
//        WRITE_MODE      
//        master_2_slave = 1;
//        SDA_in = 1;
//        #2;
//        SDA_in = 0; //address pt1
//        #67;
//        SDA_in = 1; //address pt2
//        #10;
//        SDA_in = 0; //read write
//        #10;
//        SDA_in = 1;
//        #90;
//        SDA_in = 0;
//        #10;
//        SDA_in = 0;
//        #3;
//        SDA_in = 1;

//        READ_MODE
        master_2_slave = 1;
        SDA_in = 1;
        #2;
        SDA_in = 0; //address pt1
        #67;
        SDA_in = 1; //address pt2
        #7;
        SDA_in = 0; //read write
        #10;
        master_2_slave = 0;
        #10;
        master_2_slave = 1;
        SDA_in = 0;
        #10;
        SDA_in = 1;
        #70;
        SDA_in = 0;
        #10;
        SDA_in = 0;
        #3;
        SDA_in = 1;
        
        #41;
        master_2_slave = 1;
        SDA_in = 1;
        #2;
        SDA_in = 0; //address pt1
        #67;
        SDA_in = 1; //address pt2
        #7;
        SDA_in = 0; //read write
        #10;
        master_2_slave = 0;
        #10;
        master_2_slave = 1;
        SDA_in = 1;
        #10;
        SDA_in = 0;
        #70;
        SDA_in = 0;
        #10;
        SDA_in = 0;
        #3;
        SDA_in = 1;
    end

    
endmodule