#!/bin/sh
# tab-action.sh TYPE ABSPATH — outputs fzf action for tab-complete in workspace-picker
# W: accept (select workspace)
# D/Z: change-query to abs path + / so reload drills into that dir
type="$1"
abspath="$2"
# Show ~/... instead of /home/po/... so query stays readable
display=$(printf '%s' "$abspath" | sed "s|^$HOME|~|")
[ "$type" = "W" ] && printf 'accept' || printf 'change-query(%s/)' "$display"
