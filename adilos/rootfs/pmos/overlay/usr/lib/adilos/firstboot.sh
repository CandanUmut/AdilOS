#!/usr/bin/env bash
set -euo pipefail

LOG_DIR=/data/adilos/logs
MODEL_DIR=/data/adilos/models
mkdir -p "$LOG_DIR" "$MODEL_DIR"
chmod 700 /data/adilos || true
hostnamectl set-hostname adilos || true

echo "Welcome to AdilOS" > /etc/motd

if [ ! -f /etc/adilos/firstboot-complete ]; then
  cat <<'MSG' >/etc/issue
AdilOS Ignition
--------------
Default user: user (no password)
Run 'adilos-firstboot-wizard' to personalize your device.
MSG
  touch /etc/adilos/firstboot-complete
fi
