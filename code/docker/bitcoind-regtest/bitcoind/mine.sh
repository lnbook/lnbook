#!/bin/bash

export address=`cat /bitcoind/keys/demo_address.txt`
export privkey=`cat /bitcoind/keys/demo_privkey.txt`
echo "================================================"
echo "Bitcoin address: " ${address}
echo "Private key: " ${privkey}
echo "Balance:" `bitcoin-cli -datadir=/bitcoind getbalance`
echo "================================================"
echo "Mining 101 blocks to unlock some bitcoin"
bitcoin-cli -datadir=/bitcoind generatetoaddress 101 $address
echo "Mining 1 block every 10 seconds"
while sleep 10; do \
	bitcoin-cli -datadir=/bitcoind generatetoaddress 1 $address; \
	echo "Balance:" `bitcoin-cli -datadir=/bitcoind getbalance`; \
done
