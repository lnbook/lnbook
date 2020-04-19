FROM bitcoind_base:latest

ADD bitcoind /bitcoind
WORKDIR /bitcoind
RUN ln -sf /dev/stdout /bitcoind/debug.log

EXPOSE 12001


CMD bitcoind -datadir=/bitcoind -daemon \
	&& sleep 2 \
	&& address=$(bitcoin-cli -datadir=/bitcoind getnewaddress) \
	&& bitcoin-cli -datadir=/bitcoind generatetoaddress 101 $address \
	&& while sleep 10 \
	; do bitcoin-cli -datadir=/bitcoind generatetoaddress 1 $address \
	; done
