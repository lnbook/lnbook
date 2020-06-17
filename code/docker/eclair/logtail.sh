#!/bin/bash
set -Eeuo pipefail

# Show LND log from beginning and follow
tail -n +1 -f /eclair/eclair.log || true
