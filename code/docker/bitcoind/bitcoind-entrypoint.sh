#!/bin/bash
set -Eeuo pipefail


# Start bitcoind
echo "Starting bitcoind..."
bitcoind -datadir=/bitcoind -daemon

# Wait for bitcoind startup
echo -n "Waiting for bitcoind to start"
until bitcoin-cli -datadir=/bitcoind -rpcwait getblockchaininfo  > /dev/null 2>&1
do
	echo -n "."
	sleep 1
done
echo
echo "bitcoind started"


# Load private key into wallet
export address=`cat /bitcoind/keys/demo_address.txt`
export privkey=`cat /bitcoind/keys/demo_privkey.txt`

# If restarting the wallet already exists, so don't fail if it does,
# just load the existing wallet:
bitcoin-cli -datadir=/bitcoind createwallet regtest > /dev/null || bitcoin-cli -datadir=/bitcoind loadwallet regtest > /dev/null
bitcoin-cli -datadir=/bitcoind importprivkey $privkey > /dev/null || true

echo "================================================"
echo "Imported demo private key"
echo "Bitcoin address: " ${address}
echo "Private key: " ${privkey}
echo "================================================"

# Executing CMD
exec "$@"
