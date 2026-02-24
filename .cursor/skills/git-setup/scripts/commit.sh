#!/usr/bin/env bash
# Commit all changes with the given message.
# Usage: commit.sh "your commit message"
# Run from the project repository root (not from inside .cursor or submodules).

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 \"commit message\""
  exit 1
fi

# Find repo root (directory containing .git)
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || true
if [ -z "$GIT_ROOT" ]; then
  echo "Error: Not in a git repository."
  exit 1
fi

cd "$GIT_ROOT"
git add -A
git commit -m "$*"
