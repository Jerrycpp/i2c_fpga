module i2c (clk, SCL, SDA, DATA_IN, DATA_OUT, rst);
    input SCL, clk, rst;
    localparam ADDR = 7'b0000001;
    input [7:0] DATA_IN;
    output reg [7:0] DATA_OUT;
    reg [7:0] data_w;
    inout SDA;
    reg bit_en;
    assign SDA = bit_en ? 1'bz : 1'b0;
    wire SCL_posedge, SCL_negedge, SDA_posedge, SDA_negedge;
    reg [2:0] i2c_state, i2c_next_state;
    localparam IDLE = 3'b0, ADDRRW = 3'd1, ACK1 = 3'd2, READ = 3'd3, WRITE = 3'd4, ACK2 = 3'd5;
    reg ACKed;
    reg [7:0] addrrw;
    reg [3:0] addrrw_counter, data_read_counter, data_written_counter;
    edge_detector SCL_edge (.clk(clk), .inp(SCL), .neg(SCL_negedge), .pos(SCL_posedge), .rst(rst));
    edge_detector SDA_edge (.clk(clk), .inp(SDA), .neg(SDA_negedge), .pos(SDA_posedge), .rst(rst));
    always@(posedge clk or posedge rst) begin
        if (rst) begin
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
                if (SDA_negedge) begin
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
    always@(posedge clk or posedge rst) begin
        if (rst || i2c_state == IDLE) begin
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
    always@(posedge clk or posedge rst) begin
        if (rst || i2c_state == IDLE) begin
            ACKed <= 0;
            bit_en <= 1;
            data_written_counter <= 4'b0;
            data_w <= 8'b0;
        end
        else begin
            // handle ACK first
            // if (SCL_negedge) begin
                if (i2c_state == ACK1 || (i2c_state == ACK2 && addrrw[0] == 0)) begin
                bit_en <= 0;
                ACKed <= 1;
                data_w <= DATA_IN;
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
                if (SCL_negedge) begin
                    bit_en <= data_w [7:7];
                    data_w <= data_w << 1;
                    data_written_counter <= data_written_counter + 1;
                end
                end
            // end
        end
    end

    // handle WRITE mode

    always @(posedge clk or posedge rst) begin
        if (rst || i2c_state == IDLE) begin
            data_read_counter <= 4'b0;
            DATA_OUT <= 8'b0;
        end
        else begin
            if (i2c_state == READ && SCL_posedge) begin
                DATA_OUT <= {DATA_OUT[6:0], SDA};
                data_read_counter <= data_read_counter + 1;
            end
        end
    end

endmodule