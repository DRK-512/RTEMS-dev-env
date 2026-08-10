#!/bin/bash
set -euo pipefail  # Exit on error, unset vars, and pipe failures

ERR="\e[31m"
EC="\e[0m"
IMAGE_NAME="rtems6-devel"
# Check if we have enough space to build the container
MIN_DISK_GB=20

[[ ! -d ./apps ]] && echo -e "${ERR}ERROR: Missing ./apps director${EC}" && exit 1

# Build image if it does not exist
if ! docker images -q $IMAGE_NAME; then
        echo "Image '$IMAGE_NAME' not found locally. Checking disk space before build..."

        # Get available disk space in GB (correct calculation)
        AVAILABLE_SPACE_GB=$(df --output=avail / | tail -n 1 | awk '{print $1 / 1024 / 1024}')
        AVAILABLE_SPACE_GB=$(printf "%.0f" "$AVAILABLE_SPACE_GB")

        # Check if the available space is greater than the threshold
        if [ "$AVAILABLE_SPACE_GB" -lt "$MIN_DISK_GB" ]; then
                echo -e "${ERR}ERROR: Not enough space to build container${EC}"
                echo "Required: $THRESHOLD GB"
                echo "Available: $AVAILABLE_SPACE GB"
                exit 1
        fi
    
        docker build --tag $IMAGE_NAME .
        # privileged & security-opt allow for access to the serial port
        # allow port 69 for tftp server
        # Volume to make meta-gcia a shared directory
        docker run \
        --privileged \
        --security-opt \
        seccomp=unconfined \
        --volume ./apps:/home/builder \
        -it ${IMAGE_NAME} /bin/bash
elif [[ -z $(docker ps -a --filter "ancestor=${IMAGE_NAME}" -q) ]]; then
        docker run \
        --privileged \
        --security-opt \
        seccomp=unconfined \
        --volume ./apps:/home/builder \
        -it ${IMAGE_NAME} /bin/bash
else
        CONTAINER_ID=$(docker ps -a --filter "ancestor=${IMAGE_NAME}" -q)
        docker start $CONTAINER_ID
        docker attach $CONTAINER_ID
fi
