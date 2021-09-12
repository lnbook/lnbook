ARG OS=ubuntu
ARG OS_VER=focal
FROM ${OS}:${OS_VER} as os-base

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -yqq \
		curl unzip jq bash-completion

# Install default Java Runtime Environment
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -yqq \
	  default-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install eclair
WORKDIR /usr/src

ARG ECLAIR_VER=0.4.2
ARG ECLAIR_COMMIT=52444b0
RUN cd /usr/src && \
	curl -# -sLO https://github.com/ACINQ/eclair/releases/download/v${ECLAIR_VER}/eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip && \
	unzip eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip && \
	install eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}/bin/eclair-cli /usr/local/bin && \
	rm eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip

ADD https://raw.githubusercontent.com/ACINQ/eclair/master/contrib/eclair-cli.bash-completion /usr/share/bash-completion/completions/eclair-cli

ADD eclair /eclair
WORKDIR /eclair
RUN ln -s /eclair /root/.eclair

ADD bashrc /root/.bashrc
ADD eclair-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/eclair-entrypoint.sh
ADD logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh
ADD wait-for-bitcoind.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wait-for-bitcoind.sh
COPY cli /usr/local/bin
RUN chmod +x /usr/local/bin/cli

ENV ECLAIR_VER=$ECLAIR_VER
ENV ECLAIR_COMMIT=$ECLAIR_COMMIT

EXPOSE 9735
ENTRYPOINT ["/usr/local/bin/eclair-entrypoint.sh"]

# Show logs from beginning and keep following
CMD ["/usr/local/bin/logtail.sh"]
