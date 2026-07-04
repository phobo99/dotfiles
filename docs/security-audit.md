# Security Audit

Generated on 2026-07-04.

Scope: local macOS security posture plus dotfiles repository hygiene. Commands were read-only; no system settings were changed.

## Summary

Good:

- FileVault is enabled.
- System Integrity Protection is enabled.
- Gatekeeper assessments are enabled.
- Repository secret scan found no obvious secret patterns.
- Tracked files do not include browser profiles, app sessions, auth files, caches, logs, or local databases.
- `~/.ssh` directory is `700`; private SSH key file is `600`.
- No valid local code-signing identities were found.

Needs attention:

- macOS Application Firewall is disabled.
- Firewall stealth mode is off.
- macOS 26.5.2 is available; the machine is on 26.5.
- Automatic download/install, critical updates, and config data updates are disabled in Software Update preferences.
- Homebrew has many outdated packages, including `openssl@3`, `gh`, `docker`, `colima`, `ruby`, `python@3.13`, and `ca-certificates`.
- GitHub CLI auth token for `phobo99` is invalid.
- Existing SSH key is RSA; prefer Ed25519 for new machine keys.
- Claude config has `skipDangerousModePermissionPrompt: true`.
- Codex config includes multiple MCP servers and trusted local paths; review before using untrusted repos/prompts.

## System State

macOS:

```text
ProductName: macOS
ProductVersion: 26.5
BuildVersion: 25F71
```

FileVault / volume encryption:

```text
FileVault: Yes
Sealed: Yes
Locked: No
```

`fdesetup status` returned `Unknown volume or device specifier: '/'`, so FileVault was verified with `diskutil info /`.

SIP:

```text
System Integrity Protection status: enabled.
```

Gatekeeper:

```text
assessments enabled
```

Firewall:

```text
Firewall is disabled. (State = 0)
Firewall stealth mode is off
Firewall has block all state set to disabled.
Automatically allow built-in signed software ENABLED.
Automatically allow downloaded signed software ENABLED.
```

Software Update:

```text
AutomaticDownload = 0
AutomaticallyInstallMacOSUpdates = 0
ConfigDataInstall = 0
CriticalUpdateInstall = 0
LastFullSuccessfulDate = "2026-07-04 06:53:41 +0000"
LastUpdatesAvailable = 3
```

Available updates from `softwareupdate --list`:

```text
Command Line Tools for Xcode 26.5
Command Line Tools for Xcode 26.6
macOS Tahoe 26.5.2, Version: 26.5.2, Recommended: YES, Action: restart
```

XProtect / Gatekeeper data:

```text
Latest observed XProtectPlistConfigData install: 2026-05-26, version 5345
Latest observed XProtectPayloads install: 2026-05-26, version 157
Latest observed Gatekeeper Compatibility Data install: 2026-05-26
```

Power settings:

```text
displaysleep 10
sleep 1
standby 1
hibernatemode 3
powernap 1
womp 1
```

Screen lock:

```text
askForPassword and askForPasswordDelay were not present in com.apple.screensaver defaults.
```

Confirm manually in System Settings:

- Lock Screen -> Require password after screen saver begins or display is turned off.
- Recommended value: immediately or 5 seconds.

Remote services:

```text
systemsetup -getremotelogin required administrator access.
systemsetup -getremoteappleevents required administrator access.
launchctl did not find com.openssh.sshd or com.apple.screensharing.
netstat did not show port 22 listening.
```

Listening TCP ports observed:

```text
rapportd: ports 53201, 53202, 54507
ControlCenter: ports 5000, 7000
Raycast: 127.0.0.1:7265
figma_agent: 127.0.0.1:44950, 127.0.0.1:44960
adb: 127.0.0.1:5037
node: 127.0.0.1:3001
```

Notes:

- `rapportd` and ControlCenter ports are Apple ecosystem services.
- `adb` is expected with Android tooling.
- `figma_agent` is expected if Figma desktop/MCP integration is active.
- `node` on `127.0.0.1:3001` should be checked if it is not intentionally running.

## Repository Hygiene

Secret scan:

```text
./scripts/check-secrets.sh
No obvious secret patterns found.
```

Tracked files:

```text
.gitignore
Brewfile
README.md
bootstrap.sh
claude/.claude/CLAUDE.md
claude/.claude/settings.json
codex/.codex/AGENTS.md
codex/.codex/config.toml
cursor/Library/Application Support/Cursor/User/keybindings.json
cursor/Library/Application Support/Cursor/User/settings.json
docs/inventory.md
docs/manual-app-state.md
docs/optimization-audit.md
editors/cursor-extensions.txt
editors/vscode-extensions.txt
ghostty/Library/Application Support/com.mitchellh.ghostty/config.ghostty
git/.gitconfig
opencode/.config/opencode/AGENTS.md
opencode/.config/opencode/opencode.jsonc
scripts/check-secrets.sh
scripts/install-editor-extensions.sh
vscode/Library/Application Support/Code/User/settings.json
zsh/.p10k.zsh
zsh/.zprofile
zsh/.zshenv
zsh/.zshrc
```

Ignore coverage is good for:

- auth files
- host files
- token/secret/credential-like filenames
- private key file extensions
- `.env` files
- session history
- telemetry
- editor global/workspace storage
- cache/log directories
- SQLite/database files
- dependencies and temp directories

Keep running this before push:

```sh
./scripts/check-secrets.sh
git diff --cached
git status --ignored
```

## Identity And Keys

SSH:

```text
~/.ssh: drwx------
~/.ssh/config: -rw-r--r--
~/.ssh/id_rsa: -rw-------
~/.ssh/id_rsa.pub: -rw-r--r--
~/.ssh/known_hosts: -rw-------
```

Recommendation:

- For new machine keys, generate Ed25519:

```sh
ssh-keygen -t ed25519 -a 100 -C "phobotkcb@gmail.com"
```

GPG:

```text
~/.gnupg does not exist.
```

Code signing:

```text
0 valid identities found
```

GitHub CLI:

```text
Token for github.com account phobo99 is invalid.
```

Fix:

```sh
gh auth login -h github.com
```

or remove stale auth:

```sh
gh auth logout -h github.com -u phobo99
```

## Agent Config Review

Claude:

```json
"skipDangerousModePermissionPrompt": true
```

This is convenient, but it weakens the safety prompt boundary. Keep it only if you are comfortable reviewing prompts/repos yourself before giving Claude broad filesystem or shell access.

Codex:

- MCP servers configured: Context7, Figma, codegraph, node_repl, Argent.
- `node_repl` trusts `/Users/pholuu/.codex`.
- Several Argent MCP tools are configured with approval mode.

Recommendation:

- Keep auth/session files ignored.
- Review MCP servers after every restore.
- Avoid using permission-heavy agent configs inside unknown repositories.

## Recommended Fix Order

1. Install macOS Tahoe 26.5.2 and restart.
2. Enable Application Firewall.
3. Enable stealth mode.
4. Re-enable automatic security-related updates if you want the safer default.
5. Upgrade Homebrew packages after the macOS update.
6. Re-authenticate GitHub CLI.
7. Generate a new Ed25519 SSH key for this machine and add it to GitHub.
8. Confirm lock-screen password requirement manually in System Settings.
9. Decide whether `skipDangerousModePermissionPrompt` should stay enabled.
10. Check whether `node` on `127.0.0.1:3001` is intentional.

Useful commands:

```sh
softwareupdate --list
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode
gh auth status
HOMEBREW_NO_AUTO_UPDATE=1 brew outdated
```
