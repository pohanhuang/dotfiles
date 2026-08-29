#!/bin/bash
# OSC 52 clipboard handler for tmux
# Based on: https://woojar.dev/posts/ssh-tmux-neovim-osc52-clipboard-guide/

buf=$(cat)

if [ -z "$buf" ]; then
  exit 0
fi

encoded=$(printf '%s' "$buf" | base64 | tr -d '\n')

TTY=$(tmux list-clients -F '#{client_tty}' 2>/dev/null | head -1)

if [ -z "$TTY" ]; then
  TTY=$(tmux display -p '#{client_tty}' 2>/dev/null)
fi

if [ -n "$TTY" ] && [ -e "$TTY" ]; then
  printf '\033]52;c;%s\007' "$encoded" >"$TTY" 2>/dev/null
  exit 0
fi

pane_tty=$(tmux display -p '#{pane_tty}' 2>/dev/null)
if [ -n "$pane_tty" ] && [ -e "$pane_tty" ]; then
  printf '\033]52;c;%s\007' "$encoded" >"$pane_tty" 2>/dev/null
fi
