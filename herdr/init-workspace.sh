#!/bin/sh
# init-workspace.sh — ensure dev / lab tabs exist in a workspace
# HERDR_ACTIVE_WORKSPACE_ID must be set to the target workspace

# env is only set when hdr() invokes us; from a keybinding it's missing, so fall
# back to the focused pane reported by the server (authoritative cwd).
CWD="${HERDR_ACTIVE_PANE_CWD:-}"
WS="${HERDR_ACTIVE_WORKSPACE_ID:-}"

if [ -z "$CWD" ] || [ -z "$WS" ]; then
  FOCUSED=$(herdr pane list 2>/dev/null | python3 -c "
import sys, json
panes = json.load(sys.stdin)['result']['panes']
p = next((p for p in panes if p.get('focused')), None)
print(f\"{p['workspace_id']}\t{p.get('cwd') or ''}\" if p else '')
")
  [ -z "$WS" ]  && WS=$(printf '%s' "$FOCUSED" | cut -f1)
  [ -z "$CWD" ] && CWD=$(printf '%s' "$FOCUSED" | cut -f2)
fi

CWD="${CWD:-$HOME}"

if [ -z "$WS" ]; then
  echo "init-workspace: cannot resolve workspace" >&2
  exit 1
fi

WS_FLAG="--workspace $WS"

existing_labels() {
  herdr tab list $WS_FLAG 2>/dev/null | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
for t in data['result']['tabs']:
    print(t.get('label', ''))
"
}

has_tab() {
  existing_labels | grep -qx "$1"
}

# remember default "1" tab to close later
DEFAULT_TAB=$(herdr tab list $WS_FLAG 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
match = next((t for t in data['result']['tabs'] if t.get('label') == '1'), None)
print(match['tab_id'] if match else '')
")

# dev
if ! has_tab "dev"; then
  DEV=$(herdr tab create $WS_FLAG --label "dev" --cwd "$CWD")
  DEV_PANE=$(echo "$DEV" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['root_pane']['pane_id'])")
  herdr pane run "$DEV_PANE" "nvim ." >/dev/null
fi

# lab
if ! has_tab "lab"; then
  herdr tab create $WS_FLAG --label "lab" --cwd "$CWD" >/dev/null
fi

# close default "1" tab
[ -n "$DEFAULT_TAB" ] && herdr tab close "$DEFAULT_TAB" >/dev/null

# focus dev
DEV_TAB=$(herdr tab list $WS_FLAG 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
match = next((t for t in data['result']['tabs'] if t.get('label') == 'dev'), None)
print(match['tab_id'] if match else '')
")
[ -n "$DEV_TAB" ] && herdr tab focus "$DEV_TAB" >/dev/null

# force a relayout so panes pick up the real terminal size instead of the
# [server] headless_rows/cols defaults. no-op when no client is attached.
# ponytail: zoom jiggle, drop it if herdr resizes panes on attach.
herdr pane zoom --current --toggle >/dev/null 2>&1
herdr pane zoom --current --toggle >/dev/null 2>&1
