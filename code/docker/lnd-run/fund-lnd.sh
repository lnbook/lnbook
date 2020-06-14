#!/bin/bash

# Generate a new receiving address for LND wallet
address=$(lncli --lnddir=/lnd --network regtest newaddress np2wkh | jq .address)

# Ask Bitcoin Core to send 10 BTC to the address, using JSON-RPC call
curl --user regtest:regtest \
     -H 'content-type: text/plain;' \
	 http://bitcoind:18443/ \
	 --data-binary @- <<EOF
	{
	  "jsonrpc": "1.0",
	  "id": "lnd-run-container",
	  "method": "sendtoaddress",
	  "params": [
	    ${address},
	    10,
	    "funding LND"
	  ]
	}
EOF
