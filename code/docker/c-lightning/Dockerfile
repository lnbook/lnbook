FROM lnbook/bitcoind-regtest AS c-lightning-base

# Install software-properties-common to add apt repositories
RUN apt update && apt install -yqq \
	software-properties-common

# c-lightning
RUN add-apt-repository -u ppa:lightningnetwork/ppa
RUN apt-get install -y \
 	lightningd

FROM c-lightning-base AS c-lightning-run

ADD lightningd /lightningd
WORKDIR /lightningd
RUN ln -s /lightningd /root/.lightning

ADD bashrc /root/.bashrc
ADD c-lightning-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/c-lightning-entrypoint.sh
ADD fund-c-lightning.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-c-lightning.sh

EXPOSE 9735 9835
ENTRYPOINT ["/usr/local/bin/c-lightning-entrypoint.sh"]
