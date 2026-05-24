#!/usr/bin/env bash
set -u
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$ROOT_DIR/logs/ubuntu_starter_logs_$STAMP"
mkdir -p "$OUT"

{
  echo "Ubuntu Starter Kit log package"
  echo "Date: $(date --iso-8601=seconds)"
  echo "Root: $ROOT_DIR"
  echo "Version: $(cat "$ROOT_DIR/VERSION" 2>/dev/null)"
  uname -a
  if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a
  fi
} > "$OUT/environment.txt" 2>&1

bash "$ROOT_DIR/scripts/check_static.sh" > "$OUT/check_static.txt" 2>&1 || true
APP_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/ubuntu-starter-kit"
[[ -f "$APP_DATA_DIR/logs/ubuntu-starter-kit.log" ]] && cp "$APP_DATA_DIR/logs/ubuntu-starter-kit.log" "$OUT/runtime.log"

cd "$ROOT_DIR/logs" || exit 1
zip -r "ubuntu_starter_logs_$STAMP.zip" "ubuntu_starter_logs_$STAMP" >/dev/null
printf 'Hazır: %s\n' "$ROOT_DIR/logs/ubuntu_starter_logs_$STAMP.zip"
