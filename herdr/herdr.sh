# herdr shell helpers — source in ~/.zshrc

# hkill — close all workspaces
hkill() {
  herdr workspace list 2>/dev/null | python3 -c "
import sys, json, subprocess
for w in json.load(sys.stdin)['result']['workspaces']:
    subprocess.run(['herdr', 'workspace', 'close', w['workspace_id']], stdout=subprocess.DEVNULL)
    print('closed:', w.get('label') or w['workspace_id'])
"
}

# ensure server is running, start headless if not
_herdr_ensure_server() {
  herdr workspace list >/dev/null 2>&1 && return 0
  echo "herdr: starting server..."
  # a headless server spawns panes at [server] headless_cols/rows (120x40 by
  # default), so seed that fallback with this terminal's real size.
  # ponytail: appends to a config copy; drop it if config.toml grows a [server] table.
  local cfg="${TMPDIR:-/tmp}/herdr-server-config.toml"
  { cat ~/.config/herdr/config.toml
    printf '\n[server]\nheadless_cols = %s\nheadless_rows = %s\n' "$(tput cols)" "$(tput lines)"
  } > "$cfg" 2>/dev/null
  HERDR_CONFIG_PATH="$cfg" nohup herdr server >/dev/null 2>&1 &
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
    herdr workspace focus "$id" >/dev/null
    herdr
  else
    hd "$id"
  fi
}

# hd [path] — open or create workspace at path
hd() {
  _herdr_ensure_server || return 1

  local cwd label existing found result id pane_id

  cwd=$(cd "${1:-.}" 2>/dev/null && pwd)
  if [ -z "$cwd" ]; then
    echo "herdr: path not found: $1"
    return 1
  fi

  # Match on cwd, not basename: ~/a/harvester and ~/b/harvester are different
  # workspaces. Also pick a non-colliding label for the sidebar/pickers.
  # ponytail: a workspace's cwd is its lowest-numbered pane's cwd; good enough
  # unless you start splitting root panes into unrelated directories.
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
    echo "herdr: attaching '$label'"
    herdr workspace focus "$existing" >/dev/null
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
