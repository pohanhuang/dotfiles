#!/bin/bash

# Get current directory name for session-specific scratchpad
current_dir="$(tmux display-message -p '#{pane_current_path}')"
dir_name="$(basename "$current_dir")"

# Define session name for scratchpad (per-directory)
session="_popup_scratchpad_${dir_name}"

# Create session if it doesn't exist
if ! tmux has -t "$session" 2>/dev/null; then
	session_id="$(tmux new-session -dP -s "$session" -c "$current_dir" -F '#{session_id}')"
	tmux set-option -t "$session_id" status off          # Hide status bar
	tmux set-option -t "$session_id" mouse on            # Enable mouse in popup
	session="$session_id"
fi

# Attach to the scratchpad session inside the popup
# Set key-table to popup for this client to enable Esc/Ctrl-d to close
exec tmux attach -t "$session" \; set-option -t "$session" key-table popup >/dev/null 2>&1
