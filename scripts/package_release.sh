#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
OUT_DIR="$ROOT_DIR/release"
PKG_NAME="Ubuntu-Starter-Kit-v$VERSION-safe-preview"
PKG_DIR="$OUT_DIR/$PKG_NAME"

bash "$ROOT_DIR/scripts/check_static.sh"
rm -rf "$OUT_DIR"
mkdir -p "$PKG_DIR"
rsync -a \
  --exclude='.git' \
  --exclude='release' \
  --exclude='dist' \
  --exclude='logs' \
  --exclude='*.tmp' \
  --exclude='*.bak' \
  "$ROOT_DIR/" "$PKG_DIR/"

cd "$OUT_DIR"
zip -r "$PKG_NAME.zip" "$PKG_NAME" >/dev/null
sha256sum "$PKG_NAME.zip" > "$PKG_NAME.zip.sha256"
printf 'Release hazır:\n%s\n%s\n' "$OUT_DIR/$PKG_NAME.zip" "$OUT_DIR/$PKG_NAME.zip.sha256"
