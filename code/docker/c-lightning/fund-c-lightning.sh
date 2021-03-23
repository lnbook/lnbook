#!/bin/bash
set -Eeuo pipefail

# Generate a new receiving address for c-lightning wallet
address=$(lightning-cli --lightning-dir=/lightningd --network regtest newaddr | jq .address)

# Ask Bitcoin Core to send 10 BTC to the address, using JSON-RPC call
curl --user regtest:regtest \
     -H 'content-type: text/plain;' \
	 http://bitcoind:18443/ \
	 --data-binary @- <<EOF
	{
	  "jsonrpc": "1.0",
	  "id": "c-lightning-container",
	  "method": "sendtoaddress",
	  "params": [
	    ${address},
	    10,
	    "funding c-lightning"
	  ]
	}
EOF
