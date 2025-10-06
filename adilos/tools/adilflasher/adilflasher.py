#!/usr/bin/env python3
"""AdilOS flashing helper."""
import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_BOOT = ROOT / "out" / "boot" / "halium-boot.img"
DEFAULT_ROOTFS = ROOT / "out" / "rootfs" / "adilos-rootfs.img"


def run(cmd, check=True):
    print("+", " ".join(str(x) for x in cmd))
    return subprocess.run(cmd, check=check)


def wait_for_adb():
    run(["adb", "wait-for-device"])


def flash_boot(image: Path):
    run(["fastboot", "devices"])
    run(["fastboot", "flash", "boot", str(image)])
    run(["fastboot", "reboot"])


def push_rootfs(image: Path):
    wait_for_adb()
    run(["adb", "shell", "mkdir", "-p", "/data/adilos"])
    run(["adb", "shell", "chmod", "700", "/data/adilos"])
    run(["adb", "push", str(image), "/data/adilos/adilos-rootfs.img"])


def tail_logs():
    try:
        run(["adb", "logcat"], check=False)
    except KeyboardInterrupt:
        pass


def main():
    parser = argparse.ArgumentParser(description="Flash AdilOS artifacts")
    parser.add_argument("--boot", type=Path, default=DEFAULT_BOOT, help="Path to halium-boot.img")
    parser.add_argument("--rootfs", type=Path, default=DEFAULT_ROOTFS, help="Path to adilos-rootfs.img")
    parser.add_argument("--no-tail", action="store_true", help="Do not tail logcat after flashing")
    args = parser.parse_args()

    if not args.boot.exists():
        print(f"Boot image missing: {args.boot}", file=sys.stderr)
        return 1
    if not args.rootfs.exists():
        print(f"Rootfs image missing: {args.rootfs}", file=sys.stderr)
        return 1

    flash_boot(args.boot)
    push_rootfs(args.rootfs)
    if not args.no_tail:
        tail_logs()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
