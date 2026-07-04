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

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

packages=(zsh git ghostty codex claude opencode)
for package in "${packages[@]}"; do
  stow --target "$HOME" --no-folding "$package"
done

if ! command -v volta >/dev/null 2>&1; then
  echo "Volta was not found after brew bundle. Check Homebrew PATH and rerun bootstrap."
  exit 1
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@24 pnpm eas-cli @anthropic-ai/claude-code
node -v
pnpm -v
eas --version
claude --version

echo "Dotfiles installed. Restart your terminal to load the new shell."
