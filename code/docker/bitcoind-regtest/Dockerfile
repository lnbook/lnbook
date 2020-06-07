FROM lnbook/bitcoind_base:latest

ADD bitcoind /bitcoind
WORKDIR /bitcoind
RUN ln -s /bitcoind /root/.bitcoin

EXPOSE 12001

CMD bitcoind -datadir=/bitcoind -daemon \
	&& sleep 2 \
	&& export address=$(bitcoin-cli -datadir=/bitcoind getnewaddress) \
	&& export privkey=$(bitcoin-cli -datadir=/bitcoind dumpprivkey $address)\
	&& echo "Mining 101 blocks to unlock some bitcoin" \
	&& bitcoin-cli -datadir=/bitcoind generatetoaddress 101 $address \
	&& echo "================================================"\
	&& echo "Mining to bitcoin address: " ${address} \
	&& echo "Private key: " ${privkey} \
	&& echo "Balance: " `bitcoin-cli -datadir=/bitcoind getbalance` \
	&& echo "================================================"\
	&& echo "Configuration:" \
	&& cat /bitcoind/bitcoin.conf \
	&& echo "================================================"\
	&& echo "Use the command below to mine new blocks and progress the chain:"\
	&& echo "bitcoin-cli -datadir=/bitcoind generatetoaddress 1" $address \
	&& echo "================================================"\
	&& bash
