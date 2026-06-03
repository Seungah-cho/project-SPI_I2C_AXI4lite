/*
 * LED.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "LED.h"






void LED_Init()
{
	GPIO_SetMode(LED_PORT, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, OUTPUT);
}

void LED_Clear()
{
	GPIO_WritePort(LED_PORT, LED_ALL_OFF);
}


void LED_On_0 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_0, SET);
}

void LED_On_1 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_1, SET);
}

void LED_On_2 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_2, SET);
}

void LED_On_3 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_3, SET);
}

void LED_On_4 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_4, SET);
}

void LED_On_5 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_5, SET);
}

void LED_On_6 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_6, SET);
}

void LED_On_7 ( )
{
	GPIO_WritePin(LED_PORT, LED_PIN_7, SET);
}

void LED_Off(uint32_t LED_Pin)
{
	GPIO_WritePin(LED_PORT, LED_Pin, RESET);
}

static uint8_t led_pos = 3;

void LED_Round_Shift_L()
{
	static uint32_t prev = 0;

    if (millis() - prev >= 100)
    {
        prev = millis();

        if (led_pos == 3)
            led_pos = 0;
        else
            led_pos++;

        GPIO_WritePort(LED_PORT, (1 << led_pos));
    }
}


void LED_Round_Shift_R()
{

	static uint32_t prev = 0;

    if (millis() - prev >= 500)
    {
        prev = millis();

        if (led_pos == 0)
            led_pos = 3;
        else
            led_pos--;

        GPIO_WritePort(LED_PORT, (1 << led_pos));
    }
}


