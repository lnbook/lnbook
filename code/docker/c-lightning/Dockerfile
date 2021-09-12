ARG OS=ubuntu
ARG OS_VER=focal
FROM ${OS}:${OS_VER} as os-base

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -yqq \
		curl unzip jq bash-completion

FROM os-base as cl-install
COPY --from=lnbook/bitcoind:latest /usr/bin/bitcoin-cli /usr/bin

# Set CL_VER ENV from ARG
ARG CL_VER=0.10.1
ENV CL_VER=${CL_VER}

RUN apt-get update -qq && apt-get install -yqq \
		gpg xz-utils libpq5 libsodium23 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -# -sLO https://github.com/ElementsProject/lightning/releases/download/v${CL_VER}/clightning-v${CL_VER}-Ubuntu-20.04.tar.xz

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

RUN tar -xvf /tmp/clightning-v${CL_VER}-Ubuntu-20.04.tar.xz -C /

ADD https://raw.githubusercontent.com/ElementsProject/lightning/master/contrib/lightning-cli.bash-completion /usr/share/bash-completion/completions/lightning-cli

COPY lightningd /lightningd
WORKDIR /lightningd
RUN ln -s /lightningd /root/.lightning

COPY bashrc /root/.bashrc
COPY c-lightning-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/c-lightning-entrypoint.sh
COPY fund-c-lightning.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-c-lightning.sh
COPY logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh
COPY wait-for-bitcoind.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wait-for-bitcoind.sh
COPY cli /usr/local/bin
RUN chmod +x /usr/local/bin/cli


EXPOSE 9735 9835
ENTRYPOINT ["/usr/local/bin/c-lightning-entrypoint.sh"]

# Show logs from beginning and keep following
CMD ["/usr/local/bin/logtail.sh"]
