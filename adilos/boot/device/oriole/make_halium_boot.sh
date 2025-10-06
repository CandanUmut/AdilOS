#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(realpath "$(dirname "$0")")
ROOT=$(realpath "$SCRIPT_DIR/../../..")
INITRAMFS=${INITRAMFS:-$ROOT/boot/out/initramfs.cpio.gz}
KERNEL_IMAGE=${KERNEL_IMAGE:-$SCRIPT_DIR/Image}
DTB_IMAGE=${DTB_IMAGE:-$SCRIPT_DIR/dtb.img}
DTBO_IMAGE=${DTBO_IMAGE:-$SCRIPT_DIR/dtbo.img}
MKBOOTIMG=${MKBOOTIMG:-mkbootimg}
ARGS_FILE=${ARGS_FILE:-$SCRIPT_DIR/mkbootimg.args.example}
OUT=${HALIUM_BOOT_OUT:-$ROOT/out/boot/halium-boot.img}

if [ ! -f "$INITRAMFS" ]; then
  echo "Initramfs missing at $INITRAMFS. Run boot/halium-initramfs/mkinitramfs.sh" >&2
  exit 1
fi

for f in "$KERNEL_IMAGE" "$DTB_IMAGE" "$DTBO_IMAGE"; do
  if [ ! -f "$f" ]; then
    echo "Placeholder missing: $f" >&2
    echo "Copy the device-specific artifact to that path before building." >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$OUT")"

readarray -t EXTRA_ARGS < "$ARGS_FILE"

$MKBOOTIMG \
  --kernel "$KERNEL_IMAGE" \
  --ramdisk "$INITRAMFS" \
  --dtb "$DTB_IMAGE" \
  --dtbo "$DTBO_IMAGE" \
  "${EXTRA_ARGS[@]}" \
  -o "$OUT"

echo "Created halium-boot image at $OUT"
