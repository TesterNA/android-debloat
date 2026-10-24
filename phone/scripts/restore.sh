#!/usr/bin/env bash
# Undo disable.sh: re-enable every package in TIER sections of a debloat list.
# Packages removed with `pm uninstall -k --user 0` are not covered: bring those back with
#   cmd package install-existing <pkg>   (the list's comments name them).
# Usage: PHONE=<ip:port> bash scripts/restore.sh <device-dir>/debloat.txt
set -euo pipefail
LIST="${1:?usage: PHONE=<ip:port> restore.sh <list>}"
DEV="${PHONE:?set PHONE=<ip:port>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADB="${ADB:-$ROOT/platform-tools/adb.exe}"
[ -x "$ADB" ] || ADB=adb

PKGS=$(awk '
  NR == 1 { sub(/^\357\273\277/, "") }
  /^# ---- TIER/ { tier = 1 }
  /^# ---- / && !/^# ---- TIER/ { tier = 0 }
  { sub(/\r$/, ""); sub(/[ \t]+#.*$/, "") }
  /^[ \t]*(#|$)/ { next }
  tier == 0 { next }
  { print $1 }' "$LIST")
BAD=$(printf '%s\n' "$PKGS" | grep -vE '^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' || true)
[ -z "$BAD" ] || { echo "not a package name: $BAD" >&2; exit 1; }

for p in $PKGS; do
  echo "$p: $("$ADB" -s "$DEV" shell pm enable --user 0 "$p" 2>&1 | head -1 | tr -d '\r')"
done
