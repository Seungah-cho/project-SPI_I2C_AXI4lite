/*
 * common.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#include "common.h"

uint32_t millis_tick = 0;

uint32_t millis()
{
	return millis_tick;
}

void millis_inc()
{
	millis_tick++;
}

void delay_ms(uint32_t msec)
{
//	usleep(msec*1000);
	delay_us(msec*1000);
}

void delay_us(uint32_t usec)
{
//	static uint32_t prevtimer = 0;
	uint32_t prevtimer = TMR_GetCNT(TMR0);
	while (TMR_GetCNT(TMR0) - prevtimer < usec);

//	while (curtimer - prevtimer < usec);
//	prevtimer = curtimer; // 위의 while문의 조건이 거짓일때 실행됨.
//	usleep(usec);
}
