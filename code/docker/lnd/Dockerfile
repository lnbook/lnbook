FROM golang:1.13 as lnd-base

ENV GOPATH /go
WORKDIR $GOPATH/src

# LND
RUN go get -d github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install

FROM ubuntu:18.04 AS lnd-run

RUN apt update && apt install -yqq \
	curl gosu jq bash-completion

COPY --from=lnd-base /go /go
RUN cp /go/src/github.com/lightningnetwork/lnd/contrib/lncli.bash-completion \
	   /usr/share/bash-completion/completions/lncli

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin

ADD lnd /lnd
RUN ln -s /lnd /root/.lnd
ADD fund-lnd.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-lnd.sh
ADD bashrc /root/.bashrc
ADD lnd-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/lnd-entrypoint.sh
ADD logtail.sh /usr/local/bin
RUN chmod +x /usr/local/bin/logtail.sh

# LND RPC
EXPOSE 10009/tcp

# LND P2P
EXPOSE 9735/tcp

WORKDIR /lnd
ENTRYPOINT ["/usr/local/bin/lnd-entrypoint.sh"]

# Show lnd logs from beginning and keep following
CMD ["/usr/local/bin/logtail.sh"]
