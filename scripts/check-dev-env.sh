#!/usr/bin/env bash
set -uo pipefail

failures=0

check_command() {
  local label="$1"
  shift
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'MISSING %-22s %s\n' "$label" "$command_name"
    failures=$((failures + 1))
    return 0
  fi

  local output
  if output="$("$@" 2>&1 | head -n 1)"; then
    printf 'OK      %-22s %s\n' "$label" "$output"
  else
    printf 'FAIL    %-22s %s\n' "$label" "$output"
    failures=$((failures + 1))
  fi
}

check_path() {
  local label="$1"
  local path="$2"

  if [[ -e "$path" ]]; then
    printf 'OK      %-22s %s\n' "$label" "$path"
  else
    printf 'MISSING %-22s %s\n' "$label" "$path"
    failures=$((failures + 1))
  fi
}

check_env() {
  local name="$1"
  local value="${!name:-}"

  if [[ -n "$value" ]]; then
    printf 'OK      %-22s %s\n' "$name" "$value"
  else
    printf 'MISSING %-22s not set\n' "$name"
    failures=$((failures + 1))
  fi
}

echo "Core JavaScript"
check_command "Node" node -v
check_command "pnpm" pnpm -v
check_command "Vercel CLI" vercel --version
check_command "direnv" direnv version

echo
echo "Expo and React Native"
check_command "EAS CLI" eas --version
check_command "Java" java -version
check_command "Watchman" watchman --version
check_command "CocoaPods" pod --version
check_command "ADB" adb version
check_command "Android emulator" emulator -version
check_env "JAVA_HOME"
check_env "ANDROID_HOME"
check_path "Android SDK" "${ANDROID_HOME:-$HOME/Library/Android/sdk}"
check_path "Android platform-tools" "${ANDROID_HOME:-$HOME/Library/Android/sdk}/platform-tools"

echo
echo "iOS"
check_command "xcode-select" xcode-select -p
check_command "xcodebuild" xcodebuild -version
check_path "Expo Orbit app" "/Applications/Expo Orbit.app"

echo
echo "Containers and security helpers"
check_command "Docker" docker --version
check_command "Colima" colima version
check_command "GitHub CLI" gh --version
check_command "gitleaks" gitleaks version

echo
if [[ "$failures" -eq 0 ]]; then
  echo "Development environment check passed."
else
  echo "Development environment check found $failures issue(s)."
fi

exit "$failures"
