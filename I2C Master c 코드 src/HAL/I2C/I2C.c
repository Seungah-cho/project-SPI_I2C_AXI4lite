#include "I2C.h"
#include "../../common/common.h"

void I2C_Init(void)
{
    I2C_MASTER->CR = 0x00;
}

uint8_t I2C_ReadSlave(uint8_t slave_addr)
{
    uint8_t rx_data = 0;

    I2C_MASTER->CR = I2C_CR_START;
    delay_us(20);  
    I2C_MASTER->CR = 0x00;

    I2C_MASTER->TXR = (slave_addr << 1) | 0x01;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100); 
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->CR  = I2C_CR_READ | I2C_CR_ACK_IN;
    delay_us(100);

    rx_data = (uint8_t)(I2C_MASTER->RXR);
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->CR = I2C_CR_STOP;
    delay_us(20);
    I2C_MASTER->CR = 0x00;

    return rx_data;
}

void I2C_WriteSlave(uint8_t slave_addr, uint8_t tx_data)
{
    I2C_MASTER->CR = I2C_CR_START;
    delay_us(20);
    I2C_MASTER->CR = 0x00;

    I2C_MASTER->TXR = (slave_addr << 1) | 0x00;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100);
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->TXR = tx_data;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100);
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->CR = I2C_CR_STOP;
    delay_us(20);
    I2C_MASTER->CR = 0x00;
}

void I2C_WriteSlave16Bit(uint8_t slave_addr, uint16_t data)
{
    uint8_t low_byte = (uint8_t)(data & 0xFF);
    uint8_t high_byte = (uint8_t)((data >> 8) & 0xFF);

    I2C_MASTER->CR = I2C_CR_START;
    delay_us(20);
    I2C_MASTER->CR = 0x00;

    I2C_MASTER->TXR = (slave_addr << 1) | 0x00;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100);
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->TXR = low_byte;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100);
    I2C_MASTER->CR  = 0x00;

    I2C_MASTER->TXR = high_byte;
    I2C_MASTER->CR  = I2C_CR_WRITE;
    delay_us(100);
    I2C_MASTER->CR  = 0x00;
    
    // STOP
    I2C_MASTER->CR = I2C_CR_STOP;
    delay_us(20);
    I2C_MASTER->CR = 0x00;
}
