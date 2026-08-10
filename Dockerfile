FROM debian:12

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/rtems/6/bin:$PATH"
ENV RTEMS_VERSION="6"
ENV RTEMS_PREFIX="/opt/rtems/6"
ENV RTEMS_KERNEL_PATH="/opt/rtems/rtems-kernel"

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
    zlib1g-dev \
    unzip \
    gdb \
    cmake \
    vim \
    pax \
    python3-dev \
    python-is-python3 \
    libncurses-dev \
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
    xz-utils \
    bzip2 \
    ca-certificates \
    libgmp-dev libmpfr-dev libmpc-dev libisl-dev \
    device-tree-compiler \
    minicom \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create User
RUN useradd -m -u 1000 -s /bin/bash builder && \
    passwd -d builder && \
    usermod -aG sudo builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder && \
    touch /home/builder/.sudo_as_admin_successful

RUN mkdir /opt/rtems

COPY ./rtems/rtems-kernel /opt/rtems/rtems-kernel
COPY ./rtems/rtems-source-builder /opt/rtems/rtems-source-builder
COPY ./rtems/rtems-tools /opt/rtems/rtems-tools

RUN chown -R builder:builder /opt/rtems/

USER builder
WORKDIR /home/builder

# The next 2 commands setup the rtems env, and are split for better debugging
WORKDIR /opt/rtems/rtems-source-builder/rtems
RUN /opt/rtems/rtems-source-builder/source-builder/sb-get-sources
RUN /opt/rtems/rtems-source-builder/source-builder/sb-set-builder --prefix=$RTEMS_PREFIX ./config/6/rtems-arm --with-rtems-tests=yes --with-rtems-smp

# Create the config file
COPY ./include/config.ini $RTEMS_KERNEL_PATH

# Build RTEMS test
WORKDIR /opt/rtems/rtems-tools
RUN ./waf configure --prefix=$RTEMS_PREFIX
RUN ./waf build
RUN ./waf install

# Build the kernel
WORKDIR $RTEMS_KERNEL_PATH
# Configure the waf project
RUN ./waf configure --prefix=$RTEMS_PREFIX
RUN ./waf build
RUN ./waf install
