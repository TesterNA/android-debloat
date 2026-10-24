#!/usr/bin/env bash
# Refresh the UAD-ng package database (descriptions + removal levels for ~5000 packages).
# Usage: bash scripts/update-uad.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL=https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json
TMP="$ROOT/uad/uad_lists.json.new"
curl -fsSL -o "$TMP" "$URL"
"$(command -v python3 || command -v python)" -I -c "import json,sys; d=json.load(open(sys.argv[1],encoding='utf-8')); print(len(d),'packages')" "$TMP"
mv "$TMP" "$ROOT/uad/uad_lists.json"
date +%F > "$ROOT/uad/updated.txt"
