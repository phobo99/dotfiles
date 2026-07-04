# Interactive shell for frontend/RN/Expo work.
# Keep this file free of secrets; API keys belong in project-local env files.

if [[ -t 0 && -t 1 && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ $- != *i* ]] && return

typeset -U path PATH

export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export BUN_INSTALL="$HOME/.bun"
export VOLTA_HOME="$HOME/.volta"
export REACT_EDITOR="cursor"
export EDITOR="cursor"
export VISUAL="cursor"
export ZSH="$HOME/.oh-my-zsh"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89,italic"

path=(
  "$HOME/.local/bin"
  "$VOLTA_HOME/bin"
  "$BUN_INSTALL/bin"
  "$HOME/.opencode/bin"
  "$HOME/.lmstudio/bin"
  "$HOME/.antigravity/antigravity/bin"
  "$HOME/Library/pnpm/bin"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "$HOME/.rbenv/shims"
  "$HOME/.rbenv/bin"
  $path
)
export PATH

HISTFILE="$HOME/.zhistory"
SAVEHIST=50000
HISTSIZE=50000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt auto_cd
setopt prompt_subst

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
ZSH_COMPDUMP="$HOME/.zcompdump"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  fzf
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if command -v eza >/dev/null 2>&1; then
  alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"
  alias ll="eza --color=always --long --icons=always --git"
else
  alias ll="ls -lah"
fi

alias c="clear"
alias grep="grep --color=auto"

_rbenv_init() {
  unfunction rbenv 2>/dev/null
  eval "$("$HOME/.rbenv/bin/rbenv" init - zsh)"
}

if [[ -x "$HOME/.rbenv/bin/rbenv" ]]; then
  rbenv() {
    _rbenv_init
    rbenv "$@"
  }
fi

if [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null 2>&1; then
  source "$(kiro --locate-shell-integration-path zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if [[ -t 0 && -t 1 && -r "$ZSH/oh-my-zsh.sh" ]]; then
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[default]='fg=#ffffff'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ffffff'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#7dcfff,bold'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7dcfff,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a,bold'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#ffffff'
  ZSH_HIGHLIGHT_STYLES[string]='fg=#9ece6a'
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz colors
  colors
  PROMPT='%F{cyan}%~%f %(?.%F{green}.%F{red})%#%f '
  RPROMPT=''
fi

if [[ -t 0 && -t 1 && -f "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi
