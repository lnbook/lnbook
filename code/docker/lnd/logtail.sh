#!/bin/bash
set -Eeuo pipefail

# Show LND log from beginning and follow
tail -n +1 -f /lnd/logs/bitcoin/regtest/lnd.log || true

# When tail is interrupted, shutdown LND
lncli --lnddir=/lnd --network regtest stop
