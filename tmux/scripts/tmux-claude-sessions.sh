#!/bin/bash

# List all Claude sessions with fzf and optionally cd to their directory
claude agents --json | jq -r '.[] | "\(.name)\t\(.status)\t\(.cwd)"' |
  column -t -s $'\t' |
  fzf --reverse \
      --border-label " Claude Sessions " \
      --header "Enter: cd to session dir | Esc: cancel" \
      --prompt "🤖 " \
      --preview 'echo {} | awk "{print \$NF}" | xargs -I{} sh -c "echo \"Directory: {}\n\" && ls -lh {}"' \
      --preview-window 'right:50%' |
  awk '{print $NF}' |
  xargs -I{} tmux send-keys "cd {}" C-m
