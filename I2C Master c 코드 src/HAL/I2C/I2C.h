/*
 * I2C.h
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#ifndef SRC_HAL_I2C_I2C_H_
#define SRC_HAL_I2C_I2C_H_







#include "xparameters.h"
#include <stdint.h>

typedef struct {
    uint32_t CR;    // Control Register
    uint32_t SR;    // Status Register
    uint32_t TXR;   // TX Data Register
    uint32_t RXR;   // RX Data Register
} I2C_Typedef_t;

#define I2C_BASEADDR    XPAR_I2C_MASTER_0_S00_AXI_BASEADDR

#define I2C_MASTER      ((I2C_Typedef_t *)(I2C_BASEADDR))

#define I2C_CR_START    (1 << 0)
#define I2C_CR_WRITE    (1 << 1)
#define I2C_CR_READ     (1 << 2)
#define I2C_CR_STOP     (1 << 3)
#define I2C_CR_ACK_IN   (1 << 4)

#define I2C_SR_BUSY     (1 << 0)
#define I2C_SR_DONE     (1 << 1)
#define I2C_SR_ACK_OUT  (1 << 2)


void I2C_Init(void);
uint8_t I2C_ReadSlave(uint8_t slave_addr);
void I2C_WriteSlave(uint8_t slave_addr, uint8_t tx_data);
void I2C_WriteSlave16Bit(uint8_t slave_addr, uint16_t data);










#endif /* SRC_HAL_I2C_I2C_H_ */
