#!/bin/bash
set -Eeuo pipefail

echo Starting eclair...
cd /usr/src/eclair-node-${ECLAIR_VER}-${ECLAIR_COMMIT}/
/bin/bash bin/eclair-node.sh -Declair.datadir="/eclair" &
cd /eclair

until eclair-cli -p eclair getinfo  > /dev/null 2>&1
do
	sleep 1
done

echo Eclair node started

# Executing CMD
echo "$@"
exec "$@"
