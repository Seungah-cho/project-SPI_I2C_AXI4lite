#include "xil_printf.h"
#include "xil_exception.h"
#include "ap_main.h"
#include "../HAL/TMR/TMR.h"
#include "../driver/Button/Button.h"
#include "UpCounter/UpCounter.h"
#include "TimeClock/TimeClock.h"
#include "interrupt.h"
#include "../HAL/I2C/I2C.h"
#include "../common/common.h"

typedef enum {
    TIME_CLOCK,
    UP_COUNTER
} modeState_t;

modeState_t modeState = TIME_CLOCK;
hBtn_t hbtnMode;

extern uint8_t g_slave_btn_state;

// Slave ����� I2C �ּ�
#define SLAVE_BOARD_ADDR 0x12

void ap_init()
{
    I2C_Init(); 

    Button_Init(&hbtnMode, GPIOA, GPIO_PIN_5);
    UpCounter_Init();
    TimeClock_Init();
    SetupInterruptSystem();

    TMR_SetPSC(TMR0, 100-1);
    TMR_SetARR(TMR0, 0xffffffff);
    TMR_StopIntr(TMR0);
    TMR_StartTimer(TMR0);

    TMR_SetPSC(TMR1, 100-1);
    TMR_SetARR(TMR1, 1000-1);
    TMR_StartIntr(TMR1);
    TMR_StartTimer(TMR1);

    TMR_SetPSC(TMR2, 100-1);
    TMR_SetARR(TMR2, 10000-1);
    TMR_StartIntr(TMR2);
    TMR_StartTimer(TMR2);
}

void ap_excute()
{
    static uint32_t prev_com_time = 0;

    if (millis() - prev_com_time >= 10) {
        prev_com_time = millis();

        I2C_WriteSlave16Bit(SLAVE_BOARD_ADDR, Switch_GetState());

        delay_us(50);

        g_slave_btn_state = I2C_ReadSlave(SLAVE_BOARD_ADDR);
    }

    switch (modeState)
    {
    case TIME_CLOCK:
        TimeClock_Excute();
        if (Button_GetState(&hbtnMode) == ACT_RELEASED) {
            modeState = UP_COUNTER;
            FND_SetDP(FND_DIGIT_100, OFF);
        }
        break;
    case UP_COUNTER:
        UpCounter_Excute();
        if (Button_GetState(&hbtnMode) == ACT_RELEASED) {
            modeState = TIME_CLOCK;
        }
        break;
    }
}


