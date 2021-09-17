#!/bin/bash
set -Eeuo pipefail

echo Waiting for bitcoind to start...
until curl --silent --user regtest:regtest --data-binary '{"jsonrpc": "1.0", "id": "lnd-node", "method": "getblockchaininfo", "params": []}' -H 'content-type: text/plain;' http://bitcoind:18443/ | jq -e ".result.blocks > 0" > /dev/null 2>&1
do
	echo -n "."
	sleep 1
done

echo Waiting for bitcoind to mine blocks...
until curl --silent --user regtest:regtest --data-binary '{"jsonrpc": "1.0", "id": "lnd-node", "method": "getbalance", "params": ["*", 6]}' -H 'content-type: text/plain;' http://bitcoind:18443/ | jq -e ".result > 0" > /dev/null 2>&1
do
	echo -n "."
	sleep 1
done
