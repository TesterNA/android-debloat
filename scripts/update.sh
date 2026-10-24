#!/usr/bin/env bash
# Bring this repo and every repo it depends on to the newest version. Safe to run any time.
#   bash scripts/update.sh
# Dependencies are cloned next to this repo (in its parent folder). A repo with local changes that
# block a fast-forward is left alone and reported: nothing is ever reset, stashed or overwritten.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PARENT="$(dirname "$ROOT")"

# name|url — keep in sync with scripts/update.ps1 and the SOURCES.md files.
DEPS="cleanyourtv|https://github.com/Gathin23/cleanyourtv
tv-detox|https://github.com/Ansub/tv-detox
free-my-tv|https://github.com/simbasjungles/free-my-tv"

status=0
pull() {   # pull <dir> <label>
  local dir="$1" label="$2" before after
  before=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if git -C "$dir" pull --ff-only -q 2>/tmp/upd.err; then
    after=$(git -C "$dir" rev-parse --short HEAD)
    [ "$before" = "$after" ] && echo "ok       $label  up to date ($after)" || echo "updated  $label  $before -> $after"
  else
    echo "BLOCKED  $label  $(head -1 /tmp/upd.err)  (local changes or conflict: ask the user, do not reset)"
    status=1
  fi
}

if git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then pull "$ROOT" "android-debloat"; fi

while IFS='|' read -r name url; do
  dir="$PARENT/$name"
  if [ -d "$dir/.git" ]; then pull "$dir" "$name"
  elif [ -e "$dir" ]; then echo "BLOCKED  $name  $dir exists but is not a git clone"
  else git clone -q "$url" "$dir" && echo "cloned   $name  $(git -C "$dir" rev-parse --short HEAD)" || status=1
  fi
done <<< "$DEPS"

# CleanYourTV's ADB client (adb-shell) lives in a venv inside its clone.
CYT="$PARENT/cleanyourtv"
if [ -f "$CYT/tools/requirements.txt" ] && [ ! -d "$CYT/tools/venv" ]; then
  PY=$(command -v python3 || command -v python || true)
  if [ -n "$PY" ]; then
    "$PY" -m venv "$CYT/tools/venv" && { "$CYT/tools/venv/bin/python" -m pip install -q -r "$CYT/tools/requirements.txt" 2>/dev/null \
      || "$CYT/tools/venv/Scripts/python.exe" -m pip install -q -r "$CYT/tools/requirements.txt"; } && echo "venv     cleanyourtv/tools/venv created"
  else echo "NOTE     python not found: CleanYourTV's venv was not created"; fi
fi

# UAD-ng package database for phones (refresh if missing or older than 30 days).
UAD="$ROOT/phone/uad/uad_lists.json"
if [ ! -f "$UAD" ] || [ -n "$(find "$UAD" -mtime +30 2>/dev/null)" ]; then
  bash "$ROOT/phone/scripts/update-uad.sh" && echo "updated  UAD-ng database"
else echo "ok       UAD-ng database ($(cat "$ROOT/phone/uad/updated.txt" 2>/dev/null))"; fi
exit $status
