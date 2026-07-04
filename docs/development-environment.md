# Development Environment

Generated on 2026-07-04.

Scope: default setup for React Native with Expo and Next.js development on macOS.

## Default Toolchain

Installed by `Brewfile`:

- Android Studio and Android Platform Tools
- Zulu JDK 17
- Watchman
- CocoaPods
- Docker, Docker Compose, and Colima
- GitHub CLI
- direnv
- gitleaks
- Expo Orbit
- VS Code and Cursor
- Chrome, Brave, and Zen for browser testing
- Proxyman and ngrok for network debugging

Installed by Volta in `bootstrap.sh`:

- Node 24
- pnpm
- eas-cli
- vercel
- @anthropic-ai/claude-code

Shell environment:

- `JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home`
- `ANDROID_HOME=$HOME/Library/Android/sdk`
- Android `cmdline-tools`, `platform-tools`, and `emulator` are added to `PATH`.
- Volta bin is added to `PATH`.
- `direnv hook zsh` loads automatically when `direnv` is installed.

## Why These Tools Are Included

React Native / Expo:

- React Native requires Node, Watchman, a JDK, Android Studio, and Android SDK tooling.
- JDK 17 is the safer default for React Native Android builds.
- Expo/EAS workflows use `eas-cli` for build, submit, update, credentials, and project configuration.
- Expo Orbit speeds up opening EAS builds and updates on Android emulators and iOS simulators.
- CocoaPods is required when working with iOS native dependencies or Expo prebuild/dev-client projects.

Next.js:

- Next.js currently requires Node 20.9 or newer; Node 24 satisfies this.
- pnpm is the default package manager for this setup.
- Vercel CLI is useful for project linking, environment inspection, local deployment parity, logs, and deployments.
- Browser coverage includes Chromium-based browsers and Zen for Firefox-family checks.

Security and local environment hygiene:

- `direnv` keeps project-specific environment variables scoped to the current directory.
- `gitleaks` adds a structured secret scan before pushing.
- Secrets should stay in project-local `.env` files or password managers, not in global shell config or this repo.

## Check The Environment

Run:

```sh
./scripts/check-dev-env.sh
```

This checks:

- Node, pnpm, Vercel CLI, and direnv
- EAS CLI, Java, Watchman, CocoaPods, ADB, and Android emulator
- `JAVA_HOME`, `ANDROID_HOME`, and Android SDK paths
- Xcode selection and `xcodebuild`
- Expo Orbit app installation
- Docker, Colima, GitHub CLI, and gitleaks

The script is read-only. It reports missing or failing tools and exits non-zero if required checks fail.

## Common Usage

After changing dotfiles setup:

```sh
./bootstrap.sh
./scripts/check-dev-env.sh
```

Before pushing this repository:

```sh
./scripts/check-secrets.sh
git diff --check
git status --short
```

When working in a project with `direnv`:

```sh
cp .envrc.example .envrc
direnv allow
direnv status
```

Use `.envrc.example` for non-secret documentation. Keep real tokens in `.env`, `.env.local`, a password manager, or the provider dashboard. If `.envrc` exports secrets, keep it ignored.

Expo daily checks:

```sh
eas whoami
npx expo start
npx expo-doctor
```

Expo build setup:

```sh
npx expo install expo-dev-client
eas build:configure
eas build --profile development --platform ios
eas build --profile development --platform android
```

Next.js daily checks:

```sh
pnpm install
pnpm dev
pnpm lint
pnpm test
```

Vercel project setup:

```sh
vercel login
vercel link
vercel env pull .env.local
vercel dev
```

## Manual Steps After A Fresh Mac

Xcode:

```sh
xcode-select -p
xcodebuild -version
```

Then open Xcode and check:

- Xcode -> Settings -> Locations -> Command Line Tools is selected.
- Xcode -> Settings -> Platforms has the iOS runtime you need.
- Accept any license prompts if `xcodebuild` asks.

Android Studio:

- Open Android Studio once after install.
- Install the Android SDK platform and build tools required by your project.
- Create at least one Android Virtual Device if you use emulators.
- Confirm `adb devices` sees your emulator or physical device.

Expo:

```sh
eas login
eas whoami
```

Use development builds for production-grade Expo apps:

```sh
npx expo install expo-dev-client
eas build:configure
```

Next.js / Vercel:

```sh
vercel login
vercel --version
```

Use project-local dependencies for framework tooling:

- `next`, `react`, `react-dom`
- `typescript`
- `eslint`
- `prettier`
- `vitest` or `jest`
- `playwright`
- `tailwindcss`

Do not install these globally unless a project explicitly needs it.

## Optional Tools

Add these only when the workflow actually needs them:

- `ios-deploy`: install/debug apps on physical iPhones from the command line.
- `mkcert` and `nss`: trusted local HTTPS certificates for OAuth, PWA, and callback testing.
- Maestro: mobile E2E tests for Expo/React Native apps.
- `imagemagick`: local asset resizing/conversion if app icon and screenshot work is frequent.

These are not installed by default because they either add extra trust state, increase setup weight, or are better kept project-specific.

## Project-Level Defaults

Recommended per-project files:

- `.nvmrc` or `packageManager` in `package.json` if the project needs a specific Node/package-manager version.
- `.env.example` with non-secret variable names.
- `.env.local` ignored by Git for Next.js local secrets.
- `.envrc.example` when using direnv.
- `eas.json` for Expo build profiles.
- `playwright.config.ts` for Next.js E2E tests.
- `vitest.config.ts` for unit/component tests.

Keep credentials out of dotfiles:

- Expo tokens
- Vercel tokens
- Google service account JSON
- Apple signing certificates and provisioning profiles
- Android keystores
- OAuth client secrets
