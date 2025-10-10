#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[!] Error at ${BASH_SOURCE[0]}:${LINENO} (exit $?)" >&2' ERR

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_BOOT="${REPO_ROOT}/out/boot"
OUT_ROOTFS="${REPO_ROOT}/out/rootfs"

HALIUM_INITRAMFS_SCRIPT="${REPO_ROOT}/boot/halium-initramfs/mkinitramfs.sh"
ROOTFS_IMG="${OUT_ROOTFS}/adilos-rootfs.img"
HALIUM_BOOT_IMG="${OUT_BOOT}/halium-boot.img"
ADILFLasher="${REPO_ROOT}/tools/adilflasher/adilflasher.py"

DO_BUILD=1
DO_PUSH=1
DO_FLASH=1
TEMP_BOOT=0
PARTITION="auto"
SLOT="auto"

usage() {
  cat <<'EOF'
Usage: $(basename "$0") [options]
  --no-build           Skip building (images must exist)
  --build-only         Build only (no push/flash)
  --flash-only         Flash only (skip build/push)
  --push-only          Push rootfs only (skip build/flash)
  --temp-boot          Use 'fastboot boot <img>' (no flashing)
  --partition=NAME     boot|init_boot|recovery|auto (default: auto)
  --slot=MODE          auto|a|b|both (default: auto)
  -h, --help           Show help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --no-build) DO_BUILD=0 ;;
    --build-only) DO_BUILD=1; DO_PUSH=0; DO_FLASH=0 ;;
    --flash-only) DO_BUILD=0; DO_PUSH=0; DO_FLASH=1 ;;
    --push-only) DO_BUILD=0; DO_PUSH=1; DO_FLASH=0 ;;
    --temp-boot) TEMP_BOOT=1 ;;
    --partition=*) PARTITION="${arg#*=}" ;;
    --slot=*) SLOT="${arg#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[!] Unknown option: $arg"; usage; exit 2 ;;
  esac
done

ensure_dirs() {
  mkdir -p "${OUT_BOOT}" "${OUT_ROOTFS}"
  mkdir -p "${REPO_ROOT}/boot"
  if [[ ! -L "${REPO_ROOT}/boot/out" ]]; then
    rm -rf "${REPO_ROOT}/boot/out" 2>/dev/null || true
    ln -snf "${OUT_BOOT}" "${REPO_ROOT}/boot/out"
  fi
}

install_host_deps() {
  if command -v apt-get >/dev/null 2>&1; then
    local sudo_cmd=""
    if [[ "${EUID}" -ne 0 ]]; then
      if command -v sudo >/dev/null 2>&1; then
        sudo_cmd="sudo"
      else
        echo "[!] apt-based distribution detected but sudo/root privileges unavailable." >&2
        echo "    Re-run with sudo or install dependencies manually." >&2
        exit 1
      fi
    fi
    ${sudo_cmd} apt-get update
    BASE_PKGS=(adb fastboot android-bootimg python3 python3-pip cmake ninja-build build-essential curl git unzip dos2unix)
    if apt-cache show qt6-base-dev >/dev/null 2>&1; then
      QT_PKGS=(qt6-base-dev qt6-base-dev-tools)
      apt-cache show qt6-webengine-dev >/dev/null 2>&1 && QT_PKGS+=(qt6-webengine-dev)
    else
      QT_PKGS=(qtbase5-dev qtbase5-dev-tools)
      apt-cache show qtwebengine5-dev >/dev/null 2>&1 && QT_PKGS+=(qtwebengine5-dev)
    fi
    ${sudo_cmd} apt-get install -y "${BASE_PKGS[@]}" "${QT_PKGS[@]}" || {
      echo "[!] apt install failed; install deps manually and rerun." >&2; exit 1;
    }
  else
    echo "[i] Non-apt distro: ensure adb, fastboot, android-bootimg, toolchain, Qt, curl, git, unzip."
  fi
}

ensure_pmbootstrap() {
  if command -v pmbootstrap >/dev/null 2>&1; then
    echo "[+] pmbootstrap: $(pmbootstrap --version || true)"; return
  fi
  if command -v apt-get >/dev/null 2>&1; then
    local sudo_cmd=""
    if [[ "${EUID}" -ne 0 ]]; then
      if command -v sudo >/dev/null 2>&1; then
        sudo_cmd="sudo"
      else
        sudo_cmd=""
      fi
    fi
    ${sudo_cmd} apt-get update || true
    ${sudo_cmd} apt-get install -y pmbootstrap python3 git openssl || true
    command -v pmbootstrap >/dev/null 2>&1 && { echo "[+] pmbootstrap installed (apt)"; return; }
  fi
  echo "[i] Installing pmbootstrap from git..."
  mkdir -p "${HOME}/src"
  if [[ ! -d "${HOME}/src/pmbootstrap" ]]; then
    git clone --depth=1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git "${HOME}/src/pmbootstrap"
  fi
  mkdir -p "${HOME}/.local/bin"
  ln -snf "${HOME}/src/pmbootstrap/pmbootstrap.py" "${HOME}/.local/bin/pmbootstrap"
  export PATH="${HOME}/.local/bin:${PATH}"
  command -v pmbootstrap >/dev/null 2>&1 || { echo "[!] pmbootstrap not found on PATH"; exit 1; }
  echo "[+] pmbootstrap installed (git): $(pmbootstrap --version || true)"
}

