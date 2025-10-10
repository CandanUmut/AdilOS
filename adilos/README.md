# AdilOS — Bootstrap Repo (Universal Build + Flash)

This repo builds a Halium-style initramfs + halium-boot.img and a minimal ext4 rootfs so you can boot AdilOS to a shell on real Android hardware. It also includes a universal flasher that works across A/B and fastbootd devices.

## Pre-flight (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install -y \
  adb fastboot android-bootimg pmbootstrap python3 python3-pip cmake ninja-build build-essential \
  curl git unzip dos2unix \
  qt6-base-dev qt6-base-dev-tools qt6-webengine-dev || true

# If pmbootstrap unavailable/too old:
mkdir -p "$HOME/src" && cd "$HOME/src"
git clone --depth=1 https://gitlab.postmarketos.org/postmarketOS/pmbootstrap.git
mkdir -p "$HOME/.local/bin"
ln -snf "$HOME/src/pmbootstrap/pmbootstrap.py" "$HOME/.local/bin/pmbootstrap"
export PATH="$HOME/.local/bin:$PATH"
pmbootstrap --version

# Optional udev rule (no sudo for adb/fastboot)
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | \
  sudo tee /etc/udev/rules.d/51-android.rules >/dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Build

```bash
make
# outputs:
#  out/boot/initramfs.cpio.gz
#  out/rootfs/adilos-rootfs.img
#  out/boot/halium-boot.img
```

### Building halium-boot.img with a stock boot

Place a stock boot.img and repack with our initramfs automatically via:

```bash
HALIUM_STOCK_BOOT=/path/to/stock_boot.img bash boot/device/or_any/make_halium_boot.sh \
  --initramfs out/boot/initramfs.cpio.gz \
  --out out/boot/halium-boot.img \
  --stock-boot "$HALIUM_STOCK_BOOT"
```

## Flash (universal)

```bash
chmod +x scripts/flash_adilos.sh

# Full pipeline (build → push → flash):
bash -euxo pipefail scripts/flash_adilos.sh

# If images already built:
bash -euxo pipefail scripts/flash_adilos.sh --no-build

# Temporary boot (won’t persist):
bash -euxo pipefail scripts/flash_adilos.sh --no-build --temp-boot

# Partition/slot overrides:
bash -euxo pipefail scripts/flash_adilos.sh --partition=init_boot --slot=a
```

## Notes
- This rootfs is a stub for smoke tests; it boots and drops to a shell. Swap it with a real postmarketOS/Alpine userspace next.
- PEP 668: do not install Python tools globally with pip. Use apt or git link for pmbootstrap.
- Makefile uses LF endings and requires TABs for recipes.
