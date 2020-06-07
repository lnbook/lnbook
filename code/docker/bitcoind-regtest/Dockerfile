FROM lnbook/bitcoind_base:latest

ADD bitcoind /bitcoind
WORKDIR /bitcoind

EXPOSE 12001


CMD bitcoind -datadir=/bitcoind -daemon \
	&& sleep 2 \
	&& address=$(bitcoin-cli -datadir=/bitcoind getnewaddress) \
	&& privkey=$(bitcoin-cli -datadir=/bitcoind dumpprivkey $address)\
	&& echo "================================================"\
	&& echo "Mining to bitcoin address: " ${address} \
	&& echo "Private key: " ${privkey} \
	&& echo "Configuration:" \
	&& cat /bitcoind/bitcoin.conf \
	&& echo "================================================"\
	&& echo "Mining 101 blocks to unlock some bitcoin" \
	&& bitcoin-cli -datadir=/bitcoind generatetoaddress 101 $address \
	&& echo "Mining 1 block every 10 seconds"\
	&& while sleep 10 \
	; do bitcoin-cli -datadir=/bitcoind generatetoaddress 1 $address \
	; done
