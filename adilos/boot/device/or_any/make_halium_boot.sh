#!/usr/bin/env bash
set -euo pipefail

INITRAMFS=""
OUT_IMG=""
KERNEL_IMG="${KERNEL_IMG:-}"
STOCK_BOOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --initramfs) INITRAMFS="$2"; shift 2 ;;
    --out) OUT_IMG="$2"; shift 2 ;;
    --stock-boot) STOCK_BOOT="$2"; shift 2 ;;
    *) echo "[!] Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$INITRAMFS" || -z "$OUT_IMG" ]]; then
  echo "Usage: $0 --initramfs path.cpio.gz --out halium-boot.img [--stock-boot stock_boot.img]" >&2
  exit 1
fi

if [[ ! -f "$INITRAMFS" ]]; then
  echo "[!] Missing initramfs: $INITRAMFS" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_IMG")"

command -v mkbootimg >/dev/null 2>&1 || { echo "[!] mkbootimg not found (install android-bootimg)" >&2; exit 1; }
if [[ -n "$STOCK_BOOT" ]]; then
  command -v unpackbootimg >/dev/null 2>&1 || { echo "[!] unpackbootimg not found (install android-bootimg)" >&2; exit 1; }
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BASE_ARGS=()
CMDLINE=""
PAGESIZE=""
BOARD=""
HEADERV=""

if [[ -n "$STOCK_BOOT" ]]; then
  if [[ ! -f "$STOCK_BOOT" ]]; then
    echo "[!] stock boot not found: $STOCK_BOOT" >&2
    exit 1
  fi
  echo "[i] Unpacking stock boot: $STOCK_BOOT"
  unpackbootimg -i "$STOCK_BOOT" -o "$TMP" >/dev/null 2>&1 || true

  if [[ -z "$KERNEL_IMG" ]]; then
    KERNEL_IMG="$(ls "$TMP"/*-kernel 2>/dev/null | head -n1 || true)"
  fi

  [[ -f "$TMP"/*-cmdline ]] && CMDLINE="$(cat "$TMP"/*-cmdline || true)"
  [[ -f "$TMP"/*-pagesize ]] && PAGESIZE="$(cat "$TMP"/*-pagesize || true)"
  [[ -f "$TMP"/*-board ]] && BOARD="$(cat "$TMP"/*-board || true)"
  [[ -f "$TMP"/*-header_version ]] && HEADERV="$(cat "$TMP"/*-header_version || true)"

  [[ -n "$CMDLINE"  ]] && BASE_ARGS+=(--cmdline "$CMDLINE")
  [[ -n "$PAGESIZE" ]] && BASE_ARGS+=(--pagesize "$PAGESIZE")
  [[ -n "$BOARD"    ]] && BASE_ARGS+=(--board "$BOARD")
  [[ -n "$HEADERV"  ]] && BASE_ARGS+=(--header_version "$HEADERV")
fi

if [[ -z "$KERNEL_IMG" || ! -f "$KERNEL_IMG" ]]; then
  echo "[!] Set KERNEL_IMG or pass --stock-boot" >&2
  exit 1
fi

echo "[+] Building halium-boot: $OUT_IMG"
mkbootimg --kernel "$KERNEL_IMG" \
          --ramdisk "$INITRAMFS" \
          "${BASE_ARGS[@]}" \
          --output "$OUT_IMG"

echo "[+] halium-boot ready: $OUT_IMG"
