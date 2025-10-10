# Makefile (AdilOS)
# Outputs: out/boot, out/rootfs

REPO_ROOT := $(abspath .)
OUT_BOOT  := $(REPO_ROOT)/out/boot
OUT_ROOTFS:= $(REPO_ROOT)/out/rootfs

INITRAMFS := $(OUT_BOOT)/initramfs.cpio.gz
HALIUM_BOOT_IMG := $(OUT_BOOT)/halium-boot.img
ROOTFS_IMG := $(OUT_ROOTFS)/adilos-rootfs.img

PMOS_BUILD := $(REPO_ROOT)/rootfs/pmos/build_rootfs.sh
MKINIT     := $(REPO_ROOT)/boot/halium-initramfs/mkinitramfs.sh
MKBOOT     := $(REPO_ROOT)/boot/device/or_any/make_halium_boot.sh

.PHONY: all rootfs initramfs halium-boot dirs clean help

all: rootfs halium-boot

dirs:
	@mkdir -p "$(OUT_BOOT)" "$(OUT_ROOTFS)"
	@mkdir -p "$(REPO_ROOT)/boot"
	@[ -L "$(REPO_ROOT)/boot/out" ] || ln -snf "$(OUT_BOOT)" "$(REPO_ROOT)/boot/out"

initramfs: $(INITRAMFS)

$(INITRAMFS): | dirs
	@echo "[+] Building initramfs..."
	@bash "$(MKINIT)"
	@[ -f "$(INITRAMFS)" ] || ln -sf "$(REPO_ROOT)/boot/out/initramfs.cpio.gz" "$(INITRAMFS)"
	@ls -lh "$(INITRAMFS)"

rootfs: $(ROOTFS_IMG)

$(ROOTFS_IMG): | dirs
	@echo "[+] Building rootfs image..."
	@bash "$(PMOS_BUILD)" "$(ROOTFS_IMG)"
	@ls -lh "$(ROOTFS_IMG)"

halium-boot: $(HALIUM_BOOT_IMG)

$(HALIUM_BOOT_IMG): initramfs | dirs
	@echo "[+] Building halium-boot image..."
	@bash "$(MKBOOT)" --initramfs "$(INITRAMFS)" --out "$(HALIUM_BOOT_IMG)"
	@ls -lh "$(HALIUM_BOOT_IMG)"

clean:
	@echo "[+] Cleaning outputs..."
	@rm -rf "$(OUT_BOOT)" "$(OUT_ROOTFS)"

help:
	@echo "Targets: all (default), initramfs, rootfs, halium-boot, clean"
