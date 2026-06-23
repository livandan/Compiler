FROM gcc:15

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libboost-regex-dev \
        cmake \
    && rm -rf /var/lib/apt/lists/*
