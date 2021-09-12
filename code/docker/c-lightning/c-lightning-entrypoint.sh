#!/bin/bash
set -Eeuo pipefail

source /usr/local/bin/wait-for-bitcoind.sh

echo Starting c-lightning...
lightningd --lightning-dir=/lightningd --daemon

until lightning-cli --lightning-dir=/lightningd getinfo > /dev/null 2>&1
do
	sleep 1
done
echo "Startup complete"
sleep 2
echo "Funding c-lightning wallet"
source /usr/local/bin/fund-c-lightning.sh

exec "$@"
