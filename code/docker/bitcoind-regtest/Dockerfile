FROM ubuntu:18.04 AS bitcoind-base

RUN apt update && apt install -yqq \
	curl gosu jq bash-completion

ENV BITCOIND_VERSION 0.20.0
# Install binaries for Bitcoin Core
ADD https://bitcoincore.org/bin/bitcoin-core-${BITCOIND_VERSION}/bitcoin-${BITCOIND_VERSION}-x86_64-linux-gnu.tar.gz /usr/local
RUN cd /usr/local/ \
	&& tar -zxf bitcoin-${BITCOIND_VERSION}-x86_64-linux-gnu.tar.gz \
	&& cd bitcoin-${BITCOIND_VERSION} \
	&& install bin/* /usr/local/bin \
	&& install include/* /usr/local/include \
	&& install -v lib/* /usr/local/lib

ENV GH_URL https://raw.githubusercontent.com/bitcoin/bitcoin/master/
ENV BC /usr/share/bash-completion/completions/
ADD $GH_URL/contrib/bitcoin-cli.bash-completion $BC/bitcoin-cli
ADD $GH_URL/contrib/bitcoind.bash-completion $BC/bitcoind
ADD $GH_URL/contrib/bitcoin-tx.bash-completion $BC/bitcoin-tx

FROM bitcoind-base AS bitcoind-regtest

ADD bitcoind /bitcoind
RUN ln -s /bitcoind /root/.

ADD bashrc /root/.bashrc
ADD bitcoind-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/bitcoind-entrypoint.sh
ADD mine.sh /usr/local/bin
RUN chmod +x /usr/local/bin/mine.sh

# bitcoind P2P
EXPOSE 18444/tcp
# bitcoind regtest RPC
EXPOSE 18443/tcp
# zmqpubrawblock
EXPOSE 12005/tcp
# zmqpubrawtx
EXPOSE 12006/tcp

WORKDIR /bitcoind
ENTRYPOINT ["/usr/local/bin/bitcoind-entrypoint.sh"]

# Mine new block every 10 seconds
CMD ["/usr/local/bin/mine.sh"]
