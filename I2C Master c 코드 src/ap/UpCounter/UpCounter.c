/*
 * UpCounter.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "UpCounter.h"

hBtn_t hBtnRunStop, hBtnClear;
uint16_t counter = 0;

void UpCounter_Init()
{
	FND_Init();
	LED_Init();
	Button_Init(&hBtnRunStop, GPIOA, GPIO_PIN_4);
	Button_Init(&hBtnClear, GPIOA, GPIO_PIN_7);

	counter = 0;
}

void UpCounter_Excute()
{
//	UpCounter_DisLoop();
	LED_Off(LED_PIN_6|LED_PIN_5|LED_PIN_4);
	LED_On_7();
	LED_Round_Shift_L();

	static upcounter_state_t upCounterState = STOP;

	switch (upCounterState)
	{
	case STOP:
		UpCounter_Stop();
		if (Button_GetState(&hBtnRunStop) == ACT_PUSHED) {
			upCounterState = RUN;
		}
		else if (Button_GetState(&hBtnClear) == ACT_PUSHED) {
			upCounterState = CLEAR;
		}
		break;
	case RUN:
		UpCounter_Run();
		if (Button_GetState(&hBtnRunStop) == ACT_PUSHED) {
			upCounterState = STOP;
		}
		break;
	case CLEAR:
		UpCounter_Clear();
		upCounterState = STOP;
		break;
	default :
		UpCounter_Stop();
		break;
	}
}

void UpCounter_DisLoop()
{
	FND_DispDigit();
}

void UpCounter_Run()
{
	static uint32_t prevTimeCounter = 0;

	if (millis() - prevTimeCounter <= 100-1) {
		return;
	}
	prevTimeCounter = millis();

	FND_SetNum(counter++);
}

void UpCounter_Stop()
{
	FND_SetNum(counter); // 현재 counter 값만 출력.
}

void UpCounter_Clear()
{
	counter = 0;
	FND_SetNum(0);
}
