# syntax = docker/dockerfile:1.0-experimental
# devenv Dockerfile (multi-state container)
FROM ubuntu:18.04

# Import Bitcoin Core files from bitcoind-base container
COPY --from=lnbook/bitcoind-base /usr/local/ /usr/local/

# Import lnd from lnd-base container
FROM golang:1.13
ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
COPY --from=lnbook/lnd-base $GOPATH $GOPATH

# Install software-properties-common to add apt repositories
RUN apt-get update && apt-get install -y \
	software-properties-common \
	apt-utils \
	curl \
	git

# c-lightning
RUN add-apt-repository -u ppa:lightningnetwork/ppa
RUN apt-get update && apt-get install -y \
 	lightningd

# OpenJDK11 for eclair
RUN apt-get update && apt install -y \
	openjdk-11-jdk

# eclair-node
RUN mkdir -p /usr/src/eclair
WORKDIR /usr/src/eclair
RUN curl -SLO https://github.com/ACINQ/eclair/releases/download/v0.3.3/eclair-node-0.3.3-12ac145.jar

RUN mkdir -p /lnbook
WORKDIR /lnbook
VOLUME /lnbook
