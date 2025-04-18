# Base image with all necessary tools
FROM debian:buster-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    build-essential \
    python \
    make \
    pkg-config \
    zlib1g-dev \
    libglib2.0-dev \
    libpixman-1-dev \
    qemu-system-arm \
    qemu-utils \
    gdb-multiarch \
    xterm \
    x11-apps \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /project

# Copy project files into the container
COPY . /project/

# Add convenience script for running QEMU with display
RUN echo '#!/bin/bash\n\
make clean\n\
make all\n\
qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio -display sdl\n\
' > /usr/local/bin/run-qemu && \
    chmod +x /usr/local/bin/run-qemu

# Add GDB debug script
RUN echo '#!/bin/bash\n\
make clean\n\
make all\n\
qemu-system-aarch64 -s -S -M raspi3b -kernel kernel8.img -serial stdio -display sdl\n\
' > /usr/local/bin/debug-qemu && \
    chmod +x /usr/local/bin/debug-qemu

# Set default command
CMD ["/bin/bash"]