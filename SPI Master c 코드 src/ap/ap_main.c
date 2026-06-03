#include "xil_printf.h"
#include "xil_exception.h"
#include "ap_main.h"
#include "../HAL/TMR/TMR.h"
#include "../driver/Button/Button.h"
#include "../driver/Switch/Switch.h"
#include "UpCounter/UpCounter.h"
#include "TimeClock/TimeClock.h"
#include "interrupt.h"
#include "../HAL/SPI/SPI.h"

typedef enum {
    TIME_CLOCK,
    UP_COUNTER
} modeState_t;

modeState_t modeState = TIME_CLOCK;
hBtn_t hbtnMode;

extern uint8_t g_slave_btn_state;

void ap_init()
{
    SPI_Init();
    Switch_Init();

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


void ap_excute() {
    static uint32_t prev_spi_time = 0;

    if (millis() - prev_spi_time >= 50) {
        prev_spi_time = millis();

        uint16_t switch_data = Switch_GetState();

        Xil_ExceptionDisable();
        GPIO_WritePin(SPI_PORT, SPI_CS_N_PIN, RESET);
        delay_us(10);

        g_slave_btn_state = SPI_Transfer16Bit(switch_data);
        delay_us(10);

        GPIO_WritePin(SPI_PORT, SPI_CS_N_PIN, SET);
        Xil_ExceptionEnable();
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


