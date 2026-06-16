# FPGA People Counter & Access Control

## 📌 Overview
A hardware-level directional people counting system implemented in **Verilog HDL** for the **Xilinx Basys 3 FPGA** board. This project was designed to accurately track room occupancy using external optical sensors. It features a robust Finite State Machine (FSM) to prevent false triggers and includes a secret "VIP" authorization mode built with shift registers.

## 🚀 Key Features
* **Directional Detection (FSM):** A highly reliable 7-state Finite State Machine that tracks the sequence of sensor interruptions, ensuring that people are only counted when they fully pass through the gate. It completely ignores false triggers or people turning back halfway.
* **Hardware Multiplexing:** Custom implementation of time-division multiplexing to drive a 4-digit 7-segment display using a single data bus.
* **Cascading BCD Counters:** Custom BCD logic handling carries and borrows across digits (0-9999 range) without relying on high-level mathematical synthesis.
* **VIP Access Mode:** A hidden authorization sequence utilizing a 1Hz clock divider and a 4-bit shift register. Entering the correct sequence (1-1-0-1) bypasses the "Room Full" hardware lock.

## 🛠️ Hardware Requirements
* **Board:** Digilent Basys 3 (Artix-7 FPGA)
* **Sensors:** 2x Optical / IR Obstacle Sensors (connected via Pmod JA)
* **Clock:** 100 MHz onboard oscillator

## 🧠 System Architecture
### The Finite State Machine (FSM)
The core logic relies on an FSM to determine the direction of movement. 
* **States 1-3 (Entry):** Sensor A blocked -> Sensors A & B blocked -> Sensor B blocked -> Clear (Triggers `enter_pulse`).
* **States 4-6 (Exit):** Sensor B blocked -> Sensors A & B blocked -> Sensor A blocked -> Clear (Triggers `exit_pulse`).
* **Fallback:** Any incomplete sequence securely returns the system to the `0` (Idle) state.

## ⚙️ How to Run
1. Create a new RTL project in **Xilinx Vivado**.
2. Select the `xc7a35tcpg236-1` part (Basys 3).
3. Add `fpga_project.v` as the design source.
4. Add `fpga_project.xdc` as the constraints file.
5. Generate Bitstream and program the device.

## 👨‍💻 Author
**Kacper Tytko** *Electronics and Telecommunications Engineering*
