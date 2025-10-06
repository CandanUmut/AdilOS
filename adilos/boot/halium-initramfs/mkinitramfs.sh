#!/usr/bin/env bash
set -euo pipefail

ROOT=$(realpath "$(dirname "$0")")
OUT=${OUT:-$ROOT/../out/initramfs.cpio.gz}
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR"/{bin,sbin,dev,proc,sys,run,etc}
cp "$ROOT/init" "$WORKDIR/"
cp "$ROOT/init.functions" "$WORKDIR/"
chmod +x "$WORKDIR/init"

if command -v busybox >/dev/null 2>&1; then
  cp "$(command -v busybox)" "$WORKDIR/bin/busybox"
else
  echo "Using prebuilt busybox is not supported yet." >&2
  exit 1
fi

( cd "$WORKDIR" && find . | cpio -H newc -o ) | gzip -c > "$OUT"
echo "Created initramfs at $OUT"
