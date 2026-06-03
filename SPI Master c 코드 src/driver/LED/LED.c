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

//void LED_On (uint8_t chooseled, uint8_t num)
//void LED_On (uint8_t num)
//{
//	GPIO_WritePin(LED_PORT, (LED_PIN_0<<num), RESET); // led[num] on
////	GPIO_WritePin(LED_PORT, (LED_PIN_0), SET);
//
////	if(((chooseled>>num) & 0x01) == 1) {
////		GPIO_WritePin(LED_PORT, (LED_PIN_0<<num), SET); // led[0] on
////	}
//}

//void LED_On(uint32_t LED_PIN)
//{
//	GPIO_WritePin(LED_PORT, LED_PIN, SET);
//}

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

//static uint16_t led_tick = 0;
//void LED_Shift_R(uint8_t time)
void LED_Round_Shift_R()
{
//	uint8_t i;
//	while(1) {
//		for (i=0; i<4; i++) {
//			LED_Clear();
//			GPIO_WritePin(LED_PORT, (LED_PIN_3 >> i), SET);
//		}
//		LED_Clear();
//		GPIO_WritePin(LED_PORT, LED_PIN_0, SET);
//	}
//	led_tick++;
//
//    if (led_tick >= 5)   // 100ms °ø 5 = 0.5√ 
//    {
//        led_tick = 0;
//
//        if (led_pos == 0)
//            led_pos = 3;
//        else
//            led_pos--;
//
//        GPIO_WritePort(LED_PORT, (1 << led_pos));
//    }
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

//typedef struct{
//	uint8_t Right;
//	uint8_t Left;
//}Shift_state_t;
//Shift_state_t shift_state = { 3, 0 };
//
//void LED_Shift(int RL){
//	static uint8_t ShiftState;
//
//	if(RL == RightShift) 			ShiftState = (shift_state.Right) % 4;
//	else if(RL == LeftShift) 		ShiftState = shift_state.Left;
//
//	switch (ShiftState) {
//	case 0:
//		LED_Clear();
//		LED_On_0 ( );
//		break;
//	case 1:
//		LED_Clear();
//		LED_On_1 ( );
//		break;
//	case 2:
//		LED_Clear();
//		LED_On_2 ( );
//		break;
//	case 3:
//		LED_Clear();
//		LED_On_3 ( );
//		break;
//	}
//}







//void LED_Init(){
//	GPIO_SetMode(LED_PORT, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, OUTPUT);
//}
//
//void LED_SetON(uint32_t LED_Pin){
//	GPIO_WritePin(LED_PORT, LED_Pin, LED_ON);
//}
//
//void LED_SetOFF(uint32_t LED_Pin){
//	GPIO_WritePin(LED_PORT, LED_Pin, LED_OFF);
//}
//
//void LED_AllOff(){
//	GPIO_WritePin(LED_PORT, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, LED_OFF);
//}
//
//typedef struct{
//	uint8_t Right;
//	uint8_t Left;
//}Shift_state_t;
//Shift_state_t shift_state = { 3, 0 };
//
//void LED_Shift(int RL){
//	static uint8_t ShiftState;
//
//	if(RL == RightShift) 			ShiftState = (shift_state.Right) % 4;
//	else if(RL == LeftShift) 		ShiftState = shift_state.Left;
//
//	switch (ShiftState) {
//	case 0:
//		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
//		LED_SetON(LED_PIN_0);
//		break;
//	case 1:
//		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
//		LED_SetON(LED_PIN_1);
//		break;
//	case 2:
//		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
//		LED_SetON(LED_PIN_2);
//		break;
//	case 3:
//		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
//		LED_SetON(LED_PIN_3);
//		break;
//	}
//}
//
//void LED_IncShiftState(){
//	if(shift_state.Left > 3) shift_state.Left = 0;
//	else shift_state.Left++;
//}
//
//void LED_DecShiftState(){
//	if(shift_state.Right < 0) shift_state.Right = 3;
//	else shift_state.Right--;
//}

