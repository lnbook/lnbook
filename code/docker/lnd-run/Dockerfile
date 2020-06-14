FROM golang:1.13 as lnd-base

ENV GOPATH /go
WORKDIR $GOPATH/src

RUN apt update && apt install -y \
	jq

# LND
RUN go get -d github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install

FROM lnd-base AS lnd-run

ADD lnd /lnd
RUN ln -s /lnd /root/.lnd
ADD fund-lnd.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-lnd.sh
ADD bashrc /root/.bashrc
ADD lnd-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/lnd-entrypoint.sh

WORKDIR /lnd
ENTRYPOINT ["/usr/local/bin/lnd-entrypoint.sh"]

# Show lnd logs from beginning and keep following
CMD ["tail", "-n", "+1", "-f", "/lnd/logs/bitcoin/regtest/lnd.log"]
