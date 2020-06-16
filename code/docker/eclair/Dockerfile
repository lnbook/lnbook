FROM ubuntu:18.04 AS eclair-base

RUN apt update && apt install -yqq \
	curl gosu jq bash-completion

RUN apt update && apt install -yqq \
	openjdk-11-jdk unzip

# Install eclair
ENV ECLAIR_VER 0.4
ENV ECLAIR_COMMIT 69c538e
WORKDIR /usr/src
RUN curl -sLO https://github.com/ACINQ/eclair/releases/download/v${ECLAIR_VER}/eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip
RUN unzip eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}-bin.zip -d eclair

ADD eclair /eclair
WORKDIR /eclair
RUN ln -s /eclair /root/.eclair

ADD bashrc /root/.bashrc
ADD eclair-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/eclair-entrypoint.sh
ADD fund-eclair.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-eclair.sh

EXPOSE 9735
ENTRYPOINT ["/usr/local/bin/eclair-entrypoint.sh"]
