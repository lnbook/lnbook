FROM golang:1.13

ENV GOPATH /go
WORKDIR $GOPATH/src

RUN apt update && apt install -y \
	jq

# LND
RUN go get -d github.com/lightningnetwork/lnd
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd
RUN make && make install
