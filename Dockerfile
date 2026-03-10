# Use a lightweight base image with development tools
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/rtems/7/bin:$PATH"
ENV RTEMS_VERSION="7"
ENV RTEMS_PREFIX="/opt/rtems/7"
ENV RTEMS_KERNEL_PATH="/opt/rtems-kernel"

# Update package list and install dependencies
RUN apt-get update -y && \
    apt-get install -y \
    build-essential \
    git \
    bison \
    flex \
    sudo \
    python3 \
    python3-pip \
    python3-setuptools \
    wget \
    texinfo \
    libncurses5-dev \
    libncursesw5-dev \
    zlib1g-dev \
    unzip \
    gdb \
    cmake \
    vim \
    && apt-get clean

# Install RTEMS Source Builder (RSB) dependencies
RUN apt-get install -y \
    u-boot-tools \
    python \
    python3-dev \
    python3-venv \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    && apt-get clean

# Clone the RTEMS Source Builder (RSB) & RTEMS
# The commit ID's are based off working versions of main, and non of the tag releases seem to work properly for me
RUN cd /opt && \
    git clone https://gitlab.rtems.org/rtems/tools/rtems-source-builder.git  && \
    git clone https://gitlab.rtems.org/rtems/rtos/rtems.git rtems-kernel && \
    cd rtems-source-builder && \
    git checkout 71faa243ebf4ccf737bf83699f694f39f3b92fef && \
    cd ../rtems-kernel && \
    git checkout 120bc92b0417cab11424e348ff9dc2a3aa870836

# The next 2 RUN commands setup the rtems env, and are split for better debugging
WORKDIR /opt/rtems-source-builder/rtems
RUN ../source-builder/sb-get-sources
RUN ../source-builder/sb-set-builder --prefix=$RTEMS_PREFIX ./config/7/rtems-arm --with-rtems-tests=yes --with-rtems-smp

# Set default dir to RTEMS_KERNEL_PATH to run the rest of this container in
WORKDIR $RTEMS_KERNEL_PATH

# Create the config file
COPY ./include/config.ini $RTEMS_KERNEL_PATH

# Configure the waf project
RUN ./waf configure --prefix=$RTEMS_PREFIX 
RUN ./waf build
RUN ./waf install
