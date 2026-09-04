#!/usr/bin/env bash

set -euo pipefail

input="$(cat)"
encoded="$(printf '%s' "$input" | base64 | tr -d '\r\n')"

if [[ -n "${TMUX:-}" ]]; then
  # Find the real outer tmux client.
  # Ignore our persistent popup scratch sessions.
  outer_tty="$(
    tmux list-clients -F '#{client_tty} #{session_name}' |
      awk '$2 !~ /^_popup_/ {print $1; exit}'
  )"

  if [[ -n "$outer_tty" && -w "$outer_tty" ]]; then
    printf '\033]52;c;%s\007' "$encoded" >"$outer_tty"
    exit 0
  fi
fi

# Normal non-tmux fallback
printf '\033]52;c;%s\007' "$encoded" >/dev/tty
