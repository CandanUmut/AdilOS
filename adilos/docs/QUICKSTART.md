# AdilOS Quickstart

1. Enable OEM unlocking + USB debugging on device.
2. Unlock bootloader (wipes data):

   ```bash
   adb reboot bootloader
   fastboot flashing unlock
   ```

3. Install host deps:

   ```bash
   sudo apt-get update
   sudo apt-get install -y adb fastboot android-bootimg pmbootstrap python3 python3-pip cmake ninja-build build-essential curl git unzip dos2unix qt6-base-dev qt6-base-dev-tools qt6-webengine-dev || true
   ```

4. Build artifacts:

   ```bash
   make
   ```

5. Flash:

   ```bash
   bash -euxo pipefail scripts/flash_adilos.sh --no-build
   ```

If it fails to flash, the script will try fastbootd and A/B slots. You can also pass `--temp-boot` for a non-persistent test.
