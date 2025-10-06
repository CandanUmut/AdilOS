#!/usr/bin/env bash
set -euo pipefail

systemctl --user stop waydroid-session.target || true
sudo systemctl stop waydroid-container.service || true
sudo systemctl disable waydroid-container.service || true
