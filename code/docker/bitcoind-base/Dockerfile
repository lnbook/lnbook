FROM ubuntu:18.04

ENV BITCOIND_VERSION 0.20.0


# # Install development tools prerequisites
# RUN apt-get update && apt-get install -y \
#     build-essential \
# 	libtool \
# 	autotools-dev \
# 	automake \
# 	pkg-config \
# 	python3 \
# 	wget \
# 	git \
# 	curl \
# 	unzip

# # Install additional Bitcoin Core (bitcoind) requirements
# RUN apt-get install -y \
# 	libssl-dev \
# 	libevent-dev \
# 	bsdmainutils \
# 	libboost-system-dev \
# 	libboost-filesystem-dev \
# 	libboost-chrono-dev \
# 	libboost-test-dev \
# 	libboost-thread-dev \
# 	libminiupnpc-dev \
# 	libzmq3-dev

# # Install software-properties-common to add apt repositories
# RUN apt-get install -y \
# 	software-properties-common
#
# # Add Bitcoin Core PPA repository
# RUN add-apt-repository ppa:bitcoin/bitcoin
# RUN apt-get update && apt-get install -y \
# 	bitcoind


# Install binaries for Bitcoin Core
ADD https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION}/bitcoin-${BITCOIND_VERSION}-x86_64-linux-gnu.tar.gz /usr/local
RUN cd /usr/local/ \
	&& tar -zxf bitcoin-${BITCOIND_VERSION}-x86_64-linux-gnu.tar.gz \
	&& cd bitcoin-${BITCOIND_VERSION} \
	&& install bin/* /usr/local/bin \
	&& install include/* /usr/local/include \
	&& install -v lib/* /usr/local/lib 

# Confirm installation
RUN bitcoind -version
