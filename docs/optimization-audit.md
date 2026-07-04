# Optimization Audit

Generated on 2026-07-04.

## Shell Changes Applied

- Restored Oh My Zsh and Powerlevel10k for real terminal sessions.
- Added bootstrap installation for Oh My Zsh, Powerlevel10k, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- Kept `fzf` and `zoxide` in the Oh My Zsh plugin list; the underlying binaries are installed through Homebrew.
- Guarded Oh My Zsh, Powerlevel10k, fzf/autosuggest/syntax-highlighting so non-TTY shells used by scripts and agents stay quiet.
- Removed duplicate manual `compinit`; Oh My Zsh owns completion initialization.
- Removed the eager `rbenv init` call from login shell startup; `rbenv` now initializes lazily when called.
- Kept RN/Expo essentials: Java 17, Android Studio, Android Platform Tools, Android SDK paths, Volta, Bun, pnpm global bin, Watchman via Brewfile, CocoaPods via Brewfile.
- Kept TUI-agent paths for Codex, Claude, opencode, LM Studio, and Antigravity.

## Startup Baseline

Before:

```text
zsh -i -c exit
real 0.68
```

After:

```text
zsh -i -c exit
real 0.02
```

This measurement is non-TTY, so real terminal startup will include Oh My Zsh, Powerlevel10k, fzf, zoxide, autosuggestions, and syntax highlighting. Non-TTY shells still avoid prompt/plugin UI, duplicate completion, and eager rbenv.

## Large Local State Not Tracked

- `.config/superpowers`: 2.8G
- `.bun`: 2.3G
- `.cache`: 1.9G
- `.npm`: 1.4G
- `.codex`: 830M
- `.volta`: 454M
- `.claude`: 262M

These are cache/session/tool-state directories, not portable dotfiles. They should stay out of Git.

## RAM Notes

The largest live memory users observed were app processes, especially Brave tabs/renderers, Slack, Cloudflare WARP, VS Code helpers, Telegram, Raycast, and Codex. Shell startup is now small; further RAM wins should come from reducing always-on GUI apps, browser tabs/extensions, and launch agents.

Suggested candidates to review manually:

- Disable Zoom updater if Zoom is not used often.
- Disable Google updater duplicates only if Chrome/Brave update policy is understood.
- Disable WARP autostart when VPN is not required.
- Disable Proxyman helper when proxy capture is not needed.
- Keep Watchman for React Native unless it is known to be idle and unwanted.

No app/package was uninstalled and no launch agent was disabled automatically.
