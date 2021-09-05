FROM lnbook/bitcoind AS c-lightning-base

# Install software-properties-common to add apt repositories
RUN apt-get update -qq && apt-get install -yqq \
	wget gpg xz-utils libpq5 libsodium23

# c-lightning
ENV C_LIGHTNING_VER 0.10.1

RUN cd /tmp && \
    wget -q https://github.com/ElementsProject/lightning/releases/download/v${C_LIGHTNING_VER}/clightning-v${C_LIGHTNING_VER}-Ubuntu-20.04.tar.xz

# Verify developer signatures. The `gpg --verify` command will print a
# couple of warnings about the key not being trusted. That's ok. The
# important part is that it doesn't error and reports "Good
# signature".
ADD devkeys.pem /tmp/devkeys.pem
RUN gpg --import /tmp/devkeys.pem
ADD https://github.com/ElementsProject/lightning/releases/download/v0.10.1/SHA256SUMS /tmp/SHA256SUMS
ADD https://github.com/ElementsProject/lightning/releases/download/v0.10.1/SHA256SUMS.asc /tmp/SHA256SUMS.asc
RUN cd /tmp && \
    gpg -q --verify SHA256SUMS.asc SHA256SUMS && \
    cat SHA256SUMS && \
    sha256sum --ignore-missing -c SHA256SUMS

RUN tar -xvf /tmp/clightning-v${C_LIGHTNING_VER}-Ubuntu-20.04.tar.xz -C /

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
