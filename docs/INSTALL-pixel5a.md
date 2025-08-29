# Install — Pixel 5a (barbet)

> Unlocking bootloader wipes data. Proceed at your own risk.

1. Enable OEM Unlock + USB Debugging
2. `adb reboot bootloader`
3. `fastboot flashing unlock` (confirm on device)
4. Flash `halium-boot.img`
5. Boot once, create `/data/adilos`, push `adilos-rootfs.img`, reboot
6. First boot may take several minutes; be patient
