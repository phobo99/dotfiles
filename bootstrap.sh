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

packages=(zsh git ghostty vscode cursor codex claude opencode starship mise)

# Stow refuses to replace real files. Back up any real (non-symlink) target
# that a package wants to own, e.g. a hand-edited ~/.zshrc or a
# ~/.config/mise/config.toml written by `mise use -g` before the link existed.
backup_stow_conflicts() {
  local package="$1" rel target
  while IFS= read -r -d '' rel; do
    rel="${rel#"$ROOT/$package/"}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      local backup="$target.bak-$(date +%Y%m%d%H%M%S)"
      echo "Backing up existing $target to $backup"
      mv "$target" "$backup"
    fi
  done < <(find "$ROOT/$package" -type f -print0)
}

for package in "${packages[@]}"; do
  backup_stow_conflicts "$package"
done

for package in "${packages[@]}"; do
  stow --target "$HOME" --no-folding "$package"
done

"$ROOT/scripts/install-editor-extensions.sh"

# --- Runtimes and global JS tooling: mise -------------------------------------
# Tools and versions live in mise/.config/mise/config.toml (stowed above to
# ~/.config/mise/config.toml). Projects pin their own versions in mise.toml.
if ! command -v mise >/dev/null 2>&1; then
  echo "mise was not found after brew bundle. Check Homebrew PATH and rerun bootstrap."
  exit 1
fi

eval "$(mise activate bash --shims)"
mise install --yes
mise reshim

# Claude Code installed via npm under mise needs its native binary placed by
# its own install script (postinstall does not run reliably under mise).
claude_pkg="$(mise where npm:@anthropic-ai/claude-code 2>/dev/null || true)"
if [[ -n "$claude_pkg" ]]; then
  claude_install="$(find "$claude_pkg" -path '*/@anthropic-ai/claude-code/install.cjs' -print -quit 2>/dev/null || true)"
  if [[ -n "$claude_install" ]] && ! claude --version >/dev/null 2>&1; then
    echo "Fixing Claude Code native binary via $claude_install"
    (cd "$(dirname "$claude_install")" && node install.cjs) || echo "Claude Code install.cjs failed; run it manually."
    mise reshim
  fi
fi

# --- Vite+: build toolchain only (Node/package managers stay with mise) -------
VITE_PLUS_VERSION="${VITE_PLUS_VERSION:-1.2.0}"
if [[ ! -x "$HOME/.vite-plus/bin/vp" ]]; then
  curl -fsSL https://vite.plus | VP_VERSION="$VITE_PLUS_VERSION" bash
fi
if [[ -x "$HOME/.vite-plus/bin/vp" ]]; then
  # Opt out of Vite+ managing the global Node.js runtime and package managers.
  "$HOME/.vite-plus/bin/vp" env off || true
fi

node -v
bun --version
pnpm -v
yarn -v
eas --version
vercel --version
claude --version
"$HOME/.vite-plus/bin/vp" --version || true

echo "Dotfiles installed. Restart your terminal to load the new shell."
