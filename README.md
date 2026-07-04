# Pholuu macOS Dotfiles

Repository: personal macOS setup for frontend, React Native, Expo, and terminal AI agents.

This repository keeps a new Mac close to daily-driver ready without tracking local app state, browser profiles, credentials, session history, or generated caches.

---

## The Problem

Fresh macOS setup gets messy quickly:

- Terminal, editor, browser, mobile, and AI-agent settings live in different places.
- Browser profiles, app sessions, SQLite state, and auth files are easy to commit by accident.
- React Native and Expo need several moving parts: Java, Android tooling, CocoaPods, Watchman, Docker/Colima, and Node tooling.
- Rebuilding a machine later is hard if the setup notes are only memory.

Traditional dotfiles help with shell config, but they usually do not document what is intentionally not portable.

## The Solution

This repo uses a small `bootstrap.sh` plus GNU Stow:

- Installs Homebrew packages from `Brewfile`.
- Disables Homebrew analytics.
- Installs Oh My Zsh, Powerlevel10k, autosuggestions, and syntax highlighting.
- Stows selected config directories into `$HOME`.
- Installs VS Code and Cursor extensions from tracked lists.
- Installs Volta-managed Node tooling: Node 24, `pnpm`, `eas-cli`, `vercel`, and Claude Code.
- Keeps non-TTY shells quiet so scripts and agents do not load prompt/plugin UI.
- Keeps secrets, auth state, browser profiles, telemetry, logs, caches, and SQLite databases out of Git.

## What It Installs

Core CLI:

- `git`, `stow`, `ripgrep`, `eza`, `fzf`, `zoxide`
- `volta`, `direnv`, `watchman`, `cocoapods`, `rbenv`
- `docker`, `docker-compose`, `colima`
- `gh`, `gitleaks`, `scrcpy`, `rtk`, `emojify`
- Volta-managed `node@24`, `pnpm`, `eas-cli`, `vercel`, and Claude Code

Applications:

- Development: VS Code, Cursor, Android Studio, Android Platform Tools, Zulu JDK 17
- Terminal and agents: Ghostty, Codex, CodexBar
- Browsers: Chrome, Brave, Zen
- Network/debugging: Proxyman, Cloudflare WARP, ngrok
- Expo: Expo Orbit
- Communication/productivity: Slack, Telegram, Raycast

## Architecture

### Directory Structure

```text
dotfiles/
|-- bootstrap.sh                         # Main setup script
|-- Brewfile                             # Homebrew formulae and casks
|-- .gitignore                           # Secret, auth, cache, and generated-state ignores
|-- scripts/
|   |-- check-secrets.sh                 # Fast pre-push secret pattern scan
|   |-- check-dev-env.sh                 # React Native/Expo/Next.js environment check
|   `-- install-editor-extensions.sh     # VS Code and Cursor extension restore
|-- docs/
|   |-- inventory.md                     # Current machine inventory snapshot
|   |-- development-environment.md       # Expo/RN/Next.js toolchain notes
|   |-- manual-app-state.md              # State intentionally restored by login/manual sync
|   |-- optimization-audit.md            # Shell/app-state optimization notes
|   `-- security-audit.md                # Current machine security review
|-- zsh/
|   |-- .zshenv
|   |-- .zprofile
|   |-- .zshrc
|   `-- .p10k.zsh
|-- git/
|   `-- .gitconfig
|-- ghostty/
|   `-- Library/Application Support/com.mitchellh.ghostty/config.ghostty
|-- vscode/
|   `-- Library/Application Support/Code/User/settings.json
|-- cursor/
|   `-- Library/Application Support/Cursor/User/
|-- codex/
|   `-- .codex/
|-- claude/
|   `-- .claude/
`-- opencode/
    `-- .config/opencode/
