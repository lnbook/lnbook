#!/bin/bash

bitcoind -datadir=/bitcoind -daemon
sleep 5
export address=`cat /bitcoind/keys/demo_address.txt`
export privkey=`cat /bitcoind/keys/demo_privkey.txt`
echo "================================================"
echo "Importing demo private key"
echo "Bitcoin address: " ${address}
echo "Private key: " ${privkey}
echo "================================================"
bitcoin-cli -datadir=/bitcoind importprivkey $privkey
