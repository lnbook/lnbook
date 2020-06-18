#!/bin/bash
set -Eeuo pipefail

echo Waiting for bitcoind to start...
until bitcoin-cli -rpcconnect=bitcoind -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest getblockchaininfo  > /dev/null 2>&1
do
	echo -n "."
	sleep 1
done

echo Waiting for bitcoind to mine blocks...
until bitcoin-cli -rpcconnect=bitcoind -rpcport=18443 -rpcuser=regtest -rpcpassword=regtest getbalance  | jq -e ". > 0" > /dev/null 2>&1
do
	echo -n "."
	sleep 1
done
