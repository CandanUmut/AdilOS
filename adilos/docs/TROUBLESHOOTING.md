# Troubleshooting AdilOS Ignition

## Boot loops or black screen

- **Check userdata mount:** Drop into the initramfs shell by holding volume up during boot. Run `ls /dev/block/by-name` to confirm `userdata` exists. Mount manually with `mount -t ext4 /dev/block/by-name/userdata /data`.
- **Missing rootfs image:** Ensure `/data/adilos/adilos-rootfs.img` exists. Use `adb push` from recovery or re-run `make flash`.
- **switch_root failure:** Inspect `/dev/kmsg` logs. Confirm the initramfs `losetup` succeeded and the rootfs image contains `/sbin/init`.

## initramfs shell access

- Connect via USB, run `adb shell` once the fallback BusyBox shell is active.
- Logs are streamed to `/dev/kmsg`; use `dmesg` for review.

## Waydroid not starting

- Verify binderfs is mounted: `mount | grep binder`. If missing, run `/usr/bin/enable_waydroid.sh` manually.
- Confirm `waydroid-container.service` is enabled (`systemctl status waydroid-container.service`).

## Network issues

- Use `nmcli device status` to confirm the Wi-Fi device is managed.
- Delete stale connections with `nmcli connection delete <name>` and retry.

## AI services

- Services log to `journalctl -u adilai-llm.service` etc.
- Populate `/data/adilos/models` with the required model files and adjust service configuration accordingly.

## Child Mode

- Toggle via `systemctl start childmode.service` to enable the DNS filter. Ensure `dnscrypt-proxy` is installed.
- To disable, run `systemctl stop childmode.service` and remove `/etc/adilos/childmode.enabled`.

## Updating the rootfs overlay

- Edit files under `rootfs/pmos/overlay/` and rebuild the image with `make rootfs`.
- Use `scripts/loop_image.sh` to mount the generated image locally for inspection.
