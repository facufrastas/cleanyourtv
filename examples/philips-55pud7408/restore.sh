#!/usr/bin/env bash
# Undo everything done to the Philips 55PUD7408/77: re-enable every package in debloat.txt (from the
# record saved before the first change), give Home back to the stock Google TV launcher, and reset
# Private DNS and Location. Needs ADB on (Developer options > USB debugging).
#
# Usage: TV_HOST=192.168.1.84 examples/philips-55pud7408/restore.sh
set -euo pipefail
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.84 $0}"
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../.." && pwd)"
PY="$ROOT/tools/venv/bin/python"

"$ROOT/tools/restore.sh" "$DIR/debloat.txt" com.google.android.apps.tv.launcherx

# Settings changed outside the list. Before: Private DNS unset (automatic), Location off.
printf '%s\n' \
  "settings put global private_dns_mode opportunistic" \
  "settings delete global private_dns_specifier" \
  "cmd location set-location-enabled false" \
  "settings delete secure enabled_accessibility_services" \
  | "$PY" -I "$ROOT/tools/tv.py" --batch

echo "Done. Projectivy's own accessibility service is not switched back on: open Projectivy once and"
echo "it asks for it. To remove the new launcher too: tools/tv.py 'pm uninstall com.gathin.tvhome'"
