#!/bin/bash
set -Eeuo pipefail

echo Starting bitcoind...
bitcoind -datadir=/bitcoind -daemon
until bitcoin-cli -datadir=/bitcoind -rpcwait getblockchaininfo  > /dev/null 2>&1
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
# If restarting the wallet already exists, so don't fail if it does,
# just load the existing wallet:
bitcoin-cli -datadir=/bitcoind createwallet regtest || bitcoin-cli -datadir=/bitcoind loadwallet regtest
bitcoin-cli -datadir=/bitcoind importprivkey $privkey || true

# Executing CMD
echo "$@"
exec "$@"
