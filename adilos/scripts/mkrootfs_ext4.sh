#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:-}
SIZE_MB=${2:-4096}
LABEL=${3:-adilos-rootfs}

if [[ -z "$IMAGE" ]]; then
  echo "Usage: $0 <image_path> [size_mb] [label]" >&2
  exit 1
fi

mkdir -p "$(dirname "$IMAGE")"
truncate -s 0 "$IMAGE"
truncate -s "${SIZE_MB}M" "$IMAGE"
mkfs.ext4 -F -L "$LABEL" "$IMAGE"
