#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
OUT_DIR="${REPO_ROOT}/out/boot"
OUT="${OUT_DIR}/initramfs.cpio.gz"

mkdir -p "${OUT_DIR}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

mkdir -p "${WORKDIR}"/{bin,sbin,etc,proc,sys,dev,newroot,data}
cp "${SCRIPT_DIR}/init" "${WORKDIR}/init"
chmod +x "${WORKDIR}/init"

# BusyBox (optional, improves shell)
if command -v busybox >/dev/null 2>&1; then
  cp "$(command -v busybox)" "${WORKDIR}/bin/busybox"
  cat > "${WORKDIR}/bin/sh" <<'SH'
#!/bin/sh
exec /bin/busybox sh "$@"
SH
  chmod +x "${WORKDIR}/bin/sh"
fi

# Create the archive
( cd "${WORKDIR}" && find . -print0 | cpio --null -ov --format=newc | gzip -9 ) > "${OUT}"

echo "Created initramfs at ${OUT}"
