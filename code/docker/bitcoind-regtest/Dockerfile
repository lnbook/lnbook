FROM bitcoind_base:latest

ADD bitcoind /bitcoind
WORKDIR /bitcoind

EXPOSE 12001

RUN ln -sf /dev/stdout /bitcoind/debug.log

CMD ["bitcoind", "-datadir=/bitcoind"]
