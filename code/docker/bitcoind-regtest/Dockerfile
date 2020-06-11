FROM lnbook/bitcoind-base:latest

ADD bitcoind /bitcoind
RUN ln -s /bitcoind /root/.bitcoin

# bitcoind P2P
EXPOSE 18444/tcp
# bitcoind regtest RPC
EXPOSE 18443/tcp
# zmqpubrawblock
EXPOSE 12005/tcp
# zmqpubrawtx
EXPOSE 12006/tcp

WORKDIR /bitcoind
CMD /bin/bash /bitcoind/bitcoind-start.sh \
	&& /bin/bash /bitcoind/mine.sh
