#!/usr/bin/env bash
set -euo pipefail

ROOT=$(realpath "$(dirname "$0")/../..")
WORKDIR=${PMOS_WORKDIR:-$ROOT/.pmbootstrap}
OUT_IMAGE=${ROOTFS_OUT:-$ROOT/out/rootfs/adilos-rootfs.img}
OVERLAY_DIR=$(realpath "$(dirname "$0")/overlay")
PACKAGES_LIST=$(realpath "$(dirname "$0")/packages.list")
PMOS_INIT_CONF=$(realpath "$(dirname "$0")/pmos_init.conf")

if ! command -v pmbootstrap >/dev/null 2>&1; then
  echo "pmbootstrap is required; install from https://wiki.postmarketos.org/" >&2
  exit 1
fi

mkdir -p "$WORKDIR"

pmbootstrap -w "$WORKDIR" init --config "$PMOS_INIT_CONF" --aports-branch edge --force

while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
  pmbootstrap -w "$WORKDIR" pkg install "$pkg"
done < "$PACKAGES_LIST"

pmbootstrap -w "$WORKDIR" install --overlay "$OVERLAY_DIR" --hostname adilos --wipe

IMAGE_SIZE_MB=${ROOTFS_SIZE_MB:-6144}
"$ROOT/scripts/mkrootfs_ext4.sh" "$OUT_IMAGE" "$IMAGE_SIZE_MB"

ROOTFS_MOUNT=$(mktemp -d)
trap 'sudo umount "$ROOTFS_MOUNT" || true; rmdir "$ROOTFS_MOUNT"' EXIT
sudo mount "$OUT_IMAGE" "$ROOTFS_MOUNT"
sudo rsync -a "$WORKDIR/chroot_native/home/pmos/rootfs/" "$ROOTFS_MOUNT/"
sudo umount "$ROOTFS_MOUNT"
rmdir "$ROOTFS_MOUNT"

echo "Rootfs image created at $OUT_IMAGE"
