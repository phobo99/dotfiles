#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

install_extensions() {
  local cli="$1"
  local list_file="$2"

  if ! command -v "$cli" >/dev/null 2>&1; then
    echo "Skipping $cli extensions; $cli command not found."
    return 0
  fi

  while IFS= read -r extension || [[ -n "$extension" ]]; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    "$cli" --install-extension "$extension" --force
  done < "$list_file"
}

install_extensions code "$ROOT/vscode/extensions.txt"
install_extensions cursor "$ROOT/cursor/extensions.txt"

