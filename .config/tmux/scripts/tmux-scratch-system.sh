#!/bin/bash

# Get current directory name for session-specific scratchpad
current_dir="$(tmux display-message -p '#{pane_current_path}')"
dir_name="$(basename "$current_dir")"

# Define system scratchpad session name (per-directory)
session="_popup_system_${dir_name}"

# Create session if it doesn't exist
if ! tmux has -t "$session" 2>/dev/null; then
	session_id="$(tmux new-session -dP -s "$session" -c "$current_dir" -F '#{session_id}')"
	tmux set-option -t "$session_id" status off          # Hide status bar
	tmux set-option -t "$session_id" mouse on            # Enable mouse in popup

	# Set a welcome message for system pad
	tmux send-keys -t "$session_id" "# System Scratch Pad - $(basename $current_dir)" C-m
	tmux send-keys -t "$session_id" "# Use this for: commands, logs, system notes" C-m
	tmux send-keys -t "$session_id" "" C-m

	session="$session_id"
fi

# Attach to the system scratchpad session inside the popup
# Set key-table to popup for this client to enable Esc/Ctrl-d to close
exec tmux attach -t "$session" \; set-option -t "$session" key-table popup >/dev/null 2>&1
