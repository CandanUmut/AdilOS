#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:-}
MOUNT_POINT=${2:-}

if [[ -z "$IMAGE" || -z "$MOUNT_POINT" ]]; then
  echo "Usage: $0 <image> <mount_point>" >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required to attach loop devices" >&2
  exit 1
fi

sudo mkdir -p "$MOUNT_POINT"
LOOP=$(sudo losetup -f --show "$IMAGE")
trap 'sudo umount "$MOUNT_POINT" || true; sudo losetup -d "$LOOP"' EXIT
sudo mount "$LOOP" "$MOUNT_POINT"
echo "Mounted $IMAGE on $MOUNT_POINT via $LOOP"
read -rp "Press enter to unmount..."
