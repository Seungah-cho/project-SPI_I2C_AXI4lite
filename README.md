# AXI4-Lite Based SPI/I2C Master IP Design, Verification and FPGA Demonstration

## Overview

MicroBlaze 기반 SoC 환경에서 AXI4-Lite 인터페이스를 사용하는 SPI/I2C Master IP를 설계하고, FPGA 간 데이터 통신 및 주변장치 제어를 구현한 프로젝트입니다.

단순히 통신 기능을 구현하는 데서 끝나지 않고, UVM 기반 검증 환경을 구축하여 SPI Master IP를 검증하고 실제 FPGA 보드에서 동작을 확인하였습니다.

### Key Features

* AXI4-Lite 기반 SPI Master IP 설계
* AXI4-Lite 기반 I2C Master IP 설계
* UVM Verification Environment 구축
* FPGA 간 양방향 데이터 통신 구현
* Embedded C 기반 Driver 및 Application 개발
* 실제 FPGA Demo를 통한 HW/SW Integration 검증

---

## System Architecture

### Hardware Platform

* Xilinx Basys3 FPGA
* MicroBlaze Processor
* AXI4-Lite Interconnect
* SPI Master IP
* I2C Master IP
* FND Controller
* GPIO

> Architecture Diagram

(이미지 삽입)

---

## Project Goals

본 프로젝트의 목표는 다음과 같습니다.

1. SPI/I2C 통신 프로토콜 구현
2. AXI4-Lite 기반 Peripheral IP 설계
3. UVM 기반 기능 검증 수행
4. Embedded Software와 Hardware IP 통합
5. FPGA 간 실시간 데이터 전송 구현

---

# DUT Description

AXI4-Lite 기반 Master IP를 설계하였으며,

SPI 버전과 I2C 버전을 구현하였습니다.

MicroBlaze는 Control/Status Register를 통해 각 IP를 제어합니다.

## AXI-SPI Master

MicroBlaze 프로세서가 AXI4-Lite 인터페이스를 통해 SPI Master IP를 제어하도록 설계하였습니다.

### 주요 기능

* SPI 데이터 송신
* SPI 데이터 수신
* AXI4-Lite Register Interface
* Status / Control Register

### Data Flow

Master FPGA

```text
16-bit Switch
      ↓
 SPI Master
      ↓
 SPI Bus
```

Slave FPGA

```text
 SPI Slave
      ↓
FND Controller
      ↓
7-Segment Display
```

또한 Slave FPGA의 버튼 상태를 Master FPGA로 전달하여 시스템 동작 모드(Watch/UpCounter)를 변경할 수 있도록 구현하였습니다.

---

## AXI-I2C Master

I2C Master IP를 AXI4-Lite 인터페이스와 연결하여 FPGA 간 데이터 통신을 수행하였습니다.

AXI-SPI Master에서 SPI 통신부만 I2C 통신으로 바꿨습니다.

### 주요 기능

* I2C 데이터 송신
* I2C 데이터 수신
* AXI4-Lite Register Interface
* Status / Control Register

---

# Verification

SPI Master IP에 대해 UVM 기반 검증 환경을 구축하였습니다.

## Verification Environment

### Components

* Sequencer
* Driver
* Monitor
* Scoreboard

> UVM Architecture

<img width="1018" height="795" alt="UVM 구조" src="https://github.com/user-attachments/assets/19b2ba7b-db30-49bb-9a5b-dd96a02c9f31" />


---

## Test Scenario #1 : Basic Function Test (Random)

### Objective

정상적인 송수신 기능 검증

### Method

* AXI4-Lite를 통해 CLKDIV, TXDATA, CTRL 레지스터 접근 검증
* Start bit 제어를 통한 SPI 전송 수행
* STATUS Busy bit Polling을 통한 전송 완료 확인
* RXDATA Read 검증
* MOSI-MISO Loopback 환경에서 송신 데이터와 수신 데이터 일치 여부 검증

### Result

모든 Transaction PASS

---

## Test Scenario #2 : Continuous Transaction Test

### Objective

장시간 연속 동작 검증

### Method

* 15,000회의 연속 SPI 송수신 수행
* 각 트랜잭션 완료 후 다음 전송이 정상 수행되는지 확인
* 장시간 동작 시 Deadlock 및 데이터 손실 여부 검증
* 모든 Loopback 결과에 대한 Match 검증

### Result

오류 없이 연속 동작 확인

---

## Test Scenario #3 : Corner Case Test

### Objective

Worst-Case 상황 검증

### Method

* All-0, All-1, Toggle, Walking-1, Walking-0 패턴 검증
* 다양한 경계값 데이터에 대한 SPI 및 AXI 인터페이스 동작 검증
* 정의된 Coverage Bin 및 Cross Coverage 수집
* Corner Pattern 기반 기능 커버리지 달성 여부 확인

### Test Pattern

```text
0x00, 0xFF, 0x55, 0xAA,
Single-bit Shift Pattern (8'h01, 8'h02, 8'h04 ... 8'h80, 8'hFE, 8'h7F)
```

### Result
<img width="2518" height="1204" alt="image" src="https://github.com/user-attachments/assets/20046913-d903-4d2e-acaf-8ac1feeddbbb" />

모든 패턴 정상 동작

---

## Test Scenario #4 : Reset Test

### Objective

통신 중 강제 Reset 상황 검증

