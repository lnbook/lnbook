#!/bin/bash
set -Eeuo pipefail

# Show LND log from beginning and follow
tail -n +1 -f /lightningd/lightningd.log || true
