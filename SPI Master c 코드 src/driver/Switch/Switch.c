/*
 * Switch.c
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */


#include "Switch.h"

void Switch_Init(void)
{
    GPIO_SetMode(GPIOD, GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7, INPUT);
    GPIO_SetMode(GPIOE, GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5 | GPIO_PIN_6 | GPIO_PIN_7, INPUT);
}

uint16_t Switch_GetState(void)
{
    uint16_t sw_state = 0;

    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_0) == 1) ? (1 << 0) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_1) == 1) ? (1 << 1) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_2) == 1) ? (1 << 2) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_3) == 1) ? (1 << 3) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_4) == 1) ? (1 << 4) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_5) == 1) ? (1 << 5) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_6) == 1) ? (1 << 6) : 0;
    sw_state |= (GPIO_ReadPin(GPIOD, GPIO_PIN_7) == 1) ? (1 << 7) : 0;

    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_0) == 1) ? (1 << 8) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_1) == 1) ? (1 << 9) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_2) == 1) ? (1 << 10) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_3) == 1) ? (1 << 11) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_4) == 1) ? (1 << 12) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_5) == 1) ? (1 << 13) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_6) == 1) ? (1 << 14) : 0;
    sw_state |= (GPIO_ReadPin(GPIOE, GPIO_PIN_7) == 1) ? (1 << 15) : 0;

    return sw_state;
}
