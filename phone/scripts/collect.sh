#!/usr/bin/env bash
# Read-only snapshot of a phone: packages, settings, memory, battery. Changes nothing on the device.
# Usage: bash scripts/collect.sh <ip:port> <device-dir>
#   e.g. bash scripts/collect.sh 192.168.1.50:40731 devices/google-pixel3-blueline
# Writes <device-dir>/backup-YYYYmmdd-HHMM/ and prints its path on the last line.
set -euo pipefail
DEV="${1:?usage: collect.sh <ip:port> <device-dir>}"
DIR="${2:?usage: collect.sh <ip:port> <device-dir>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADB="${ADB:-$ROOT/platform-tools/adb.exe}"
[ -x "$ADB" ] || ADB=adb
export MSYS_NO_PATHCONV=1   # Git Bash would rewrite /data and /proc into Windows paths
A() { "$ADB" -s "$DEV" shell "$@"; }

"$ADB" connect "$DEV" >/dev/null 2>&1 || true
A true >/dev/null 2>&1 || { echo "phone $DEV not reachable: check Wireless debugging and the port (adb mdns services)" >&2; exit 1; }

OUT="$DIR/backup-$(date +%Y%m%d-%H%M)"
mkdir -p "$OUT"

A getprop                         > "$OUT/getprop.txt"
A uptime                          > "$OUT/uptime.txt"
A pm list packages -f -U          > "$OUT/packages-all.txt"
A pm list packages -s             > "$OUT/packages-system.txt"
A pm list packages -3             > "$OUT/packages-user.txt"
A pm list packages -d             > "$OUT/packages-disabled.txt"
A pm list packages -u             > "$OUT/packages-incl-uninstalled.txt"
A pm list packages -i -3          > "$OUT/packages-user-installer.txt"
for ns in global secure system; do A settings list $ns > "$OUT/settings-$ns.txt"; done
A cat /proc/meminfo               > "$OUT/meminfo.txt"
A dumpsys meminfo                 > "$OUT/dumpsys-meminfo.txt"
A dumpsys batterystats            > "$OUT/batterystats.txt"
A dumpsys battery                 > "$OUT/battery.txt"
A df -h /data                     > "$OUT/df.txt" 2>&1 || true
A dumpsys device_policy           > "$OUT/device-policy.txt" 2>&1 || true

# Install time of every user app: one round trip, the loop runs on the phone.
A 'for p in $(pm list packages -3 | cut -d: -f2); do echo "$p $(dumpsys package $p | grep -m1 firstInstallTime | tr -d " ")"; done' \
  > "$OUT/user-install-times.txt"

echo "$OUT"
