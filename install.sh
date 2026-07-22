#!/usr/bin/env bash
set -euo pipefail

CURL=/usr/bin/curl

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  "$CURL" -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "install.sh: brew not found after install" >&2
  exit 1
fi
