`timescale 1ns / 1ps

module I2C_Slave #(
    parameter SLAVE_ADDR = 7'h12
)(
    input  logic clk,
    input  logic reset,

    input  logic scl,
    inout  wire  sda,

    input  logic [7:0] tx_data, // Slave -> Master 보낼 데이터 (Master가 Read일 때)
    output logic [7:0] rx_data, // Master -> Slave 받은 데이터 (Master가 Write일 때)
    output logic       data_valid // Slave 수신 완료를 나타냄.
);

    logic sda_o, sda_i;
    assign sda_i = sda;
    assign sda   = sda_o ? 1'bz : 1'b0; // 3-state buffer

    i2c_slave #(
        .SLAVE_ADDR(7'h12)
    ) u_i2c_slave (
        .*,
        .sda_i(sda_i),
        .sda_o(sda_o)
    );
    
endmodule


module i2c_slave #(
    parameter SLAVE_ADDR = 7'h12
)(
    input  logic clk,
    input  logic reset,

    input  logic scl,
    input  logic sda_i,
    output logic sda_o,

    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       data_valid
);

    // 싱크로나이저
    logic scl_sync_0, scl_sync_1;
    logic sda_sync_0, sda_sync_1;

    // always_ff @(posedge clk) begin
    //     scl_sync_0 <= scl;
    //     scl_sync_1 <= scl_sync_0;

    //     sda_sync_0 <= sda_i;
    //     sda_sync_1 <= sda_sync_0;
    // end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_sync_0 <= 1'b1;
            scl_sync_1 <= 1'b1;
            sda_sync_0 <= 1'b1;
            sda_sync_1 <= 1'b1;
        end else begin
            scl_sync_0 <= scl;
            scl_sync_1 <= scl_sync_0;

            sda_sync_0 <= sda_i;
            sda_sync_1 <= sda_sync_0;
        end
    end

    // edge 검출
    wire scl_rising  = (scl_sync_1 == 0 && scl_sync_0 == 1);
    wire scl_falling = (scl_sync_1 == 1 && scl_sync_0 == 0);
    
    wire sda_rising = (sda_sync_1 == 0 && sda_sync_0 == 1);
    wire sda_falling = (sda_sync_1 == 1 && sda_sync_0 == 0);

    // wire start = sda_falling && (scl_sync_0 == 1);
    wire start = (sda_sync_1 == 1'b1 && sda_sync_0 == 1'b0 && scl_sync_0 == 1'b1);
    // wire start = (sda_sync_1 == 1 && sda_sync_0 == 0);
    wire stop  = sda_rising && (scl_sync_0 == 1);

    // START, STOP 검출
    // wire start = (sda_sync_1 == 1 && sda_sync_0 == 0 && scl_sync_0 == 1);
    // wire stop  = (sda_sync_1 == 0 && sda_sync_0 == 1 && scl_sync_0 == 1);


    logic stop_event;

    typedef enum logic [2:0] {
        IDLE,
        ADDR,
        ADDR_ACK,
        DATA,
        DATA_ACK
    } i2c_slave_state_e;

    i2c_slave_state_e state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            stop_event <= 1'b0;
        else if (stop)
            stop_event <= 1'b1;
        else if (state == IDLE)
            stop_event <= 1'b0;
    end

    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    logic       rw; // 1: read, 0: write

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= IDLE;
            bit_cnt    <= 0;
            shift_reg  <= 0;
            sda_o      <= 1'b1;
            data_valid <= 0;
            rx_data    <= 0;
            rw         <= 0;
        end else begin
            data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    sda_o <= 1'b1;
                    if (start) begin
                        state   <= ADDR;
                        bit_cnt <= 0;
                        shift_reg <= 0;
                    end
                end
                // 주소 (7bit + RW)
                ADDR: begin
                    if (stop_event) begin
                            state <= IDLE;
                            sda_o <= 1'b1;
                        end else begin
                            if (scl_rising) begin
                                shift_reg <= {shift_reg[6:0], sda_sync_0};
                                if (bit_cnt == 3'd7) begin
                                    rw    <= sda_sync_0;
                                    state <= ADDR_ACK;
                                    bit_cnt <= 0;
                                end else begin
                                    bit_cnt <= bit_cnt + 1;
                                end
                            end
                        end
                end
                ADDR_ACK: begin
                    if (stop_event) begin
                            state <= IDLE;
                            sda_o <= 1'b1;
                    end else begin
                        if (scl_falling) begin
                            if (shift_reg[7:1] == SLAVE_ADDR)
                                sda_o <= 1'b0; // ACK
                            else
                                sda_o <= 1'b1; // NACK
                        end
                        if (scl_rising) begin
                            // sda_o <= 1'b1;
                            if (shift_reg[7:1] == SLAVE_ADDR) begin
                                state <= DATA;
                                bit_cnt <= 0;
                                shift_reg <= 0;
                            end else begin
                                state <= IDLE;
                            end
                        end
                    end
                end
                DATA: begin
                    if (stop_event) begin
                            state <= IDLE;
                            sda_o <= 1'b1;
                    end else begin
                        if (rw == 1'b0) begin
                            // Write (Master -> Slave)
                            if (scl_falling) begin
                                sda_o <= 1'b1; // scl이 low일 때 여기서 ACK 상태 해제.(이래야 안정적임.)
                            end
                            if (scl_rising) begin
                                shift_reg <= {shift_reg[6:0], sda_sync_0};

                                if (bit_cnt == 3'd7) begin
                                    rx_data    <= {shift_reg[6:0], sda_sync_0};
                                    data_valid <= 1'b1;
                                    state      <= DATA_ACK;
                                    bit_cnt    <= 0;
                                end else begin
                                    bit_cnt <= bit_cnt + 1;
                                end
                            end
                        end else begin
                            // Read (Slave -> Master)
                            if (scl_falling) begin
                                sda_o <= tx_data[7 - bit_cnt];
                            end
                            if (scl_rising) begin
                                if (bit_cnt == 3'd7) begin
                                    state   <= DATA_ACK;
                                    bit_cnt <= 0;
                                end else begin
                                    bit_cnt <= bit_cnt + 1;
                                end
                            end
                        end
                    end
                end
                DATA_ACK: begin
                    if (stop_event) begin
                            state <= IDLE;
                            sda_o <= 1'b1;
                    end else begin
                        if (rw == 1'b0) begin
                            // Slave ACK
                            if (scl_falling)
                                sda_o <= 1'b0;

                            if (scl_rising) begin
                                // sda_o   <= 1'b1;
                                state   <= DATA;
                                bit_cnt <= 0;
                            end
                        end else begin
                            // Master ACK / NACK
                            if (scl_falling)
                                sda_o <= 1'b1;

                            if (scl_rising) begin
                                if (sda_sync_0 == 1'b1) begin
                                    state <= IDLE; // NACK -> 종료
                                end else begin
                                    state   <= DATA;
                                    bit_cnt <= 0;
                                end
                            end
                        end
                    end
                end
            endcase
        end
    end

endmodule