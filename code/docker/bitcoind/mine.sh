#!/bin/bash
set -Eeuo pipefail

export address=`cat /bitcoind/keys/demo_address.txt`
echo "================================================"
echo "Balance:" `bitcoin-cli -datadir=/bitcoind getbalance`
echo "================================================"
echo "Mining 101 blocks to unlock some bitcoin"
bitcoin-cli -datadir=/bitcoind generatetoaddress 101 $address
echo "Mining 6 blocks every 10 seconds"
while echo "Balance:" `bitcoin-cli -datadir=/bitcoind getbalance`;
do
	bitcoin-cli -datadir=/bitcoind generatetoaddress 6 $address; \
	sleep 10; \

done

# If loop is interrupted, stop bitcoind
bitcoin-cli -datadir=/bitcoind stop
