# RTEMS Environment
This environment is used for RTEMs development<br>
It specifically is geared towards the BeagelBoneBlack board<br>
It pulls the repositories needed for RTEMs version 6 and sets up the environment for you to cross-compile for the device<br>
The goal is that as a software developer, all I care about is my apps, so I don't have to learn BSP deployment and what not<br>

# Directories
## Project Structure
```text
rtems-dev-env/
├── app/                   # Application source code
│   ├── helloWorld/        # This application will show display hello world via two different threads
│   ├── trafficController/ # This application simulates a safety interlock switch system with two doors (as servos) and 2 switches
│   ├── tempMonitor/       # This application simulates a real time traffic controller AKA a traffic light
│   ├── UARTLEDController/ # This application takes UART inputs and allows you to control an LED
│   └── UDPFixedSender     # Sends UDP packets at a fixed rate
├── docs/                  # Project documentation
├── include/               # Static assets
├── rtems/                 # Development/build scripts
└── README.md              # Project documentation
```

### Directory Overview

| Directory         | Description                                                   |
| ----------------- | ------------------------------------------------------------- |
| `src/`            | Contains the main application source code.                    |
| `src/components/` | Reusable components shared across the application.            |
| `src/pages/`      | Contains the application's pages or routes.                   |
| `src/services/`   | Handles API requests and integrations with external services. |
| `src/utils/`      | Shared helper functions and utilities.                        |
| `tests/`          | Contains unit, integration, and/or end-to-end tests.          |
| `docs/`           | Additional documentation and project guides.                  |
| `public/`         | Static files that are served directly to users.               |
| `scripts/`        | Utility scripts used for development, testing, or deployment. |
| `config/`         | Project and environment-specific configuration.               |

### Key Files

* `package.json` — Defines project dependencies, scripts, and package metadata.
* `.env.example` — Documents the environment variables required to run the project.
* `README.md` — Provides an overview of the project and instructions for getting started.




The content in the include directory are utilized to build RTEMS along with the docker container<br>
Whereas the share directory is a mounted volume for the container, so you can share files between the host and the container through there<br>
A good place to start with example projects can be found [here](https://gitlab.rtems.org/rtems/rtos/rtems-examples.git)

# Building
./waf configure --prefix=$RTEMS_PREFIX
./waf 

touch uEnv.txt
vim uEnv.txt 

## Generate rtems-app.img
arm-rtems6-objcopy   ./build/arm-rtems6-beagleboneblack/hello.exe   -O binary app.bin
gzip -9 -f app.bin
mkimage   -A arm   -O linux   -T kernel   -a 0x80000000   -e 0x80000000   -n RTEMS   -d app.bin.gz   rtems-app.img

#### am335 is provided by dockerfile in /opt/

SD card 
First 512M: 
rtems-app.img
am335x-boneblack.dtb
uEnv.txt

Rest empty, or ext4, it does not matter we will never use it
