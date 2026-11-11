#!/usr/bin/env zsh
set -euo pipefail

repo_dir="${0:A:h:h}"

command -v pi >/dev/null || {
  print -u2 'pi is required; install it before running this script.'
  exit 1
}

pi install "$repo_dir/pi-skills"
mkdir -p "$HOME/.pi/agent"
cp "$repo_dir/agents/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
