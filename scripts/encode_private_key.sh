#!/usr/bin/env bash
set -euo pipefail

KEY_PATH=${1:-"snowflake_rsa_key.pem"}

if [ ! -f "$KEY_PATH" ]; then
  echo "Key file not found: $KEY_PATH" >&2
  exit 1
fi

# Output a single-line value with \n escapes, suitable for .env or GitHub Secrets.
# Use python for portability across macOS/Linux.
python3 - "$KEY_PATH" <<'PY'
import sys
from pathlib import Path

key_path = Path(sys.argv[1])
data = key_path.read_text()
print(data.replace("\n", "\\n").rstrip("\\n"))
PY