```

### Key Design Decisions

1. Use Stow instead of copying files

GNU Stow creates symlinks from this repo into `$HOME`, so the repository remains the source of truth.

```sh
stow --target "$HOME" --no-folding zsh git ghostty vscode cursor codex claude opencode
```

2. Do not track local app state

Browser profiles, cookies, extension state, certificates, VPN state, telemetry, sessions, logs, and SQLite databases are machine-local. They are ignored and documented in `docs/manual-app-state.md`.

3. Keep non-interactive shells quiet

The zsh config guards prompt and plugin loading so script and agent shells stay fast and predictable.

4. Use Volta for Node tooling

Node, `pnpm`, `eas-cli`, `vercel`, and Claude Code are installed through Volta during bootstrap so JavaScript tooling is versioned outside of Homebrew casks.

5. Treat agent configs as sensitive operational config

Codex, Claude, and opencode configs are portable, but their auth/session files are not. Permission-heavy agent settings should be reviewed after every new-machine restore.

## Usage

### Quick Start

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The script will:

1. Install Homebrew packages and casks from `Brewfile`.
2. Install or update Oh My Zsh, Powerlevel10k, and zsh plugins.
3. Stow tracked config directories into `$HOME`.
4. Restore VS Code and Cursor extensions.
5. Install Volta-managed Node, package, Expo, Vercel, and agent tooling.

After install, check the development toolchain:

```sh
./scripts/check-dev-env.sh
```

### Daily Usage

After changing setup files:

```sh
./bootstrap.sh
./scripts/check-dev-env.sh
```

Before committing or pushing:

```sh
./scripts/check-secrets.sh
git diff --check
git status --short
```

For project-local environment variables, create a project `.envrc` and allow it once:

```sh
cp .envrc.example .envrc
direnv allow
```

Keep real secrets in `.env`, `.env.local`, password managers, or provider dashboards. Do not commit `.envrc` if it exports secret values.

For Expo projects:

```sh
eas login
eas whoami
npx expo install expo-dev-client
eas build:configure
```

For Next.js projects on Vercel:

```sh
vercel login
vercel link
vercel env pull .env.local
pnpm dev
```

### Before Pushing

Run:

```sh
./scripts/check-secrets.sh
git status --ignored
```

The secret scan uses both a lightweight `rg` pattern check and `gitleaks` when available. It catches common mistakes, but it does not replace reviewing staged diffs.

### Update Inventory

When the machine changes meaningfully, update:

- `Brewfile` for installable packages.
- `docs/inventory.md` for observed local apps, launch agents, and tool versions.
- `docs/development-environment.md` for Expo, React Native, and Next.js setup decisions.
- `docs/manual-app-state.md` for anything restored by login or manual app setup.
- `docs/security-audit.md` after checking system security state.

## Security Checklist

Current security audit: `docs/security-audit.md`.

High-priority items to review on this machine:

- Enable macOS Application Firewall and stealth mode.
- Install the available macOS Tahoe 26.5.2 update.
- Re-enable automatic macOS download/install, critical updates, and config data updates if you want the safer default.
- Re-authenticate GitHub CLI; the current `gh` token is invalid.
- Consider replacing the existing RSA SSH key with Ed25519.
- Review Claude `skipDangerousModePermissionPrompt: true` before using untrusted prompts or repos.
- Review Codex MCP servers and trusted paths after every restore.

Useful checks:

```sh
./scripts/check-secrets.sh
spctl --status
csrutil status
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
softwareupdate --list
gh auth status
```

## Recovery Notes

On a replacement Mac:

```sh
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Then restore manual app state:

- Sign in to browsers and sync profiles intentionally.
- Sign in to Slack and Telegram.
- Re-register Cloudflare WARP.
- Reinstall/retrust Proxyman certificates only when needed.
- Re-authenticate GitHub CLI.
- Recreate any SSH/GPG keys that should be unique to the machine.

Do not commit restored browser profiles, VPN state, certificates, auth files, session history, caches, logs, or local databases.
