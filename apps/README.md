# Rtems-Dev/apps
The end goal of this project is to refresh my understanding of **Real-Time Operating System (RTOS)** concepts by implementing them on a BeagleBone Black (BBB) running RTEMS.<br>
In the future, I also want to allow users to build for the local qemu environemnt for testing<br>
Rather than building one large application, this project is broken into smaller applications, with each one focusing on a specific RTOS concept or group of related concepts.

## RTOS Topics
The following are the high-level topics I plan to review and implement:
1. Periodic Tasks
2. Task Scheduling / Prioritization
3. GPIO
4. Interrupts
5. Thread Synchronization (Semaphores + Mutexes)
6. Message Queues
7. Producer / Consumer
8. UART Command Shell
9. Memory Management
10. Networking (UDP)

# Applications
Each application below is designed to demonstrate one or more of the RTOS concepts listed above.<br>
At a high level, here are the projects I will dive into: 
- Hello_World
- Traffic_Controller
- Temperature_Monitor
- UART_LED_Controller
- UDP_Fixed_Rate_Sender

## Hello_World
A minimal application that prints `Hello World` to the UART terminal.<br>
The purpose of this application is primarily to verify that:
- RTEMS can be successfully built and deployed to the BBB.
- The application can be executed on the target.
- Output can be read from the UART/JTAG connection.

This serves as the initial hardware and development-environment sanity check before moving on to more complex applications.

**Concepts:**
- Basic RTEMS application
- UART output
- BBB deployment

---

## Traffic Controller
A small traffic-light controller using three GPIO outputs connected to LEDs, and two button intputs.<br>
The application models a basic traffic intersection and introduces external events through interrupts.<br>
The system includes:
- Three GPIO outputs representing the traffic lights.
- A pedestrian button interrupt.
- An emergency-vehicle button interrupt.
- Periodic traffic-light state changes.
- UART status logging.

This application is intended to explore how multiple RTOS tasks interact with hardware events and how task priorities affect system behavior.

**Concepts:**
- Periodic Tasks
- Task Priorities
- Scheduling
- GPIO
- Interrupts
- Semaphores / Mutexes

---

## Temperature Monitor
A temperature-monitoring application that periodically reads a temperature sensor and passes the resulting data to another task for processing/display.<br>
The general flow is:
```text
Temperature Sensor
        │
        ▼
  Sensor Task
        │
        │ Allocate / store measurement
        ▼
  Message Queue
        │
        ▼
  Display Task
        │
        ├── Display value via UART
        │
        └── Release buffer
```
The producer task is responsible for obtaining the temperature measurement and placing it into a buffer.<br>
The consumer task receives the buffer, processes/displays the value, and then releases the memory.<br>
This project is intended to demonstrate communication and data ownership between RTOS tasks.

**Concepts:**
- Tasks / Threading
- Periodic Tasks
- Message Queues
- Producer / Consumer
- Dynamic Memory Management

---

### UART LED Controller
A UART-based command interface that allows a user to control an LED from the terminal.<br>
For example:
```text
> led on
LED enabled

> led off
LED disabled

> led blink
LED blinking
```

The goal of this application is to combine a UART command interface with dynamic memory management and inter-task communication.<br>
The general flow is:
```text
UART Input
    │
    ▼
Command Task
    │
    │ Allocate buffer
    ▼
Store command
    │
    ▼
Message Queue
    │
    ▼
Command Processing Task
    │
    ├── Execute command
    │
    └── Release buffer
```
The command task dynamically allocates a buffer for the incoming command, stores the received characters, and passes the buffer to another task through an RTEMS message queue.<br>
The processing task receives the buffer, interprets the command, performs the requested action, and then releases the allocated memory.<br>
This project is intended to eventually grow into a small UART command shell that can be used to interact with other RTEMS applications.<br>

**Concepts:**

- UART
- UART Command Shell
- Tasks / Threading
- Message Queues
- Producer / Consumer
- Dynamic Memory Management
- GPIO

---

### UDP Fixed-Rate Sender
An application that periodically sends network packets from the BBB at a fixed rate.<br>
The initial goal is to have the board send packets over Ethernet to another device at a controlled interval, allowing the network traffic to be observed externally.<br>
For example:
```text
BBB
 │
 │ UDP packet
 │
 ▼
Ethernet
 │
 ▼
Other Device
```
The packet transmission rate will be controlled by an RTEMS periodic task, allowing the project to demonstrate both networking and deterministic task timing.<br>

**Concepts:**
- Periodic Tasks
- Networking
- UDP
- RTEMS timing
