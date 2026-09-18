#!/bin/sh
# focus-tab.sh <label> [--create]
# Focus the tab with <label> in the CURRENT workspace. With --create, create it
# (at the focused pane's cwd) when missing.
#
# Scopes to the focused pane from `herdr pane list` because keybinding commands
# don't get HERDR_ACTIVE_* env — without this, an unscoped `herdr tab list`
# matches the first workspace's tab and focuses the wrong workspace.

LABEL="$1"
[ -z "$LABEL" ] && { echo "usage: focus-tab.sh <label> [--create]" >&2; exit 1; }
CREATE="$2"

herdr pane list 2>/dev/null | python3 -c "
import sys, json, os, subprocess

label, create = '$LABEL', '$CREATE' == '--create'
panes = json.load(sys.stdin)['result']['panes']
p = next((p for p in panes if p.get('focused')), None)
if not p:
    sys.exit('focus-tab: no focused pane')

ws  = p['workspace_id']
cwd = os.environ.get('HERDR_ACTIVE_PANE_CWD') or p.get('cwd') or os.path.expanduser('~')

tabs = json.loads(subprocess.check_output(['herdr', 'tab', 'list', '--workspace', ws], text=True))['result']['tabs']
m = next((t for t in tabs if t.get('label') == label), None)

if m:
    subprocess.run(['herdr', 'tab', 'focus', m['tab_id']])
elif create:
    subprocess.run(['herdr', 'tab', 'create', '--workspace', ws, '--label', label, '--cwd', cwd, '--focus'])
"
