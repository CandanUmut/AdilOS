# AdilOS Ignition Quickstart

This guide walks through building the AdilOS MVP artifacts and flashing them to an unlocked Google Pixel 6 (`oriole`).

## Host Requirements

- Linux workstation (Debian/Ubuntu/Arch tested)
- `pmbootstrap` (see [postmarketOS docs](https://wiki.postmarketos.org/wiki/Pmbootstrap))
- `fastboot` and `adb`
- `python3`, `pip`, `cmake`, `ninja`, `gcc`, `qt6` development packages
- Network access to fetch Alpine/APK indexes

```bash
sudo apt install android-sdk-platform-tools python3-pip cmake ninja-build qt6-base-dev qt6-declarative-dev qt6-webengine-dev
pip install --user pmbootstrap
```

## Repository Layout

- `boot/halium-initramfs/`: BusyBox initramfs that mounts the looped rootfs image
- `boot/device/oriole/`: scripts for composing `halium-boot.img`
- `rootfs/pmos/`: wrappers around `pmbootstrap` to build an Alpine/postmarketOS rootfs
- `packages/`: AdilOS UI, browser, store, AI, and helper tools
- `tools/`: flashing utility and model fetch helper

## Build Steps

1. **Create the initramfs**

   ```bash
   cd adilos/boot/halium-initramfs
   ./mkinitramfs.sh
   ```

2. **Build the rootfs image**

   ```bash
   cd adilos
   make rootfs
   ```

   This invokes `pmbootstrap` using the configuration in `rootfs/pmos/pmos_init.conf`, applies the overlay, and exports `out/rootfs/adilos-rootfs.img`.

3. **Assemble `halium-boot.img`**

   Provide device-specific kernel, `dtb`, and `dtbo` artifacts in `boot/device/oriole/`. Then run:

   ```bash
   make halium-boot
   ```

   The output `out/boot/halium-boot.img` uses the initramfs generated above.

## Flashing to Pixel 6

1. Unlock the bootloader if not already unlocked:

   ```bash
   adb reboot bootloader
   fastboot flashing unlock
   ```

2. Flash the boot image and push the rootfs:

   ```bash
   cd adilos
   make flash
   ```

   or manually:

   ```bash
   fastboot flash boot out/boot/halium-boot.img
   fastboot reboot
   adb shell 'mkdir -p /data/adilos && chmod 700 /data/adilos'
   adb push out/rootfs/adilos-rootfs.img /data/adilos/adilos-rootfs.img
   adb reboot
   ```

3. Optional: tail logs during first boot using the flashing helper:

   ```bash
   python3 tools/adilflasher/adilflasher.py
   ```

## First Boot Smoke Tests

After reboot, perform these checks:

1. Screen lights up with Phosh and AdilShell overlays.
2. Touch input works; open the terminal to verify.
3. Connect to Wi-Fi via `nmcli dev wifi connect "SSID" password "PASS"`.
4. Launch **AdilBrowser** and confirm Ecosia search.
5. Open **FairStore** and view the seeded AdilNotes listing.
6. Trigger the AI Palette in AdilShell; if models are downloaded using `tools/fetch_models.sh`, expect a local response.

## Next Steps

- Populate `/data/adilos/models` with GGUF, Whisper, and Piper models.
- Add more Flatpak manifests to `packages/fairstore/manifests/`.
- Extend Waydroid support by fleshing out the helper scripts.
