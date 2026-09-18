#!/bin/sh
# agent-picker.sh — fzf popup: one row per workspace with a pi agent

selected=$(herdr workspace list 2>/dev/null | python3 -c "
import sys, json, subprocess

ws_data    = json.load(sys.stdin)
workspaces = ws_data['result']['workspaces']

try:
    tab_raw = subprocess.check_output(['herdr', 'tab', 'list'], text=True)
    tabs    = json.loads(tab_raw)['result']['tabs']
except Exception:
    tabs = []

pi_tab = {t['workspace_id']: t['tab_id'] for t in tabs if t.get('label') == 'pi'}

# status indicator: follow herdr style (ANSI colors)
RESET  = '\033[0m'
ind_map = {
    'idle':    '\033[32m○\033[0m',   # green ○
    'working': '\033[93m●\033[0m',  # bright yellow ●
    'blocked': '\033[31m●\033[0m',  # red ●
}
st_map  = {'idle': 'idle', 'working': 'running', 'blocked': 'blocked'}
rows    = []

for w in workspaces:
    status  = w.get('agent_status', 'unknown')
    if status == 'unknown':
        continue
    ws_id   = w['workspace_id']
    label   = w.get('label') or ws_id
    focused = w.get('focused', False)
    ind     = ind_map.get(status, '?')
    st      = st_map.get(status, status)
    suffix  = '  (current)' if focused else ''
    target  = pi_tab.get(ws_id, ws_id)
    rows.append((0 if focused else 1, target, f'{ind}  {label:<16}  [{st}]{suffix}'))

# focused first in stdout → lands at bottom of fzf list (pre-selected)
rows.sort(key=lambda r: r[0])

for _, target, display in rows:
    print(f'{target}\t{display}')
" | fzf --ansi --delimiter='\t' --with-nth=2 --prompt="agent > " --height=40%)

[ -z "$selected" ] && exit 0
herdr tab focus "$(printf '%s' "$selected" | cut -f1)"
