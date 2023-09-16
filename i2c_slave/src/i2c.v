module i2c (sys_clk, SCL_in, SDA_in, DATA_IN, DATA_OUT, sys_rst_n, i2c_state);
    input SCL_in, sys_clk, sys_rst_n;
    wire SCL, SDA;
    debounce dbc1 (sys_clk, SCL_in, SCL, sys_rst_n);
    debounce dbc2 (sys_clk, SDA_in, SDA, sys_rst_n);
    localparam ADDR = 7'b0000001;
    input [7:0] DATA_IN;
    output reg [7:0] DATA_OUT;
    reg [7:0] data_w;
    inout SDA_in;
    reg bit_en;
    assign SDA_in = bit_en ? 1'bz : 1'b0;
    wire SCL_posedge, SCL_negedge, SDA_posedge, SDA_negedge;
    reg [2:0] i2c_state, i2c_next_state;
    output reg [2:0] i2c_state;
    localparam IDLE = 3'b0, ADDRRW = 3'd1, ACK1 = 3'd2, READ = 3'd3, WRITE = 3'd4, ACK2 = 3'd5;
    reg ACKed;
    reg [7:0] addrrw;
    reg [3:0] addrrw_counter, data_read_counter, data_written_counter;
    edge_detector SCL_edge (.sys_clk(sys_clk), .inp(SCL), .neg(SCL_negedge), .pos(SCL_posedge), .sys_rst_n(sys_rst_n));
    edge_detector SDA_edge (.sys_clk(sys_clk), .inp(SDA), .neg(SDA_negedge), .pos(SDA_posedge), .sys_rst_n(sys_rst_n));
    always@(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            i2c_state <= IDLE;
        end
        else begin
            i2c_state <= i2c_next_state;
        end
    end

    always@* begin
        i2c_next_state = i2c_state;
        case (i2c_state)
            IDLE : begin
                if (SDA_negedge && SCL) begin
                    i2c_next_state = ADDRRW;
                end
            end

            ADDRRW : begin
                if (addrrw_counter == 8 && SCL_negedge) begin
                    if (addrrw [7:1] == ADDR) begin
                        i2c_next_state = ACK1;
                    end
                    else i2c_next_state = IDLE;
                end
            end

            ACK1 : begin
                if (SCL_negedge && ACKed) begin
                    if (addrrw[0] == 0) i2c_next_state = READ;
                    else if (addrrw[0] == 1) i2c_next_state = WRITE;
                end 
                else if (SCL_negedge && !ACKed) begin
                    i2c_next_state = IDLE;
                end
            end

            READ : begin
                if (data_read_counter == 8 && SCL_negedge) begin
                    i2c_next_state = ACK2;
                end
            end

            WRITE : begin
                if (data_written_counter == 8 && SCL_negedge) begin
                    i2c_next_state = ACK2;
                end
            end

            ACK2 : begin
                if (ACKed && SCL_negedge) begin
                    i2c_next_state = IDLE;
                end
            end
        endcase
    end
    // read ADDRRW
    always@(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n || i2c_state == IDLE) begin
            addrrw <= 8'b0;
            addrrw_counter <= 3'b0;
        end
        else begin
            if (i2c_state == ADDRRW) begin
                if (SCL_posedge) begin
                    addrrw <= {addrrw[6:0], SDA};
                    addrrw_counter <= addrrw_counter + 1;
                end
            end
        end
    end
    // manage ACK and ACKed signal, WRITE mode
    always@(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n || i2c_state == IDLE) begin
            ACKed <= 0;
            bit_en <= 1;
            data_written_counter <= 4'b0;
            data_w <= 8'b0;
            //DATA_OUT <= 0;
        end
        else begin
            // handle ACK first
            // if (SCL_negedge) begin
                if (i2c_state == ACK1 || (i2c_state == ACK2 && addrrw[0] == 0)) begin
                bit_en <= 0;
                ACKed <= 1;
                data_w <= DATA_IN;
                //DATA_OUT <= data_r;
                end
                else if (i2c_state == ACK2 && addrrw[0] == 1) begin
                ACKed <= 1;
                end
                else if (i2c_state == READ || i2c_state == WRITE) begin
                ACKed <= 0;
                bit_en <= 1;
                end
                // handle WRITE operation of I2C slave device
                else if (i2c_state == WRITE) begin
                if (SCL_negedge && data_written_counter < 8) begin
                    
                        bit_en <= data_w [7:7];
                        data_w <= data_w << 1;
                        data_written_counter <= data_written_counter + 1;
                    
                end
                end
            // end
        end
    end

    // handle WRITE mode
    reg [7:0] data_r;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n || i2c_state == IDLE) begin
            data_read_counter <= 4'b0;
            data_r <= 8'b0;
        end
        else begin
            if (i2c_state == READ && SCL_posedge) begin
                data_r <= {data_r[6:0], SDA};
                data_read_counter <= data_read_counter + 1;
            end
        end
    end
    always@(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) DATA_OUT <= 8'b0;
        else if (i2c_state == ACK2) DATA_OUT <= data_r;
    end
endmodule

module debounce (sys_clk, inp, out, sys_rst_n);
    input sys_clk, inp, sys_rst_n;
    output reg out;
    reg [3:0] state;
    reg [3:0] cnter;
    always@(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            state <= 4'd1;
            cnter <= 0;       
        end
        else begin
            if (cnter == 4'd13) begin
                out <= (state[0] ^ state[1] ^ state[2] ^ state[3]) ? out : state[0];
                state <= {state[2:0], inp};
                cnter <= 0;
            end
            else cnter <= cnter + 1;
        end
    end

endmodule

