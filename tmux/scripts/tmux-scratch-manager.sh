#!/bin/bash

# Tmux Scratch Pad Manager
# Usage: tmux-scratch-manager.sh [list|clean|kill <session-name>]

case "${1:-list}" in
  list)
    echo "=== Active Scratch Pads ==="
    tmux list-sessions 2>/dev/null | grep "_popup" | while read -r line; do
      session_name=$(echo "$line" | cut -d: -f1)

      # Determine type
      if [[ "$session_name" =~ _popup_ai_ ]]; then
        type="🤖 AI"
      elif [[ "$session_name" =~ _popup_system_ ]]; then
        type="⚙️  SYSTEM"
      elif [[ "$session_name" =~ _popup_scratchpad_ ]]; then
        type="📝 GENERAL"
      else
        type="❓ OTHER"
      fi

      # Extract directory name
      dir_name=$(echo "$session_name" | sed 's/_popup_[^_]*_//')

      echo "$type | $dir_name | $session_name"
    done
    echo ""
    echo "Commands:"
    echo "  tmux-scratch-manager.sh list          # List all scratch pads"
    echo "  tmux-scratch-manager.sh clean         # Kill all scratch pads"
    echo "  tmux-scratch-manager.sh kill <name>   # Kill specific scratch pad"
    ;;

  clean)
    echo "Cleaning all scratch pad sessions..."
    count=0
    tmux list-sessions 2>/dev/null | grep "_popup" | cut -d: -f1 | while read -r session; do
      tmux kill-session -t "$session" 2>/dev/null && echo "  ✓ Killed: $session"
      count=$((count + 1))
    done
    echo "Done! Cleaned $count scratch pad sessions."
    ;;

  kill)
    if [ -z "$2" ]; then
      echo "Error: Please specify session name"
      echo "Usage: tmux-scratch-manager.sh kill <session-name>"
      exit 1
    fi
    tmux kill-session -t "$2" 2>/dev/null && echo "✓ Killed: $2" || echo "✗ Session not found: $2"
    ;;

  *)
    echo "Unknown command: $1"
    echo "Usage: tmux-scratch-manager.sh [list|clean|kill <session-name>]"
    exit 1
    ;;
esac
