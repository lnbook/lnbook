FROM lnbook/bitcoind AS c-lightning-base

# Install software-properties-common to add apt repositories
RUN apt update && apt install -yqq \
	software-properties-common

# c-lightning
ENV C_LIGHTNING_VER 0.9.2~0~ubuntu18.04.1
RUN add-apt-repository -u ppa:lightningnetwork/ppa
RUN apt-get install -yqq \
	lightningd=${C_LIGHTNING_VER}

ADD https://raw.githubusercontent.com/ElementsProject/lightning/master/contrib/lightning-cli.bash-completion /usr/share/bash-completion/completions/lightning-cli

FROM c-lightning-base AS c-lightning-run

ADD lightningd /lightningd
WORKDIR /lightningd
RUN ln -s /lightningd /root/.lightning

ADD bashrc /root/.bashrc
ADD c-lightning-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/c-lightning-entrypoint.sh
ADD fund-c-lightning.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-c-lightning.sh
ADD logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh
ADD wait-for-bitcoind.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wait-for-bitcoind.sh

EXPOSE 9735 9835
ENTRYPOINT ["/usr/local/bin/c-lightning-entrypoint.sh"]

# Show logs from beginning and keep following
CMD ["/usr/local/bin/logtail.sh"]
