#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh, then rerun this script."
  exit 1
fi

brew analytics off >/dev/null 2>&1 || true
brew bundle --file "$ROOT/Brewfile"

packages=(zsh git wezterm codex claude opencode)
for package in "${packages[@]}"; do
  stow --target "$HOME" --no-folding "$package"
done

if command -v volta >/dev/null 2>&1; then
  volta install node@24 pnpm eas-cli
fi

echo "Dotfiles installed. Restart your terminal to load the new shell."

