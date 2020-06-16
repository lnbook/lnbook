#!/bin/bash
set -Eeuo pipefail

lightningd --lightning-dir=/lightningd --daemon

until lightning-cli --lightning-dir=/lightningd --network regtest getinfo > /dev/null 2>&1
do
	sleep 1
done
echo "Startup complete"
sleep 2
echo "Funding c-lightning wallet"
source /usr/local/bin/fund-c-lightning.sh

echo "$@"
exec "$@"
