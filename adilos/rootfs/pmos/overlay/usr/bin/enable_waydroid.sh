#!/usr/bin/env bash
set -euo pipefail

if ! command -v waydroid >/dev/null 2>&1; then
  echo "Waydroid not installed." >&2
  exit 1
fi

systemctl stop waydroid-container.service 2>/dev/null || true
modprobe binder_linux devices=binder,hwbinder,vndbinder || true
mkdir -p /dev/binderfs
mount -t binder binder /dev/binderfs 2>/dev/null || true
sudo systemctl enable waydroid-container.service
sudo systemctl start waydroid-container.service
sudo loginctl enable-linger "$SUDO_USER"
systemctl --user start waydroid-session.target
