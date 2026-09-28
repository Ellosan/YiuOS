FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        bison \
        build-essential \
        ca-certificates \
        ccache \
        curl \
        flex \
        g++-multilib \
        gcc-multilib \
        git \
        git-lfs \
        gnupg \
        gperf \
        imagemagick \
        lib32ncurses5-dev \
        lib32readline-dev \
        lib32z1-dev \
        liblz4-tool \
        libncurses5-dev \
        libsdl1.2-dev \
        libssl-dev \
        libxml2 \
        libxml2-utils \
        lzop \
        openjdk-8-jdk \
        pngcrush \
        python \
        rsync \
        schedtool \
        squashfs-tools \
        unzip \
        x11proto-core-dev \
        xsltproc \
        zip \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo \
        -o /usr/local/bin/repo \
    && chmod 0755 /usr/local/bin/repo

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV USE_CCACHE=1
