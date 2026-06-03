#include "SPI.h"

#define REG_WRITE(Addr, Value)  (*(volatile uint32_t *)(Addr) = (Value))
#define REG_READ(Addr)          (*(volatile uint32_t *)(Addr))


void SPI_Init(void)
{
    GPIO_SetMode(GPIOA, GPIO_PIN_4, OUTPUT);
    GPIO_WritePin(GPIOA, GPIO_PIN_4, SET);

    REG_WRITE(SPI_BASEADDR + SPI_REG_CLK_DIV, 100);

    REG_WRITE(SPI_BASEADDR + SPI_REG_CTRL, 0x00);
}

uint8_t SPI_Transfer(uint8_t txData)
{
    uint8_t rxData = 0;

    REG_WRITE(SPI_BASEADDR + SPI_REG_TX_DATA, txData);

    REG_WRITE(SPI_BASEADDR + SPI_REG_CTRL, SPI_CTRL_START);

    while ((REG_READ(SPI_BASEADDR + SPI_REG_STATUS) & SPI_STATUS_BUSY) == 0) {
        
    }

    REG_WRITE(SPI_BASEADDR + SPI_REG_CTRL, 0x00);

    while ((REG_READ(SPI_BASEADDR + SPI_REG_STATUS) & SPI_STATUS_BUSY) != 0) {
        
    }

    rxData = (uint8_t)REG_READ(SPI_BASEADDR + SPI_REG_RX_DATA);

    return rxData;
}


uint8_t SPI_Transfer16Bit(uint16_t data16)
{
    uint8_t rxData;

    rxData = SPI_Transfer((uint8_t)(data16 & 0xFF));

    delay_us(20);

    SPI_Transfer((uint8_t)((data16 >> 8) & 0xFF));

    return rxData;
}

