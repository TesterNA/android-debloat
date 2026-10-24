#!/usr/bin/env bash
# Disable every package in a debloat list for user 0, one pm call per package, and log it.
# Usage: PHONE=<ip:port> bash scripts/disable.sh <device-dir>/debloat.txt [1]
#   With "1" only the "# ---- TIER 1" sections are applied.
# Lines: one package per line, "# comment" allowed. Sections start with "# ---- TIER <n>: ...".
# Wait ~30 s after this finishes before rebooting: Android writes the new state to disk with a delay,
# and an immediate reboot silently brings the last batch back.
set -euo pipefail
LIST="${1:?usage: PHONE=<ip:port> disable.sh <list> [1]}"
ONLY1="${2:-}"
DEV="${PHONE:?set PHONE=<ip:port>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ADB="${ADB:-$ROOT/platform-tools/adb.exe}"
[ -x "$ADB" ] || ADB=adb
LOG="$(dirname "$LIST")/applied.log"

PKGS=$(awk -v only1="$ONLY1" '
  NR == 1 { sub(/^\357\273\277/, "") }
  /^# ---- TIER/ { tier = ($4 == "1:") ? 1 : 2 }
  /^# ---- / && !/^# ---- TIER/ { tier = 0 }
  { sub(/\r$/, ""); sub(/[ \t]+#.*$/, "") }
  /^[ \t]*(#|$)/ { next }
  tier == 0 { next }
  only1 == "1" && tier != 1 { next }
  { print $1 }' "$LIST")
# The names go into a shell command on the phone: refuse anything that is not a bare package name.
BAD=$(printf '%s\n' "$PKGS" | grep -vE '^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' || true)
[ -z "$BAD" ] || { echo "not a package name: $BAD" >&2; exit 1; }
[ -n "$PKGS" ] || { echo "nothing to disable in $LIST" >&2; exit 1; }

for p in $PKGS; do
  out=$("$ADB" -s "$DEV" shell pm disable-user --user 0 "$p" 2>&1 | head -2 | tr -d '\r' | tr '\n' ' ')
  echo "$p: $out"
  echo "$(date +%F' '%T) $p: $out" >> "$LOG"
done
echo "--- disabled on the phone now:"
"$ADB" -s "$DEV" shell pm list packages -d
