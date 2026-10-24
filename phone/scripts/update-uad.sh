#!/usr/bin/env bash
# Refresh the UAD-ng package database (descriptions + removal levels for ~5000 packages).
# Usage: bash scripts/update-uad.sh        (PYTHON=<python> to choose the interpreter)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL=https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json
mkdir -p "$ROOT/uad"
TMP="$ROOT/uad/uad_lists.json.new"
trap 'rm -f "$TMP"' EXIT
curl -fsSL -o "$TMP" "$URL"
# A Python 3 that really runs (on Windows "python3" can be a Microsoft Store stub).
PY="${PYTHON:-}"
if [ -z "$PY" ]; then
  for c in python3 python py; do
    if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys; sys.exit(sys.version_info[0] != 3)' >/dev/null 2>&1; then PY=$c; break; fi
  done
fi
if [ -n "$PY" ]; then
  "$PY" -I -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8')); print(len(d),'packages')" "$TMP"
else
  grep -q '"id"' "$TMP" || { echo "downloaded file does not look like uad_lists.json" >&2; exit 1; }
fi
mv "$TMP" "$ROOT/uad/uad_lists.json"
date +%F > "$ROOT/uad/updated.txt"
