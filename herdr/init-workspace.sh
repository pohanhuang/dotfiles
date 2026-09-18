#!/bin/sh
# init-workspace.sh — ensure nvim / pi / terminal tabs exist in a workspace
# HERDR_ACTIVE_WORKSPACE_ID must be set to the target workspace

# env is only set when hd() invokes us; from a keybinding it's missing, so fall
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

# nvim
if ! has_tab "nvim"; then
  NVIM=$(herdr tab create $WS_FLAG --label "nvim" --cwd "$CWD")
  NVIM_PANE=$(echo "$NVIM" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['root_pane']['pane_id'])")
  herdr pane run "$NVIM_PANE" "nvim ." >/dev/null
fi

# pi
if ! has_tab "pi"; then
  PI=$(herdr tab create $WS_FLAG --label "pi" --cwd "$CWD")
  PI_PANE=$(echo "$PI" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['root_pane']['pane_id'])")
  herdr pane run "$PI_PANE" "pi" >/dev/null
fi

# terminal
if ! has_tab "terminal"; then
  herdr tab create $WS_FLAG --label "terminal" --cwd "$CWD" >/dev/null
fi

# deployment
if ! has_tab "deployment"; then
  herdr tab create $WS_FLAG --label "deployment" --cwd "$CWD" >/dev/null
fi

# close default "1" tab
[ -n "$DEFAULT_TAB" ] && herdr tab close "$DEFAULT_TAB" >/dev/null

# focus nvim
NVIM_TAB=$(herdr tab list $WS_FLAG 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
match = next((t for t in data['result']['tabs'] if t.get('label') == 'nvim'), None)
print(match['tab_id'] if match else '')
")
[ -n "$NVIM_TAB" ] && herdr tab focus "$NVIM_TAB" >/dev/null

# force a relayout so panes pick up the real terminal size instead of the
# [server] headless_rows/cols defaults. no-op when no client is attached.
# ponytail: zoom jiggle, drop it if herdr resizes panes on attach.
herdr pane zoom --current --toggle >/dev/null 2>&1
herdr pane zoom --current --toggle >/dev/null 2>&1
