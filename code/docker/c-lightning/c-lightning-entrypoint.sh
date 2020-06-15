#!/bin/bash
set -Eeuo pipefail

lightningd --lightning-dir=/lightningd --daemon

echo "$@"
exec "$@"
