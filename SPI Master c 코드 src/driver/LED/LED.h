/*
 * LED.h
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LED_LED_H_
#define SRC_DRIVER_LED_LED_H_





#include "../../HAL/GPIO/GPIO.h"






#define LED_PORT	GPIOC

#define LED_PIN_0  	    GPIO_PIN_0
#define LED_PIN_1   	GPIO_PIN_1
#define LED_PIN_2      	GPIO_PIN_2
#define LED_PIN_3      	GPIO_PIN_3
#define LED_PIN_4      	GPIO_PIN_4
#define LED_PIN_5      	GPIO_PIN_5
#define LED_PIN_6      	GPIO_PIN_6
#define LED_PIN_7     	GPIO_PIN_7

#define LED_ON             	1
#define LED_OFF			   	0
#define LED_ALL_ON			0xff
#define LED_ALL_OFF			0x00

void LED_Init();
void LED_Clear();
////void LED_On(uint32_t LED_PIN);
void LED_On_0();
void LED_On_1();
void LED_On_2();
void LED_On_3();
void LED_On_4();
void LED_On_5();
void LED_On_6();
void LED_On_7();
void LED_Off(uint32_t LED_Pin);
void LED_Round_Shift_L();
void LED_Round_Shift_R();

//void LED_Shift(int RL);
//#define RightShift	0
//#define LeftShift	1








#endif /* SRC_DRIVER_LED_LED_H_ */