((((((((((((((((((((((((((((((((((((((((((((((((((((((( 추가하기 )))))))))))))))))))))))))))))))))))))))))

---

# Coverage Plan

Functional Coverage를 이용하여 SPI Master의 데이터 전송 기능을 검증하였습니다.

## Coverage Items

### 1. Master TX Data

* Master 전송 데이터의 분포 확인
* Corner Pattern 발생 여부 확인

### 2. Slave TX Data

* Sequence에서 생성된 Slave TX 데이터의 분포 확인
* Corner Pattern 발생 여부 확인

### 3. Cross Coverage

* Master TX Data와 Slave TX Data의 다양한 조합 생성 여부 확인

---

# Simulation Results

## Basic Function Test

Loopback 환경에서 TX Data와 RX Data가 동일하게 수신되는 것을 확인하였습니다.

> Example

```text
TX = 0x27
RX = 0x27
```

(Waveform 이미지 삽입)

---

## Continuous Test

15,000회 연속 Transaction 수행

* PASS

(결과 이미지 삽입)

---

## Corner Case Test

모든 Coverage Hit 확인

* PASS

(Coverage Report 이미지 삽입)

---

# FPGA Demonstration
<img width="1280" height="434" alt="SPI,I2C보드 사진" src="https://github.com/user-attachments/assets/31fcbeb6-2063-48bf-bc56-7170d22af9dc" />


## SPI Demo

### Master → Slave

* Master 16-bit Switch 값 전송

### Slave → Master

* Slave Button 상태 전송

### Application Behavior

수신된 버튼 값에 따라 Master 시스템 모드 변경, 모드에 따른 led 출력

* Up Counter Mode
* Clock Mode

(동작 영상 삽입)

---

## I2C Demo

### Master → Slave

* Master 16-bit Switch 값 전송

### Slave → Master

* Slave Button 상태 전송

### Application Behavior

수신된 버튼 값에 따라 Master 시스템 모드 변경, 모드에 따른 led 출력

* Up Counter Mode
* Clock Mode

(동작 영상 삽입)

---

# Issues & Debugging

## SPI Status Register Synchronization Issue
<img width="1042" height="470" alt="SPI master 잘못된 파형" src="https://github.com/user-attachments/assets/63258792-ebd1-47be-87df-6bc5892507d5" />
<img width="948" height="476" alt="SPI master 잘 나온 파형" src="https://github.com/user-attachments/assets/b0a4b3f0-8047-4ba5-a269-f6cc0abceab1" />
(위) 문제 파형 / (아래) 정상 파형

### Problem

Slave 버튼 입력이 Master로 정상 반영되지 않는 문제 발생.

Logic Analyzer에서 MISO를 통해 버튼 데이터가 수신되는 것 확인하였지만, Master는 버튼 입력을 인식하지 못해 Master의 동작이 변경되지 않음.

### Cause

SPI 전송 완료를 DONE 플래그로 판단.

이 과정에서 START 신호가 의도보다 길게 유지되어 SPI Master FSM이 동일한 전송을 여러 차례 반복 수행.

Logic Analyzer의 파형을 통해 동일한 MOSI 데이터가 연속적으로 전송되었으며(SCLK 32개 발생), 최초에 수신한 유효한 버튼 데이터(0x20)가 이후 반복 전송 과정에서 수신된 0x00 데이터로 RX register에 덮어써짐을 확인함.

CPU는 최종적으로 저장된 0x00을 읽어 버튼 입력을 인식하지 못함.

### Solution

DONE 대신 BUSY 플래그를 사용하여 SPI FSM이 실제로 동작을 시작했는지 먼저 확인한 후 START 비트를 즉시 클리어하도록 수정.

이후 BUSY가 LOW(0)가 될 때까지 대기하여 전송 완료 확인.

이를 통해 START 신호를 펄스 형태로 제어하여 중복 전송 방지.

최초 수신한 버튼 데이터가 RX 레지스터에 정상적으로 유지되어 Slave 버튼 입력을 안정적으로 인식할 수 있도록 개선.

### Learned

Logic Analyzer를 활용해 SPI 파형을 분석하며 Software-Hardware 간 상태 동기화 문제를 직접 해결한 경험을 얻었습니다. 이를 통해 BUSY/DONE 신호를 이용한 핸드셰이크 설계의 중요성과 실제 파형 기반 디버깅의 필요성을 체감할 수 있었으며, 검증 과정에서 원인을 분석하고 해결하는 문제 해결 능력을 향상시킬 수 있었습니다.

---

## I2C Timing Issue

### Problem

Watch(시계) 기능이 정상적으로 동작하지 않음

### Cause

Done 신호가 1 Clock 동안만 HIGH로 유지되어 Software가 상태 변화를 놓침

(Sortware가 AXI bus를 통해 상태 reg 읽어오는데 수십 클럭 소요)

### Solution

I2C 동작 시간을 고려하여 delay_us() 적용

(done bit를 기다리는 대신 물리적 시간 대기)

---

# What I Learned

이번 프로젝트를 통해 단순한 RTL 설계를 넘어 HW/SW Integration 과정을 경험할 수 있었다.

특히 MicroBlaze와 AXI4-Lite 인터페이스를 이용하여 Peripheral IP를 제어하면서 프로세서 기반 시스템의 동작 구조를 이해할 수 있었다.

또한 UVM 검증 환경을 구축하고 실제 FPGA에서 동작을 확인하는 과정에서 다음과 같은 점을 배울 수 있었다.

* AXI4-Lite 기반 Peripheral 설계 방법
* SPI/I2C 프로토콜 구현
* UVM 기반 Verification Flow
* Functional Coverage 기반 검증
* Hardware-Software Synchronization 중요성
* FPGA 기반 SoC 개발 프로세스

---

# Tech Stack

### Hardware

* Verilog HDL, SystemVerilog
* AXI4-Lite Interconnect
* SPI
* I2C
* Xilinx Basys3 FPGA
* MicroBlaze (soft CPU core)

### Verification

* SystemVerilog
* UVM

### Software

* Embedded C

### Tools

* Vivado
* Xilinx Vitis
