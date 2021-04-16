#!/bin/bash
set -Eeuo pipefail

echo Starting bitcoind...
bitcoind -datadir=/bitcoind -daemon
until bitcoin-cli -datadir=/bitcoind getblockchaininfo  > /dev/null 2>&1
do
	sleep 1
done
echo bitcoind started
export address=`cat /bitcoind/keys/demo_address.txt`
export privkey=`cat /bitcoind/keys/demo_privkey.txt`
echo "================================================"
echo "Importing demo private key"
echo "Bitcoin address: " ${address}
echo "Private key: " ${privkey}
echo "================================================"

if [ ! -d "/bitcoind/regtest/wallets/regtest" ] 
then
	bitcoin-cli -datadir=/bitcoind createwallet regtest
else
	bitcoin-cli -datadir=/bitcoind loadwallet regtest
fi

bitcoin-cli -datadir=/bitcoind importprivkey $privkey

# Executing CMD
echo "$@"
exec "$@"
