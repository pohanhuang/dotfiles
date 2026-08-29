#!/usr/bin/env bash

function ta {
  sesh connect "$(sesh list --icons | grep -v '_popup' | fzf \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons | grep -v "_popup")' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons | grep -v "_popup")' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons | grep -v "_popup")' \
    --preview 'sesh preview {}')"
}

# Enhanced tn - create or attach to session based on directory name
function tn {
  local session_name="${1:-$(basename "$PWD")}"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach -t "$session_name"
  else
    tmux new-session -s "$session_name" -c "$PWD"
  fi
}
