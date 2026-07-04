#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if rg -n --hidden \
  --glob '!backups/**' \
  --glob '!**/node_modules/**' \
  --glob '!**/cache/**' \
  --glob '!**/sessions/**' \
  --glob '!**/*.sqlite*' \
  '(api[_-]?key\s*[:=]|auth[_-]?token\s*[:=]|access[_-]?token\s*[:=]|oauth_token\s*[:=]|password\s*[:=]|passwd\s*[:=]|bearer [A-Za-z0-9._-]{20,}|sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|OPENAI_API_KEY\s*=|ANTHROPIC_API_KEY\s*=)' \
  .; then
  echo "Potential secret patterns found. Review before pushing."
  exit 1
fi

echo "No obvious secret patterns found."
