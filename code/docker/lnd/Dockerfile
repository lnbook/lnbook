ARG OS=ubuntu
ARG OS_VER=focal
ARG GO_VER=1.19.5
# Define base images with ARG versions
FROM ${OS}:${OS_VER} as os
FROM golang:${GO_VER} as go

# OS image with command-line utilities
FROM os AS os-base

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && apt-get install -yqq \
    curl unzip jq bash-completion

# Go image for building LND
FROM go as lnd-build

ENV GO_VER=${GO_VER}
ENV GOPATH=/go

# Build LND
ARG LND_VER=v0.15.5-beta
ENV LND_VER=${LND_VER}
RUN mkdir -p ${GOPATH}/src
RUN git clone https://github.com/lightningnetwork/lnd.git ${GOPATH}/src/github.com/lightningnetwork/lnd
WORKDIR  ${GOPATH}/src/github.com/lightningnetwork/lnd
RUN git checkout tags/${LND_VER}
RUN make clean
RUN make
RUN make install

# Runtime image for running LND
FROM os-base as lnd-run

# Copy only the executables
COPY --from=lnd-build /go/bin /go/bin

ADD https://raw.githubusercontent.com/lightningnetwork/lnd/master/contrib/lncli.bash-completion \
    /usr/share/bash-completion/completions/lncli

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin

COPY lnd /lnd
RUN ln -s /lnd /root/.lnd
COPY fund-lnd.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-lnd.sh
COPY bashrc /root/.bashrc
COPY lnd-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/lnd-entrypoint.sh
COPY logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh
COPY wait-for-bitcoind.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wait-for-bitcoind.sh
COPY cli /usr/local/bin
RUN chmod +x /usr/local/bin/cli

# LND RPC
EXPOSE 10009/tcp

# LND P2P
EXPOSE 9735/tcp

WORKDIR /lnd
ENTRYPOINT ["/usr/local/bin/lnd-entrypoint.sh"]

# Show logs from beginning and keep following
CMD ["/usr/local/bin/logtail.sh"]
