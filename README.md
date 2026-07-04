# Pholuu macOS Dotfiles

Lean macOS setup for frontend, React Native, Expo, and terminal AI agents.

The setup is intentionally small:

- zsh without Oh My Zsh on the startup path
- direct loading for `zoxide`, `fzf`, autosuggestions, and syntax highlighting
- Volta-managed Node tooling for `pnpm`, `eas`, and Claude Code
- Android Studio, Android Platform Tools, Java 17, CocoaPods, Watchman, Docker/Colima
- Codex, Claude Code, and opencode config, without auth/session files

## Install

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

If `stow` reports conflicts on an existing machine, move the existing files aside or compare them first. Do not use `--adopt` unless you are intentionally importing local changes into the repo.

## Layout

```text
zsh/       shell startup files
git/       global Git config
wezterm/   terminal config
codex/     Codex config and global instructions
claude/    Claude Code global instructions/settings
opencode/  opencode config and instructions
docs/      inventory and audit notes
scripts/   repo checks
```

## Before Pushing

Run:

```sh
./scripts/check-secrets.sh
git status --ignored
```

The repo intentionally ignores auth files, session history, telemetry, caches, sqlite databases, and dependency folders.
