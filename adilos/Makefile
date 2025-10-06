SHELL := /bin/bash
ROOT := $(CURDIR)
OUT_DIR := $(ROOT)/out
ROOTFS_IMG := $(OUT_DIR)/rootfs/adilos-rootfs.img
HALIUM_BOOT_IMG := $(OUT_DIR)/boot/halium-boot.img

.PHONY: all rootfs halium-boot flash push-rootfs clean ensure-out

all: rootfs halium-boot

ensure-out:
@mkdir -p $(OUT_DIR)/rootfs $(OUT_DIR)/boot

rootfs: ensure-out
ROOTFS_OUT=$(ROOTFS_IMG) $(ROOT)/rootfs/pmos/build_rootfs.sh

halium-boot: ensure-out
HALIUM_BOOT_OUT=$(HALIUM_BOOT_IMG) $(ROOT)/boot/device/oriole/make_halium_boot.sh

push-rootfs:
@if [ ! -f "$(ROOTFS_IMG)" ]; then \
echo "Rootfs image missing, run make rootfs first"; \
exit 1; \
fi
$(ROOT)/scripts/adb_wait.sh shell 'mkdir -p /data/adilos && chmod 700 /data/adilos'
adb push $(ROOTFS_IMG) /data/adilos/adilos-rootfs.img

flash: halium-boot rootfs
@if [ ! -f "$(HALIUM_BOOT_IMG)" ]; then \
echo "halium-boot image missing, run make halium-boot"; \
exit 1; \
fi
fastboot devices
fastboot flash boot $(HALIUM_BOOT_IMG)
fastboot reboot
$(MAKE) push-rootfs

clean:
rm -rf $(OUT_DIR)

