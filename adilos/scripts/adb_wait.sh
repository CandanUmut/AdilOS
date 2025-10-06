#!/usr/bin/env bash
set -euo pipefail

if ! command -v adb >/dev/null 2>&1; then
  echo "adb binary not found in PATH" >&2
  exit 1
fi

adb wait-for-device
adb "$@"
