FROM debian:stable-slim

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
    gdb-multiarch \
    xterm \
    x11-apps \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /project

RUN echo '#!/bin/bash\n\
cd /project\n\
make clean\n\
make all\n\
qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio -display sdl\n\
' > /usr/local/bin/run-qemu && \
    chmod +x /usr/local/bin/run-qemu

CMD ["/bin/bash"]