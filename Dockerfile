FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar el código fuente local con los cambios de --sleep-idle-seconds
COPY . /src/llama.cpp

WORKDIR /src/llama.cpp

RUN cmake -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release

RUN cmake --build build \
    --target llama-liquid-audio-server llama-liquid-audio-cli llama-bench \
    -j$(nproc)

ENTRYPOINT ["/src/llama.cpp/build/bin/llama-liquid-audio-server"]
