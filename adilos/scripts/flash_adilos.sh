#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "${REPO_ROOT}/Makefile" || ! -d "${REPO_ROOT}/boot" ]]; then
  echo "[!] Please run this script from within the adilos repository root." >&2
  exit 1
fi

HALIUM_INITRAMFS_SCRIPT="${REPO_ROOT}/boot/halium-initramfs/mkinitramfs.sh"
ROOTFS_IMG="${REPO_ROOT}/out/rootfs/adilos-rootfs.img"
HALIUM_BOOT_IMG="${REPO_ROOT}/out/boot/halium-boot.img"
ADILFLasher="${REPO_ROOT}/tools/adilflasher/adilflasher.py"

APT_PACKAGES=(
  android-sdk-platform-tools
  python3
  python3-pip
  cmake
  ninja-build
  build-essential
  qtbase6-dev
  qt6-base-dev-tools
  curl
  git
  unzip
)

ensure_dependencies() {
  echo "[+] Ensuring required host packages are installed..."
  if command -v fastboot >/dev/null && command -v adb >/dev/null; then
    echo "    - fastboot/adb already present"
  fi

  if command -v apt-get >/dev/null; then
    echo "[+] Detected apt-based distribution; installing packages (may prompt for sudo password)."
    sudo apt-get update
    sudo apt-get install -y "${APT_PACKAGES[@]}"
  else
    cat <<'MSG'
[!] Non apt-based distribution detected.
    Please install the following packages manually before rerunning this script:
      - fastboot / adb (Android platform tools)
      - python3, python3-pip, cmake, ninja, build-essential (gcc/g++)
      - Qt6 base development headers/tools
      - curl, git, unzip
MSG
  fi

  if ! command -v pmbootstrap >/dev/null; then
    echo "[+] Installing pmbootstrap for the current user via pip..."
    python3 -m pip install --user --upgrade pmbootstrap
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
}

build_artifacts() {
  echo "[+] Building Halium initramfs..."
  bash "${HALIUM_INITRAMFS_SCRIPT}"

  echo "[+] Building AdilOS root filesystem (this may take a while)..."
  make -C "${REPO_ROOT}" rootfs

  echo "[+] Building halium-boot image..."
  make -C "${REPO_ROOT}" halium-boot
}

flash_boot_image() {
  if [[ ! -f "${HALIUM_BOOT_IMG}" ]]; then
    echo "[!] Boot image not found at ${HALIUM_BOOT_IMG}." >&2
    exit 1
  fi

  echo "[+] Waiting for device in fastboot mode..."
  until fastboot devices | grep -q '\sfastboot$'; do
    echo "    - Connect the Pixel 6 in fastboot mode (power + volume down)"
    sleep 3
  done

  echo "[+] Flashing halium-boot image..."
  fastboot flash boot "${HALIUM_BOOT_IMG}"

  echo "[+] Rebooting device..."
  fastboot reboot
}

push_rootfs() {
  if [[ ! -f "${ROOTFS_IMG}" ]]; then
    echo "[!] Rootfs image not found at ${ROOTFS_IMG}." >&2
    exit 1
  fi

  echo "[+] Waiting for device to boot (ADB)..."
  adb wait-for-device

  echo "[+] Preparing /data/adilos on device..."
  adb shell 'mkdir -p /data/adilos && chmod 700 /data/adilos'

  echo "[+] Pushing rootfs image to device (this may take a while)..."
  adb push "${ROOTFS_IMG}" /data/adilos/adilos-rootfs.img

  echo "[+] Rebooting into AdilOS..."
  adb reboot
}

run_tail_helper() {
  if [[ -f "${ADILFLasher}" ]]; then
    read -rp "[?] Launch adilflasher log tail helper after reboot? [y/N] " answer
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
      echo "[+] Starting adilflasher log tail (Ctrl+C to stop)..."
      python3 "${ADILFLasher}"
    fi
  fi
}

main() {
  ensure_dependencies
  build_artifacts

  echo "[+] Ensure the device bootloader is unlocked and the device is in fastboot mode."
  read -rp "    Press Enter when ready to flash..." _
  flash_boot_image
  push_rootfs
  run_tail_helper

  echo "[+] Flashing complete. The device should finish booting into AdilOS shortly."
}

main "$@"
