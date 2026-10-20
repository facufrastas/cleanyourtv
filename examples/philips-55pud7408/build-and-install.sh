#!/usr/bin/env bash
# Rebuild the launcher from launcher/app/src/main/res/values/config.xml and install it on the
# Philips 55PUD7408/77. HOME_KEY_SERVICE=1 keeps the remote's Settings button (scancode 357) working;
# Android switches the service off on every reinstall, so it is passed each time.
#
# Usage: TV_HOST=192.168.1.84 examples/philips-55pud7408/build-and-install.sh
set -euo pipefail
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.84 $0}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# launcherx is already disabled here, so the script has no stock launcher to find; tell it so.
STOCK_LAUNCHER="${STOCK_LAUNCHER:-none}" HOME_KEY_SERVICE=1 TV_HOST="$TV_HOST" "$ROOT/launcher/build-and-install.sh"
