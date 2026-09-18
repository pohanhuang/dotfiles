# herdr shell helpers — source in ~/.zshrc

# hkill — close all workspaces
hkill() {
  herdr workspace list 2>/dev/null | python3 -c "
import sys, json, subprocess
for w in json.load(sys.stdin)['result']['workspaces']:
    subprocess.run(['herdr', 'workspace', 'close', w['workspace_id']])
    print('closed:', w.get('label') or w['workspace_id'])
"
}

# ensure server is running, start headless if not
_herdr_ensure_server() {
  herdr workspace list >/dev/null 2>&1 && return 0
  echo "herdr: starting server..."
  nohup herdr server >/dev/null 2>&1 &
  local i=0
  while [ $i -lt 30 ]; do
    sleep 0.2
    herdr workspace list >/dev/null 2>&1 && return 0
    i=$((i+1))
  done
  echo "herdr: server failed to start"
  return 1
}

# ha — fuzzy pick: running workspaces + zoxide dirs
ha() {
  _herdr_ensure_server || return 1

  local tmp selected type id
  tmp=$(mktemp)

  # running workspaces
  herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for w in data['result']['workspaces']:
    label = w.get('label') or w['workspace_id']
    print(f\"W\t{w['workspace_id']}\t⬡  {label}\")
" >> "$tmp"

  # recent dirs from zoxide
  zoxide query --list 2>/dev/null | while read -r p; do
    printf "Z\t%s\t   %s\n" "$p" "$p"
  done >> "$tmp"

  if [ ! -s "$tmp" ]; then
    echo "herdr: nothing found"
    rm -f "$tmp"
    return 1
  fi

  selected=$(fzf --delimiter='\t' --with-nth=3 --prompt="❯ " --ansi < "$tmp")
  rm -f "$tmp"
  [ -z "$selected" ] && return

  type=$(printf '%s' "$selected" | cut -f1)
  id=$(printf '%s' "$selected" | cut -f2)

  if [ "$type" = "W" ]; then
    herdr workspace focus "$id"
    herdr
  else
    hd "$id"
  fi
}

# hd [path] — open or create workspace at path
hd() {
  _herdr_ensure_server || return 1

  local cwd label existing result id pane_id

  cwd=$(cd "${1:-.}" 2>/dev/null && pwd)
  if [ -z "$cwd" ]; then
    echo "herdr: path not found: $1"
    return 1
  fi

  label=$(basename "$cwd")

  # check if workspace with this label already exists
  existing=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
match = next((w for w in data['result']['workspaces'] if w.get('label') == '$label'), None)
print(match['workspace_id'] if match else '')
")

  if [ -n "$existing" ]; then
    echo "herdr: attaching '$label'"
    herdr workspace focus "$existing"
    # open missing tabs (nvim / pi / terminal)
    HERDR_ACTIVE_PANE_CWD="$cwd" HERDR_ACTIVE_WORKSPACE_ID="$existing" \
      ~/.config/herdr/init-workspace.sh
  else
    echo "herdr: creating '$label' at $cwd"
    result=$(herdr workspace create --cwd "$cwd" --label "$label")
    id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['workspace']['workspace_id'])")
    pane_id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['root_pane']['pane_id'])")
    HERDR_ACTIVE_WORKSPACE_ID="$id" HERDR_ACTIVE_PANE_CWD="$cwd" HERDR_ACTIVE_PANE_ID="$pane_id" \
      ~/.config/herdr/init-workspace.sh
  fi

  # don't nest herdr if already inside it
  [ -z "$HERDR_ACTIVE_WORKSPACE_ID" ] && herdr
}
