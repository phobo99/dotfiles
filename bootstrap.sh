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

install_or_update_git_repo() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    git -C "$target_dir" pull --ff-only
  else
    git clone --depth=1 "$repo_url" "$target_dir"
  fi
}

mkdir -p "$HOME/.oh-my-zsh/custom/plugins" "$HOME/.oh-my-zsh/custom/themes"
install_or_update_git_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh"
install_or_update_git_repo "https://github.com/romkatv/powerlevel10k.git" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
install_or_update_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
install_or_update_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

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
