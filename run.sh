#!/bin/bash
ERR="\e[31m"
EC="\e[0m"
IMAGE_NAME="rtems7-devel"
# Build image if it does not exist
if ! sudo docker images | grep $IMAGE_NAME; then

    # Check if we have enough space to build the container
    THRESHOLD=20

    # Get the available disk space
    AVAILABLE_SPACE=$(df --output=avail / | tail -n 1 | awk '{print $1 / 1024 / 1024}')

    # Round it to the nearest integer so we can compare to the threshold
    AVAILABLE_SPACE=$(printf "%.0f" "$AVAILABLE_SPACE")

    # Check if the available space is greater than the threshold
    if [ "$AVAILABLE_SPACE" -lt "$THRESHOLD" ]; then
        echo -e "${ERR}ERROR: Not enough space to build container${EC}"
        echo "Required: $THRESHOLD GB"
        echo "Available: $AVAILABLE_SPACE GB"
        exit 1
    fi
    
    sudo docker build --tag $IMAGE_NAME .
    # We attach ttyUSB for RS-232 access or Xilinx POD 
    # privileged & security-opt allow for access to the serial port
    # allow port 69 for tftp server
    # Volume to make meta-gcia a shared directory
    sudo docker run --privileged --security-opt seccomp=unconfined --volume ./share:/opt/share -it ${IMAGE_NAME} /bin/bash
elif [[ -z $(sudo docker ps -a --filter "ancestor=${IMAGE_NAME}" -q) ]]; then
    sudo docker run --privileged --security-opt seccomp=unconfined --volume ./share:/opt/share -it ${IMAGE_NAME} /bin/bash
else
    CONTAINER_ID=$(sudo docker ps -a --filter "ancestor=${IMAGE_NAME}" -q)
    docker start $CONTAINER_ID
    docker attach $CONTAINER_ID
fi
