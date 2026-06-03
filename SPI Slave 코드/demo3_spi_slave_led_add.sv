`timescale 1ns / 1ps

module demo3_spi_slave_led_add (
    input logic clk,
    input logic reset,
    // 보드에 맞게 버튼 4개 할당
    input logic btn_u,  // GPIO_PIN_4 (UpCounter 시작/정지)
    input logic btn_l,  // GPIO_PIN_5 (클럭/업카운터 모드 변경)
    input logic btn_r,  // GPIO_PIN_6 (시간/초 표시 변경)
    input logic btn_d,  // GPIO_PIN_7 (UpCounter Clear)

    // SPI Interface
    input  logic sclk,
    input  logic cs_n,
    input  logic mosi,
    output logic miso,

    // output
    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data
);

    logic [ 7:0] tx_data;
    logic [ 7:0] rx_data;
    logic        spi_done;

    logic [15:0] data_16;

    // Master의 GPIO_PIN_x 매크로 위치(비트 4, 5, 6, 7)에 정확히 매핑하여 전송
    assign tx_data = {btn_d, btn_r, btn_l, btn_u, 4'b0000};

    // 기존 spi_slave 모듈 인스턴스화
    spi_slave u_spi_slave (
        .clk(clk),
        .reset(reset),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .tx_data(tx_data),
        .miso(miso),
        .rx_data(rx_data),
        .done(spi_done)
    );
    fnd_controller U_FND_CTRL (
        .clk(clk),
        .reset(reset),
        .fnd_indata(data_16),  // input
        .fnd_digit(fnd_digit),
        .fnd_data(fnd_data)
    );

    logic [7:0] first_byte;
    logic       byte_phase;  // 0: 첫 번째, 1: 두 번째
    // logic       result_valid;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            byte_phase <= 0;
            // result_valid <= 0;
            data_16    <= 0;
        end else begin
            // result_valid <= 0;  // 기본값
            if (spi_done) begin
                if (byte_phase == 0) begin
                    // 첫 번째(하위) 바이트 저장
                    first_byte <= rx_data;
                    byte_phase <= 1;
                end else begin
                    // 두 번째(상위) 바이트 들어오면 조합
                    data_16 <= {rx_data, first_byte};
                    // result_valid <= 1;
                    byte_phase <= 0;
                end
            end
            if (cs_n) begin
                byte_phase <= 0;
            end
        end
    end

endmodule
