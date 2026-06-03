`timescale 1ns / 1ps

module spi_slave (             // mode 0
    input  logic       clk,      // system clock
    input  logic       reset,
    input  logic       sclk,     // SPI clock from master
    input  logic       cs_n,
    input  logic       mosi,
    input  logic [7:0] tx_data,
    output logic       miso,
    output logic [7:0] rx_data,
    output logic       done
);

    logic [7:0] rx_shift_reg, tx_shift_reg;
    logic [2:0] bit_cnt;

    logic sclk_sync_0, sclk_sync_1;
    logic mosi_sync_0, mosi_sync_1;
    logic cs_sync_0,   cs_sync_1;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sclk_sync_0 <= 1'b0;
            sclk_sync_1 <= 1'b0;
            mosi_sync_0 <= 1'b0;
            mosi_sync_1 <= 1'b0;
            cs_sync_0   <= 1'b1;
            cs_sync_1   <= 1'b1;
        end else begin
            sclk_sync_0 <= sclk;
            sclk_sync_1 <= sclk_sync_0;

            mosi_sync_0 <= mosi;
            mosi_sync_1 <= mosi_sync_0;

            cs_sync_0   <= cs_n;
            cs_sync_1   <= cs_sync_0;
        end
    end

    // edge detector
    logic sclk_d;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            sclk_d <= 1'b0;
        else
            sclk_d <= sclk_sync_1;
    end

    wire sclk_rising  = (sclk_sync_1 == 1 && sclk_d == 0);
    wire sclk_falling = (sclk_sync_1 == 0 && sclk_d == 1);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_shift_reg <= 0;
            tx_shift_reg <= 0;
            bit_cnt      <= 0;
            miso         <= 0;
            rx_data      <= 0;
            done         <= 0;
        end else begin
            done <= 0;

            if (cs_sync_1) begin
                // idle 상태
                bit_cnt <= 0;
                tx_shift_reg <= tx_data;
                miso         <= tx_data[7];
            end else begin
                // Rising edge -> 수신 (Master: MISO 읽음, Slave: MOSI 읽음)
                if (sclk_rising) begin
                    rx_shift_reg <= {rx_shift_reg[6:0], mosi_sync_1};

                    if (bit_cnt == 7) begin
                        rx_data <= {rx_shift_reg[6:0], mosi_sync_1};
                        done    <= 1;
                        bit_cnt <= 0;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // Falling edge -> 송신
                if (sclk_falling) begin
                    miso <= tx_shift_reg[6];
                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                end
            end
        end
    end

endmodule