#!/usr/bin/env bash
set -euo pipefail
command -v dos2unix >/dev/null 2>&1 || { echo "[i] dos2unix not found, using sed fallback"; }
fix() {
  local f="$1"
  if command -v dos2unix >/dev/null 2>&1; then dos2unix "$f" >/dev/null 2>&1 || true; fi
  sed -i 's/\r$//' "$f"
  # strip BOM if present
  sed -i '1s/^\xEF\xBB\xBF//' "$f"
}
fix Makefile
echo "[+] Normalized line endings for Makefile"
