FROM ubuntu:18.04

# Install development tools prerequisites
RUN apt-get update && apt-get install -y \
    build-essential \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	python3 \
	wget \
	git \
	curl \
	unzip


# Go 1.13 for LND
RUN curl -SL https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
	| tar -xzC /usr/local
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH /gocode
RUN mkdir -p $GOPATH
ENV PATH $PATH:$GOPATH/bin

# LND
RUN go get -d github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install
