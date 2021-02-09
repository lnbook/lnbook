#!/bin/bash

# Generate a new receiving address for LND wallet
address=$(lightning-cli --lightning-dir=/lightningd newaddr | jq .address)

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
	    "funding c-lightning",
	    "true"
	  ]
	}
EOF
