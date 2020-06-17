FROM ubuntu:18.04 AS eclair-base

RUN apt update && apt install -yqq \
	curl gosu jq bash-completion

RUN apt update && apt install -yqq \
	openjdk-11-jdk unzip

# Install eclair
ENV ECLAIR_VER 0.4
ENV ECLAIR_COMMIT 69c538e
WORKDIR /usr/src
RUN curl -sLO https://github.com/ACINQ/eclair/releases/download/v${ECLAIR_VER}/eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip \
	&& unzip eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip \
	&& install eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}/bin/eclair-cli /usr/local/bin

ADD https://raw.githubusercontent.com/ACINQ/eclair/master/contrib/eclair-cli.bash-completion /usr/share/bash-completion/completions/eclair-cli

ADD eclair /eclair
WORKDIR /eclair
RUN ln -s /eclair /root/.eclair

ADD bashrc /root/.bashrc
ADD eclair-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/eclair-entrypoint.sh
ADD logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh

EXPOSE 9735
ENTRYPOINT ["/usr/local/bin/eclair-entrypoint.sh"]
