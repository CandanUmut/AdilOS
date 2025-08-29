# Build Guide (barbet)

## Prereqs
- Linux/macOS host; adb/fastboot; Docker/Podman (optional); pmbootstrap; mkbootimg

## Rootfs
```
pip3 install --user pmbootstrap
pmbootstrap init    # edge; choose Plasma Mobile or Phosh
pmbootstrap install
# save as rootfs/out/adilos-rootfs.img
```

## halium-boot
- Kernel + dtb/dtbo for barbet → `kernel/barbet/`
- Initramfs `halium/initramfs/init` mounts `/data/adilos/adilos-rootfs.img` and `switch_root`
- Pack with mkbootimg → `halium/out/halium-boot.img`

## Flash
```
adb reboot bootloader
fastboot flash boot halium/out/halium-boot.img
fastboot reboot
sleep 15
adb shell 'mkdir -p /data/adilos && chmod 700 /data/adilos'
adb push rootfs/out/adilos-rootfs.img /data/adilos/adilos-rootfs.img
adb reboot
```
