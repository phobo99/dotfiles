# Manual App State

These apps are installed by `Brewfile`, but their local state is intentionally not tracked in Git.

## Browsers

Installed:

- Google Chrome
- Brave Browser
- Zen Browser

Do not track browser profile directories. They contain cookies, sessions, extension secrets, cache, and account data.

Restore path:

- Sign in to Chrome Sync for Chrome.
- Sign in to Brave Sync for Brave.
- Sign in to Firefox/Zen Sync or manually recreate Zen profiles if needed.

## Communication

Installed:

- Slack
- Telegram

Restore path:

- Log in to each workspace/account from the app.

## Network and Debugging

Installed:

- Proxyman
- Cloudflare WARP

Restore path:

- Proxyman: reinstall/retrust certificates manually from the app when needed.
- Cloudflare WARP: log in/register the device manually. The cask may require admin approval because it installs a daemon.

Do not commit certificates, VPN account state, browser profiles, or app support directories for these apps.

