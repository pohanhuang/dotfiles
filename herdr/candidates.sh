#!/bin/sh
# candidates.sh — fzf candidate generator for workspace-picker
# Output: TYPE\tID\tDISPLAY
# TYPE: W=workspace, Z=zoxide dir, D=filesystem dir
#
# If query looks like a path (contains / or is ..) → list subdirs of that path.
# Otherwise → workspaces (sorted: current first) + zoxide history.

query="${1:-}"

_is_path() {
  case "$1" in
    "~" | .. | ../ | ./* | ../* | /* | ~/* | */*) return 0 ;;
    *) return 1 ;;
  esac
}

if _is_path "$query"; then
  raw="${query%/}"   # typed prefix, used in display (e.g. ~ or ../foo)
  [ -z "$raw" ] && raw="."
  base=$(eval echo "$raw")  # expand ~ and relative paths to absolute
  # If mid-typing a subdir name (e.g. ~/harv), fall back to parent so
  # fzf can fuzzy-filter the parent's listing instead of showing nothing.
  if [ ! -d "$base" ]; then
    base=$(dirname "$base")
    raw=$(dirname "$raw")
  fi
  find "$base" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | \
    while read -r p; do
      display="$raw/$(basename "$p")"
      # col4 = typed-style path used by tab-complete in workspace-picker
      printf "D\t%s\t📁 %s\t%s\n" "$p" "$display" "$display"
    done
else
  # workspaces — current first
  herdr workspace list 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
rows = []
for w in data['result']['workspaces']:
    ws_id   = w['workspace_id']
    label   = w.get('label') or ws_id
    focused = w.get('focused', False)
    suffix  = '  ◀' if focused else ''
    rows.append((0 if focused else 1, ws_id, f'⬡  {label}{suffix}'))
rows.sort(key=lambda r: r[0])
for _, ws_id, display in rows:
    print(f'W\t{ws_id}\t{display}\t')
" 2>/dev/null
  # zoxide history
  zoxide query --list 2>/dev/null | while read -r p; do
    printf "Z\t%s\t   %s\t%s\n" "$p" "$p" "$p"
  done
fi
