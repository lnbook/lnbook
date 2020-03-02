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

# Install additional Bitcoin Core (bitcoind) requirements
RUN apt-get install -y \
	libssl-dev \
	libevent-dev \
	bsdmainutils \
	libboost-system-dev \
	libboost-filesystem-dev \
	libboost-chrono-dev \
	libboost-test-dev \
	libboost-thread-dev \
	libminiupnpc-dev \
	libzmq3-dev

# Install software-properties-common to add apt repositories
RUN apt-get install -y \
	software-properties-common

# Add Bitcoin Core PPA repository
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update && apt-get install -y \
	bitcoind
