`timescale 1ns / 1ps

module spi_master (
    input  logic       clk,
    input  logic       reset,
    input  logic       cpol,
    input  logic       cpha,
    input  logic [7:0] clk_div,  // clk 주기값. 5번 count하기 때문에 4를 넣으면 된다. // 나중에 확장할거 생각해서 bit를 좀 더 여유롭게 줬다.
    input  logic [7:0] tx_data,
    input  logic       start,
    output logic [7:0] rx_data,
    output logic       done,
    output logic       busy,
    output logic       sclk,
    output logic       mosi,
    input  logic       miso
    // output logic       cs_n
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START,
        DATA,
        STOP
    } spi_state_e;

    spi_state_e state;
    logic [7:0] div_cnt;
    logic half_tick; // clock 변경을 위한 tick. 상태가 DATA 상태일 때만 발생해야 한다. 안그럼 계속 발생함.
    logic [7:0] tx_shift_reg, rx_shift_reg;
    logic [2:0] bit_cnt; // 0~7이니까 3bit 필요.
    logic step, sclk_r; // phase라고 써져 있던거를 step으로 이름을 바꿈. 헷갈려서..

    assign sclk = sclk_r;

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            div_cnt <= 0;
            half_tick <= 1'b0;
        end else begin
            if (state == DATA) begin
                if (div_cnt == clk_div) begin // 20MHz 간격으로 tick이 발생한다.
                    div_cnt <= 0;
                    half_tick <= 1'b1;
                end else begin
                    div_cnt <= div_cnt + 1;
                    half_tick <= 1'b0;
                end
            end
        end
    end

    always_ff @( posedge clk or posedge reset ) begin
        if (reset) begin
            state        <= IDLE;
            mosi         <= 1'b1;
            // cs_n         <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            step        <= 1'b0;
            rx_data      <= 0;
            // sclk_r       <= 1'b0; // register 값.
            sclk_r       <= cpol; // 이렇게 하면 polarity에 따라 바꿀 수 있음. 밑에서 sclk_r = ~sclk_r 이렇게 토글해주니까.
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    mosi   <= 1'b1;
                    // cs_n   <= 1'b1;
                    // sclk_r <= 1'b0;
                    sclk_r <= cpol; // 이렇게 하면 polarity에 따라 바꿀 수 있음
                    if (start) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt      <= 0;
                        step        <= 1'b0;
                        busy         <=1'b1;
                        // cs_n         <= 1'b0;
                        state        <= START;
                    end
                end
                START: begin
                    if (!cpha) begin // 0이면 처음부터 나감.
                        mosi         <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                    state <= DATA;
                end
                DATA: begin
                    if (half_tick) begin
                        sclk_r <= ~sclk_r;
                        if (step == 0) begin // 수신 구간
                            step <= 1'b1;
                            if(!cpha) begin
                                rx_shift_reg <= {rx_shift_reg[6:0], miso}; // miso를 수신한다. // edge가 발생하자마자 이게 동작.
                            end else begin // phase=0일 때 첫 번째 엣지에서 ~~ phase=1일 때 첫 번째 엣지에서 나감.
                                mosi <= tx_shift_reg[7];
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                            end
                        end else begin       // 송신 구간
                            step <= 1'b0;
                            if(!cpha) begin // 송신
                                if (bit_cnt < 7) begin
                                    mosi <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end
                            end else begin // 수신
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end
                            if (bit_cnt == 7) begin
                                state <= STOP;
                                if (!cpha) begin
                                    rx_data <= rx_shift_reg;
                                end else begin
                                    // rx_data <= rx_shift_reg;
                                    rx_data <= {rx_shift_reg[6:0], miso}; // 마지막꺼 한 번더 캡쳐한다.
                                end
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end
                end
                STOP: begin
                    sclk_r <= 1'b0;
                    // cs_n   <= 1'b1;
                    done   <= 1'b1;
                    busy   <= 1'b0;
                    mosi   <= 1'b1;
                    state  <= IDLE;
                end
                default:  begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
