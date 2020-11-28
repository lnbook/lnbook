#!/bin/bash
set -Eeuo pipefail

# Show LND log from beginning and follow
touch /eclair/eclair.log
tail -n +1 -f /eclair/eclair.log || true
