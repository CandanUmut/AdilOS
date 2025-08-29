# AdilOS Mobile — Roadmap (v0.1 → v1.0)

**Ignition Day:** Sunday, Aug 31, 2025 — Boot Linux UI on Pixel 5a.

- M0 Prep (Thu–Sat): toolchain, repo, blobs, initramfs
- M1 Ignition (Sun): halium‑boot + rootfs → UI visible
- M2 Phone Basics (Week +1): Wi‑Fi/BT, telephony, sensors, basic camera
- M3 Shell & AI (Week +2): AdilShell v0.1 + local AI & skills
- M4 Flasher & Docs (Week +3): adil‑flasher CLI, dev preview images
- M5 Security (Week +4): reproducible notes, custom AVB keys, signed builds
- M6 Ecosystem (Month 2): Waydroid (optional), AdilStore bootstrap, second device

## Guiding Principles
Freedom, Local‑First, Transparency, Pragmatism, Kind UX.

## Architecture
Kernel/halium‑boot → Linux rootfs (postmarketOS); Wayland; Halium bridge; AdilShell (QML); nova‑core (Rust AI); strict permissions; signed releases later.

## Sunday Runbook (Ignition Day)
1. Build rootfs via pmbootstrap → `rootfs/out/adilos-rootfs.img`
2. Build `halium/out/halium-boot.img` (initramfs mounts `/data/adilos/adilos-rootfs.img` then switch_root)
3. Flash boot, seed rootfs, reboot; verify UI + touch.
