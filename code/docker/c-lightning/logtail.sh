#!/bin/bash
set -Eeuo pipefail

# Show LND log from beginning and follow
touch /lightningd/lightningd.log
tail -n +1 -f /lightningd/lightningd.log || true
