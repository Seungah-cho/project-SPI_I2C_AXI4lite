/*
 * interrupt.c
 *
 *  Created on: 2026. 4. 29.
 *      Author: kccistc
 */

#include "interrupt.h"

XIntc IntrController;

// 1khz : 1msec interrupt service routine
void TMR1_ISR(void *CallbackRef)
{
	millis_inc();
	UpCounter_DisLoop();
}

// 10msec interrupt service routine
void TMR2_ISR(void *CallbackRef)
{
	TimeClock_IncTime();
}

int SetupInterruptSystem() // p: pointer
{
	int status;

	// 1. 인터럽트 컨트롤러 초기화
	status = XIntc_Initialize(&IntrController, INTC_DEV_ID);
	if (status != XST_SUCCESS) {    // 문제 있는지 없는지 확인.
		return XST_FAILURE;
	}

	// 2-1. TMR1_ISR 함수를 Intc(인터럽트 컨트롤러)와 연결하는 절차
	status = XIntc_Connect(&IntrController, TMR1_DEV_ID, (XInterruptHandler)TMR1_ISR, (void *)0);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	// 2-2. TMR2_ISR 함수를 Intc와 연결
	status = XIntc_Connect(&IntrController, TMR2_DEV_ID, (XInterruptHandler)TMR2_ISR, (void *)0);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//3. Interrupt Controller 시작 (Hardware Mode)
	status = XIntc_Start(&IntrController, XIN_REAL_MODE);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// 4. 각각의 인터럽트 채널 활성화
	XIntc_Enable(&IntrController, TMR1_DEV_ID);
	XIntc_Enable(&IntrController, TMR2_DEV_ID);

	// 5. MicroBlaze의 Exception 초기화 및 활성화 (인터럽트를 통틀어서 하는거를 exception이라 한다.) // CPU와 인터럽트 컨트롤러를 연결시켜주는 부분.
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler)XIntc_InterruptHandler,
			&IntrController);
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}
