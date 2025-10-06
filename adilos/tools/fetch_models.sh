#!/usr/bin/env bash
set -euo pipefail

DEST=${1:-/data/adilos/models}
mkdir -p "$DEST"

cat <<MSG
This script downloads recommended GGUF and Whisper/Piper models for AdilOS.
You must supply URLs manually to honor licensing constraints.
Place your downloaded models into $DEST.
MSG
