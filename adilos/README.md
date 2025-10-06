# AdilOS Ignition MVP

AdilOS ("FairOS") is a privacy-first mobile operating system targeting the Google Pixel 6 (oriole). This repository contains the tooling, configuration, and reference applications required to build a Halium-style boot image, generate an Alpine/postmarketOS-based root filesystem, and assemble a minimal first-boot experience with local AI capabilities.

## Highlights

- **Security & Privacy:** Apache-2.0 licensing, no telemetry or ads, Ecosia as the default search engine, and a one-tap child-safe DNS and content filter.
- **Device Target:** Google Pixel 6 (oriole) via a Halium boot flow that mounts a looped rootfs image from userdata.
- **User Experience:** Phosh-based compositor with AdilShell UX, AdilBrowser, FairStore, and demo AdilNotes app. Waydroid integration is optional and disabled by default.
- **Local AI:** Offline speech recognition (Whisper), text generation (LLaMA/llama.cpp), and text-to-speech (Piper) exposed via lightweight HTTP services and DBus shims.

## Repository Layout

```
adilos/
  boot/              # halium initramfs and device-specific packaging
  rootfs/            # pmbootstrap helpers and overlay files
  packages/          # UI, AI, store, and helper applications
  services/          # systemd units for core services and toggles
  tools/             # flashing utilities and model download helpers
  docs/              # quickstart and troubleshooting references
```

Refer to [`docs/QUICKSTART.md`](docs/QUICKSTART.md) for build and flashing instructions, and [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for debugging tips.
