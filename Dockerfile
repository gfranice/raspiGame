FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    ARMGNU=aarch64-linux-gnu \
    BIN_DIR=/project/binaries \
    DISPLAY=host.docker.internal:0.0

RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    build-essential \
    python3 \
    make \
    pkg-config \
    zlib1g-dev \
    libglib2.0-dev \
    libpixman-1-dev \
    qemu-system-arm \
    qemu-utils \
    qemu-system-gui \
    git \
    gdb-multiarch \
    xterm \
    x11-apps \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /project

VOLUME ["/qemu-sockets"]

COPY . /project

CMD ["/bin/bash"]