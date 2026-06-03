#include "Button.h"

// SPI 통신으로 받아온 Slave 보드의 버튼 상태를 저장할 전역 변수
uint8_t g_slave_btn_state = 0;

void Button_Init(hBtn_t *hbtn, GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin)
{
    // 더 이상 Master 보드의 로컬 GPIO를 INPUT으로 설정하지 않으므로 주석 처리
    // GPIO_SetMode(GPIOx, GPIO_Pin, INPUT);

    hbtn->GPIOx = GPIOx;
    hbtn->GPIO_Pin = GPIO_Pin; // 이제 이 값은 단순한 '비트 마스크' 역할만 합니다.
    hbtn->prevState = RELEASED;
}

button_act_t Button_GetState(hBtn_t *hbtn)
{
    // 물리적 GPIO 핀을 읽는 대신, 전역 변수에서 해당 버튼 비트를 추출
    button_state_t curState = (g_slave_btn_state & hbtn->GPIO_Pin) ? PUSHED : RELEASED;

    if (hbtn->prevState == RELEASED && curState == PUSHED) {
        delay_ms(1); // 기존 디바운싱 로직 유지
        hbtn->prevState = PUSHED;
        return ACT_PUSHED;
    }
    else if (hbtn->prevState == PUSHED && curState == RELEASED) {
        delay_ms(1);
        hbtn->prevState = RELEASED;
        return ACT_RELEASED;
    }
    return NO_ACT;
}
