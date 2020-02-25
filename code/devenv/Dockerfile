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


# c-lightning
RUN add-apt-repository -u ppa:lightningnetwork/ppa
RUN apt-get install -y \
 	lightningd

# Go 1.13 for LND
RUN curl -SL https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
	| tar -xzC /usr/local
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH /gocode
RUN mkdir -p $GOPATH
ENV PATH $PATH:$GOPATH/bin

# LND
RUN go get -d github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install

# OpenJDK11 for eclair
RUN apt install -y \
	openjdk-11-jdk

# eclair-node
RUN mkdir -p /usr/src/eclair
WORKDIR /usr/src/eclair
RUN curl -SLO https://github.com/ACINQ/eclair/releases/download/v0.3.3/eclair-node-0.3.3-12ac145.jar
