FROM ubuntu:18.04 AS bitcoind-base

ENV BITCOIND_VERSION 0.20.0

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
