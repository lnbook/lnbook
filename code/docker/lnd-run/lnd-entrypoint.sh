#!/bin/bash

echo Starting lnd...
lnd --lnddir=/lnd --noseedbackup > /dev/null &
sleep 5
until lncli --lnddir=/lnd -n regtest getinfo > /dev/null 2>&1
do
	sleep 1
done
echo "Startup complete"
echo "Funding lnd wallet"
source /usr/local/bin/fund-lnd.sh

exec "$@"
