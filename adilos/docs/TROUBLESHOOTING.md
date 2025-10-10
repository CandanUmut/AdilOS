# Troubleshooting

- **Makefile: `*** missing separator`** → tabs/CRLF issue. Run:

  ```bash
  bash tools/fix_line_endings.sh
  ```

- **`mkbootimg`/`unpackbootimg` missing** → `sudo apt-get install -y android-bootimg`.
- **pmbootstrap “externally managed environment”** → never pip install. Use apt or git link per README.
- **Initramfs can’t find userdata** → device path differs; adjust `/dev/block/...` probe in `boot/halium-initramfs/init`.
- **Stuck in initramfs shell (“Missing rootfs image”)** → ensure `/data/adilos/adilos-rootfs.img` was pushed (flasher does this; or `adb push` manually).
