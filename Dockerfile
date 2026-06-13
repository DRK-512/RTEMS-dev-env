# Use a lightweight base image with development tools
FROM ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/builder/rtems/6/bin:$PATH"
ENV RTEMS_VERSION="6"
ENV RTEMS_PREFIX="/home/builder/rtems/6"
ENV RTEMS_KERNEL_PATH="/home/builder/rtems-kernel"

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
    build-essential \
    g++ \
    gdb \
    unzip \
    pax \
    bison \
    flex \
    texinfo \
    python3-dev \
    python-is-python3 \
    libncurses-dev \
    zlib1g-dev \
    ninja-build \
    pkg-config \
    qemu-system-arm \
    gdb-multiarch \
    cppcheck \
    valgrind \
    lcov \
    gcovr \
    clang-format \
    clang-tidy \
    doxygen \
    graphviz \
    u-boot-tools \
    python3-venv \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create User
RUN useradd -m -u 1000 -s /bin/bash builder && \
    passwd -d builder && \
    usermod -aG sudo builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder && \
    touch /home/builder/.sudo_as_admin_successful

USER builder
WORKDIR /home/builder
# Clone the RTEMS Source Builder (RSB) & RTEMS
# The commit ID's are based off working versions of main, and non of the tag releases seem to work properly for me
RUN git clone https://gitlab.rtems.org/rtems/tools/rtems-source-builder.git  && \
    git clone https://gitlab.rtems.org/rtems/rtos/rtems.git rtems-kernel && \
    git clone https://gitlab.rtems.org/rtems/tools/rtems-tools.git rtems-tools && \
    cd rtems-source-builder && \
    git checkout base/6 && \
    cd ../rtems-tools && \
    git checkout base/6 && \
    cd ../rtems-kernel && \
    git checkout base/6

# The next 2 RUN commands setup the rtems env, and are split for better debugging
WORKDIR /home/builder/rtems-source-builder/rtems
RUN ../source-builder/sb-get-sources
RUN ../source-builder/sb-set-builder --prefix=$RTEMS_PREFIX ./config/6/rtems-arm --with-rtems-tests=yes --with-rtems-smp

# Set default dir to RTEMS_KERNEL_PATH to run the rest of this container in
WORKDIR $RTEMS_KERNEL_PATH

# Create the config file
COPY ./include/config.ini $RTEMS_KERNEL_PATH

# Configure the waf project
RUN ./waf configure --prefix=$RTEMS_PREFIX
RUN ./waf build
RUN ./waf install
