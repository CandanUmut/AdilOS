#!/usr/bin/env bash
set -euo pipefail
OUT_IMG="${1:?Usage: build_rootfs.sh /path/to/adilos-rootfs.img}"

SIZE_MB="${ADILOS_ROOTFS_SIZE_MB:-2048}"
TMPDIR="$(mktemp -d)"
cleanup(){ sudo umount "$TMPDIR" 2>/dev/null || true; rmdir "$TMPDIR" 2>/dev/null || true; }
trap cleanup EXIT

echo "[i] Creating ext4 rootfs image (${SIZE_MB}MB) at $OUT_IMG"
mkdir -p "$(dirname "$OUT_IMG")"
dd if=/dev/zero of="$OUT_IMG" bs=1M count="$SIZE_MB" status=none
mkfs.ext4 -F "$OUT_IMG" >/dev/null
sudo mount -o loop "$OUT_IMG" "$TMPDIR"

sudo mkdir -p "$TMPDIR"/{proc,sys,dev,run,bin,sbin,etc,usr/bin,usr/sbin,root,var,tmp,home}
sudo chmod 1777 "$TMPDIR/tmp"

cat <<'INIT' | sudo tee "$TMPDIR/sbin/init" >/dev/null
#!/bin/sh
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev 2>/dev/null || true
echo "AdilOS demo rootfs: dropping to shell. Replace with real userspace."
exec /bin/sh
INIT
sudo chmod +x "$TMPDIR/sbin/init"

if command -v busybox >/dev/null 2>&1; then
  sudo cp "$(command -v busybox)" "$TMPDIR/bin/busybox" || true
  printf '%s\n' '#!/bin/sh' 'exec /bin/busybox sh "$@"' | sudo tee "$TMPDIR/bin/sh" >/dev/null
  sudo chmod +x "$TMPDIR/bin/sh"
fi

sudo umount "$TMPDIR"
sync
echo "[+] Rootfs demo image created: $OUT_IMG"
