#!/usr/bin/env bash
set -euo pipefail

KEY_PATH=${1:-"snowflake_rsa_key.pem"}

if [ ! -f "$KEY_PATH" ]; then
  echo "Key file not found: $KEY_PATH" >&2
  exit 1
fi

# Output a single-line value with \n escapes, suitable for .env or GitHub Secrets
sed ':a;N;$!ba;s/\n/\\n/g' "$KEY_PATH"
