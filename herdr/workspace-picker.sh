#!/bin/sh
# workspace-picker.sh — fzf popup: workspaces + zoxide + filesystem nav
# Type ../ (or any path) in the prompt to browse directories.
# ctrl-x: close a workspace   enter: focus/create

CANDS="$HOME/.config/herdr/candidates.sh"

selected=$(
  "$CANDS" "" | \
  fzf \
    --delimiter='\t' \
    --with-nth=3 \
    --prompt="workspace > " \
    --height=100% \
    --header='enter: focus/open   tab: drill in   ctrl-x: close' \
    --bind "change:reload($CANDS '{q}')" \
    --bind "tab:transform($HOME/.config/herdr/tab-action.sh {1} {2})+clear-selection" \
    --bind "ctrl-x:execute-silent(herdr workspace close {2})+reload($CANDS '{q}')"
)

[ -z "$selected" ] && exit 0

type=$(printf '%s' "$selected" | cut -f1)
id=$(printf '%s' "$selected" | cut -f2)

case "$type" in
  W)
    herdr workspace focus "$id"
    ;;
  D|Z)
    cwd=$(cd "$id" 2>/dev/null && pwd)
    [ -z "$cwd" ] && exit 1

    # Mirrors hd(): match on cwd via lowest-numbered pane per workspace
    found=$(herdr pane list 2>/dev/null | python3 -c "
import sys, json, os
target = '$cwd'
panes  = json.load(sys.stdin)['result']['panes']
ws_cwd = {}
for p in sorted(panes, key=lambda p: p['pane_id']):
    ws_cwd.setdefault(p['workspace_id'], p.get('cwd') or '')
match = next((ws for ws, c in ws_cwd.items() if c == target), '')
label  = os.path.basename(target)
taken  = {c: ws for ws, c in ws_cwd.items()}
if not match and any(os.path.basename(c) == label for c in taken):
    parent = os.path.basename(os.path.dirname(target))
    label  = f'{parent}/{label}' if parent else label
print(f'{match}\t{label}')
")
    existing=$(printf '%s' "$found" | cut -f1)
    label=$(printf '%s' "$found" | cut -f2)
    [ -z "$label" ] && label=$(basename "$cwd")

    if [ -n "$existing" ]; then
      herdr workspace focus "$existing"
      HERDR_ACTIVE_PANE_CWD="$cwd" HERDR_ACTIVE_WORKSPACE_ID="$existing" \
        ~/.config/herdr/init-workspace.sh
    else
      result=$(herdr workspace create --cwd "$cwd" --label "$label")
      ws_id=$(printf '%s' "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['workspace']['workspace_id'])")
      pane_id=$(printf '%s' "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['root_pane']['pane_id'])")
      HERDR_ACTIVE_WORKSPACE_ID="$ws_id" HERDR_ACTIVE_PANE_CWD="$cwd" HERDR_ACTIVE_PANE_ID="$pane_id" \
        ~/.config/herdr/init-workspace.sh
    fi
    ;;
esac
