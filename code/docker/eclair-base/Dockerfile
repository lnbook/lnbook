FROM ubuntu:18.04

# Install development tools prerequisites
RUN apt-get update && apt-get install -y \
    build-essential \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	python3 \
	wget \
	git \
	curl \
	unzip

# OpenJDK11 for eclair
RUN apt install -y \
	openjdk-11-jdk

# eclair-node
RUN mkdir -p /usr/src/eclair
WORKDIR /usr/src/eclair
RUN curl -SLO https://github.com/ACINQ/eclair/releases/download/v0.3.3/eclair-node-0.3.3-12ac145.jar
