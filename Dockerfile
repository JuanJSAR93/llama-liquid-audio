# =========================
# BUILD STAGE
# =========================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    build-essential \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
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


# =========================
# RUNTIME STAGE
# =========================
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libcurl4 \
    libssl3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar todos los ejecutables y librerías de la carpeta bin/
COPY --from=builder /src/llama.cpp/build/bin/ /usr/local/bin/

ENV LD_LIBRARY_PATH=/usr/local/bin

WORKDIR /models

ENTRYPOINT ["llama-liquid-audio-server"]
