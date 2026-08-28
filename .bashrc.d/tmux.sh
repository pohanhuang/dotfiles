alias ta='tmux a \; choose-session'

# Enhanced tn - create or attach to session based on directory name
tn() {
  local session_name="${1:-$(basename "$PWD")}"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach -t "$session_name"
  else
    tmux new-session -s "$session_name" -c "$PWD"
  fi
}
