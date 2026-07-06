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
  local sentinel="${3:-}"

  if [[ -d "$target_dir/.git" ]]; then
    git -C "$target_dir" pull --ff-only
  elif [[ -n "$sentinel" && -e "$target_dir/$sentinel" ]]; then
    echo "Using existing $target_dir"
  elif [[ -e "$target_dir" ]]; then
    local backup_dir="$target_dir.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $target_dir to $backup_dir"
    mv "$target_dir" "$backup_dir"
    git clone --depth=1 "$repo_url" "$target_dir"
  else
    git clone --depth=1 "$repo_url" "$target_dir"
  fi
}

mkdir -p "$HOME/.oh-my-zsh/custom/plugins" "$HOME/.oh-my-zsh/custom/themes"
install_or_update_git_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$HOME/.oh-my-zsh" "oh-my-zsh.sh"
install_or_update_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "zsh-autosuggestions.zsh"
install_or_update_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting.zsh"

packages=(zsh git ghostty vscode cursor codex claude opencode starship)
for package in "${packages[@]}"; do
  stow --target "$HOME" --no-folding "$package"
done

"$ROOT/scripts/install-editor-extensions.sh"

if ! command -v volta >/dev/null 2>&1; then
  echo "Volta was not found after brew bundle. Check Homebrew PATH and rerun bootstrap."
  exit 1
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@24 pnpm eas-cli vercel @anthropic-ai/claude-code
node -v
pnpm -v
eas --version
vercel --version
claude --version

echo "Dotfiles installed. Restart your terminal to load the new shell."
