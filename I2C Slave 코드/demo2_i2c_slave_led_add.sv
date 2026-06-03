`timescale 1ns / 1ps

module demo2_i2c_slave_led_add (
    input  logic       clk,
    input  logic       reset,
    input  logic       scl,
    inout  wire        sda,        // I2C는 inout wire 사용    
    input  logic       btn_u,
    input  logic       btn_l,
    input  logic       btn_r,
    input  logic       btn_d,
    output logic [3:0] fnd_digit,
    output logic [7:0] fnd_data
);
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       data_valid; // SPI의 done 역할 (데이터 수신 완료 신호)    
    logic [15:0] data_16;

    // Master의 GPIO_PIN_x 매크로 위치(비트 4, 5, 6, 7)에 정확히 매핑하여 전송
    // btn_u(bit 4), btn_l(bit 5), btn_r(bit 6), btn_d(bit 7)
    assign tx_data = {btn_d, btn_r, btn_l, btn_u, 4'b0000};

    I2C_Slave #(
        .SLAVE_ADDR(7'h12)
    ) u_i2c (
        .clk       (clk),
        .reset     (reset),
        .scl       (scl),
        .sda       (sda),
        .tx_data   (tx_data),
        .rx_data   (rx_data),
        .data_valid(data_valid)
    );
    fnd_controller U_FND_CTRL (
        .clk       (clk),
        .reset     (reset),
        .fnd_indata(data_16),
        .fnd_digit (fnd_digit),
        .fnd_data  (fnd_data)
    );

    logic [7:0] first_byte;
    logic       byte_phase;  // 0: 첫 번째, 1: 두 번째
    logic       data_valid_d;
    always_ff @(posedge clk) begin
        data_valid_d <= data_valid;
    end
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            byte_phase <= 0;
            data_16    <= 0;
        end else begin
            // data_valid는 I2C_Slave에서 한 클럭 동안만 High가 됨            
            if (data_valid_d) begin
                if (byte_phase == 0) begin
                    // 첫 번째 바이트 저장 (sw[7:0])                    
                    first_byte <= rx_data;
                    byte_phase <= 1;
                end else begin
                    // 두 번째 바이트(sw[15:8]) 들어오면 조합하여 FND에 16비트 출력                    
                    data_16 <= {rx_data, first_byte};
                    byte_phase <= 0;
                end
            end
        end
    end
endmodule
