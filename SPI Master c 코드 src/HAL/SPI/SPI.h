/*
 * SPI.h
 *
 *  Created on: 2026. 5. 3.
 *      Author: kccistc
 */

#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_





#include <stdint.h>
#include "xparameters.h"
#include "../../common/common.h"
#include "../GPIO/GPIO.h" // CS_N


#define SPI_BASEADDR      XPAR_SPI_MASTER_0_S00_AXI_BASEADDR
#define SPI_PORT          GPIOA
#define SPI_CS_N_PIN      GPIO_PIN_4

#define SPI_REG_CTRL      0x00
#define SPI_REG_STATUS    0x04
#define SPI_REG_TX_DATA   0x08
#define SPI_REG_RX_DATA   0x0C
#define SPI_REG_CLK_DIV   0x10

#define SPI_CTRL_START    0x01
#define SPI_CTRL_CPOL     0x02
#define SPI_CTRL_CPHA     0x04

#define SPI_STATUS_BUSY   0x01
#define SPI_STATUS_DONE   0x02

void SPI_Init(void);
uint8_t SPI_Transfer(uint8_t txData);
uint8_t SPI_Transfer16Bit(uint16_t data16);







#endif /* SRC_HAL_SPI_SPI_H_ */
