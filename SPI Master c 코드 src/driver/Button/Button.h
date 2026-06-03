/*
 * Button.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_BUTTON_BUTTON_H_
#define SRC_DRIVER_BUTTON_BUTTON_H_




#include "../../HAL/GPIO/GPIO.h"
#include "../../common/common.h"

typedef enum {
	RELEASED = 0, // 누르지 않았을 떄.
	PUSHED // 이때가 1.
}button_state_t; // 사용자 정의 자료형

typedef enum {
	NO_ACT = 0,
	ACT_RELEASED,
	ACT_PUSHED
}button_act_t;

typedef struct {
	GPIO_Typedef_t *GPIOx;
	uint32_t GPIO_Pin;
	button_state_t prevState;
}hBtn_t;


void Button_Init(hBtn_t *hbtn, GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin);
button_act_t Button_GetState(hBtn_t *hbtn);




#endif /* SRC_DRIVER_BUTTON_BUTTON_H_ */
