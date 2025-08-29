#!/usr/bin/env bash
set -euo pipefail
BOOT="$(dirname "$0")/../halium/out/halium-boot.img"
ROOTFS="$(dirname "$0")/../rootfs/out/adilos-rootfs.img"

echo "[*] Rebooting to bootloader..."
adb reboot bootloader

echo "[*] Flashing boot image..."
fastboot flash boot "$BOOT"

echo "[*] Rebooting to userspace for rootfs push..."
fastboot reboot
sleep 15

echo "[*] Seeding rootfs to /data/adilos/"
adb shell 'mkdir -p /data/adilos && chmod 700 /data/adilos'
adb push "$ROOTFS" /data/adilos/adilos-rootfs.img

echo "[*] Rebooting..."
adb reboot