wait_for_adb() {
  echo "[+] Waiting for ADB device..."
  for _ in {1..30}; do
    if adb get-state >/dev/null 2>&1; then return 0; fi
    sleep 1
  done
  echo "[i] No ADB device detected; will push rootfs after flash if possible."
  return 1
}

wait_for_fastboot() {
  echo "[+] Waiting for fastboot device..."
  for _ in {1..30}; do
    if fastboot devices | grep -qE '\\sfastboot$'; then return 0; fi
    sleep 1
  done
  echo "[!] No device in fastboot. Enter bootloader (Power+VolDown) and retry." >&2
  exit 1
}

get_slot() {
  fastboot getvar current-slot 2>&1 | tr -d '\r' | awk -F ': ' '/current-slot/ {print $2}'
}

reboot_fastbootd() {
  echo "[i] Rebooting into fastbootd..."
  fastboot reboot fastboot || true
  sleep 2
  wait_for_fastboot
}

flash_to_partition() {
  local part="$1" img="$2" target="$part"
  local cur slot="${SLOT}"
  cur="$(get_slot || true)"
  if [[ -n "$cur" ]]; then
    case "$slot" in
      auto) target="${part}_${cur}" ;;
      a|b)  target="${part}_${slot}" ;;
      both)
        echo "[i] Flashing both slots for ${part}..."
        fastboot flash "${part}_a" "${img}" || true
        fastboot flash "${part}_b" "${img}" || true
        return 0
        ;;
      *) target="${part}_${cur}" ;;
    esac
  fi
  echo "[+] fastboot flash ${target} ${img}"
  fastboot flash "${target}" "${img}"
}

push_rootfs_via_adb() {
  [[ -f "${ROOTFS_IMG}" ]] || { echo "[!] Missing ${ROOTFS_IMG}"; exit 1; }
  if wait_for_adb; then
    adb shell 'mkdir -p /data/adilos && chmod 700 /data/adilos' || true
    adb push "${ROOTFS_IMG}" /data/adilos/adilos-rootfs.img
    echo "[+] Rootfs push complete."
    return 0
  fi
  return 1
}

build_artifacts() {
  echo "[+] Building Halium initramfs..."
  bash "${HALIUM_INITRAMFS_SCRIPT}"

  echo "[+] Building AdilOS root filesystem..."
  make -C "${REPO_ROOT}" rootfs

  echo "[+] Building halium-boot image..."
  make -C "${REPO_ROOT}" halium-boot

  [[ -f "${HALIUM_BOOT_IMG}" ]] || { echo "[!] Missing ${HALIUM_BOOT_IMG}"; exit 1; }
  [[ -f "${ROOTFS_IMG}"     ]] || { echo "[!] Missing ${ROOTFS_IMG}"; exit 1; }
}

flash_boot_any() {
  local img="${HALIUM_BOOT_IMG}"
  [[ -f "${img}" ]] || { echo "[!] Missing boot image: ${img}"; exit 1; }

  wait_for_fastboot

  if [[ "${TEMP_BOOT}" -eq 1 ]]; then
    echo "[+] Temporary boot: fastboot boot ${img}"
    fastboot boot "${img}"
    return 0
  fi

  local try_parts=()
  case "${PARTITION}" in
    auto) try_parts=(boot init_boot) ;;
    boot) try_parts=(boot) ;;
    init_boot) try_parts=(init_boot) ;;
    recovery) try_parts=(recovery) ;;
    *) try_parts=(boot init_boot) ;;
  esac

  for p in "${try_parts[@]}"; do
    if flash_to_partition "${p}" "${img}"; then
      echo "[+] Flashed ${p} successfully."
      fastboot reboot
      return 0
    fi
  done

  reboot_fastbootd
  for p in "${try_parts[@]}"; do
    if flash_to_partition "${p}" "${img}"; then
      echo "[+] Flashed ${p} (fastbootd) successfully."
      fastboot reboot
      return 0
    fi
  done

  echo "[!] Could not flash boot/init_boot on this device." >&2
  exit 1
}

run_tail_helper() {
  if [[ -f "${ADILFLasher}" ]]; then
    read -rp "[?] Launch adilflasher log tail helper after reboot? [y/N] " answer
    [[ "${answer}" =~ ^[Yy]$ ]] && python3 "${ADILFLasher}" || true
  fi
}

main() {
  [[ -f "${REPO_ROOT}/Makefile" ]] || { echo "[!] Not in repo root"; exit 1; }

  ensure_dirs
  install_host_deps
  ensure_pmbootstrap

  if [[ "${DO_BUILD}" -eq 1 ]]; then
    build_artifacts
  else
    [[ -f "${HALIUM_BOOT_IMG}" ]] || { echo "[!] Missing ${HALIUM_BOOT_IMG}"; exit 1; }
    [[ -f "${ROOTFS_IMG}"     ]] || { echo "[!] Missing ${ROOTFS_IMG}"; exit 1; }
  fi

  if [[ "${DO_PUSH}" -eq 1 ]]; then
    push_rootfs_via_adb || echo "[i] Will try pushing rootfs after flashing if ADB appears."
  fi

  if [[ "${DO_FLASH}" -eq 1 ]]; then
    if adb get-state >/dev/null 2>&1; then adb reboot bootloader || true; fi
    flash_boot_any
  fi

  if [[ "${DO_PUSH}" -eq 1 ]]; then
    push_rootfs_via_adb || echo "[i] Skipped post-flash rootfs push (no ADB)."
  fi

  run_tail_helper
  echo "[+] All done. If you used --temp-boot, flashing is required for persistence."
}
main "$@"
