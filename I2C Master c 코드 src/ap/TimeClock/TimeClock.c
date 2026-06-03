/*
 * TimeClock.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "TimeClock.h"


timeState_t timeState = HOUR_MIN;
timeClock_t timeClock;

hBtn_t hbtnTimeMode;

void TimeClock_Init()
{
	TimeClock_SetTime(12,0,0,0);
	Button_Init(&hbtnTimeMode, GPIOA, GPIO_PIN_6);
}

void TimeClock_SetTime(uint8_t hh, uint8_t mm, uint8_t ss, uint8_t ms)
{
	timeClock.hour = hh;
	timeClock.min = mm;
	timeClock.sec = ss;
	timeClock.msec = ms;
}

void TimeClock_Excute()
{
	TimeClock_DispTime();
	LED_Off(LED_PIN_7);
	LED_On_6();
	LED_Round_Shift_R();
//	LED_Shift(RightShift);
}

void TimeClock_IncTime() // increase
{ 						// if문 안에 if문 계속 넣으면 안좋으니까 이렇게 함.
	if (timeClock.msec < 100-1){
		timeClock.msec++;
		return;
	}
	timeClock.msec = 0; // 99인 경우.

	if (timeClock.sec < 60-1){
		timeClock.sec++; // 59가 됨.
		return;
	}
	timeClock.sec = 0;

	if (timeClock.min < 60-1){
		timeClock.min++; // 59가 됨.
		return;
	}
	timeClock.min = 0;

	if (timeClock.hour < 24-1){
		timeClock.hour++; // 59가 됨.
		return;
	}
	timeClock.hour = 0;
}

void TimeClock_DispTime()
{
	switch(timeState)
	{
		case HOUR_MIN:
//			LED_Clear();
			LED_Off(LED_PIN_4);
			TimeClock_DispHourMin();
			LED_On_5();
			if (Button_GetState(&hbtnTimeMode) == ACT_RELEASED) {
				timeState = SEC_MSEC;
			}
			break;
		case SEC_MSEC:
//			LED_Clear();
			LED_Off(LED_PIN_5);
			TimeClock_DispSecMSec();
			LED_On_4();
			if (Button_GetState(&hbtnTimeMode) == ACT_RELEASED) {
				timeState = HOUR_MIN;
			}
			break;
	}

	if (timeClock.msec < 50) {
		FND_SetDP(FND_DIGIT_100, ON);
	}
	else {
		FND_SetDP(FND_DIGIT_100, OFF);
	}
}


void TimeClock_DispHourMin()
{
	uint16_t timeNum;

	timeNum = timeClock.hour * 100 + timeClock.min;

	FND_SetNum(timeNum);
}

void TimeClock_DispSecMSec()
{
	uint16_t timeNum;

	timeNum = timeClock.sec * 100 + timeClock.msec;

	FND_SetNum(timeNum);
}




