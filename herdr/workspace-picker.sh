#!/bin/sh
# workspace-picker.sh — fzf popup workspace switcher (ctrl-x closes a workspace)

list() {
  herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
rows = []
for w in data['result']['workspaces']:
    ws_id   = w['workspace_id']
    label   = w.get('label') or ws_id
    focused = w.get('focused', False)
    suffix  = '  (current)' if focused else ''
    rows.append((0 if focused else 1, ws_id, f'{label}{suffix}'))
rows.sort(key=lambda r: r[0])
for _, ws_id, display in rows:
    print(f'{ws_id}\t{display}')
"
}

# --bind reload re-runs this script with 'list' so the rows regenerate in-place
[ "$1" = "list" ] && { list; exit 0; }

selected=$(list | fzf --delimiter='\t' --with-nth=2 --prompt="workspace > " --height=40% \
  --header='enter: focus   ctrl-x: close' \
  --bind "ctrl-x:execute-silent(herdr workspace close {1})+reload($0 list)")

[ -z "$selected" ] && exit 0

herdr workspace focus "$(printf '%s' "$selected" | cut -f1)"
