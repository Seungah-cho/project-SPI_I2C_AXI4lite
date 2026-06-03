/*
 * Switch.h
 *
 *  Created on: 2026. 5. 4.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_SWITCH_SWITCH_H_
#define SRC_DRIVER_SWITCH_SWITCH_H_




#include "../../HAL/GPIO/GPIO.h"

void Switch_Init(void);
uint16_t Switch_GetState(void);



#endif /* SRC_DRIVER_SWITCH_SWITCH_H_ */
