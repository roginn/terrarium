#!/usr/bin/env bash
set -euo pipefail

# If GITHUB_TOKEN is set, configure git to use gh as credential helper
# Import git identity from host
if [ -f /home/dev/.gitconfig-host ]; then
    name=$(git config -f /home/dev/.gitconfig-host user.name 2>/dev/null || true)
    email=$(git config -f /home/dev/.gitconfig-host user.email 2>/dev/null || true)
    [ -n "$name" ] && git config --global user.name "$name"
    [ -n "$email" ] && git config --global user.email "$email"
fi

# Configure GitHub authentication via PAT
if [ -n "${GITHUB_TOKEN:-}" ]; then
    gh auth setup-git 2>/dev/null
    git config --global url."https://github.com/".insteadOf "git@github.com:"
fi

exec "$@"
