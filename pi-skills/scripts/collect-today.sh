#!/usr/bin/env bash
# Read all pi sessions from today, summarize work, and push a daily diary to ~/logbook.

set -euo pipefail

LOGBOOK="${LOGBOOK:-$HOME/logbook}"
TODAY=$(date +%Y-%m-%d)
SESSION_DIR="$HOME/.pi/agent/sessions"
DIARY="$LOGBOOK/journals/$TODAY.md"
TMPFILE=$(mktemp)

cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT

# extract user + assistant text from today's sessions
find "$SESSION_DIR" -name "${TODAY}*.jsonl" | sort | while read -r f; do
  python3 - "$f" <<'EOF'
import sys, json
from pathlib import Path

session = [json.loads(line) for line in open(sys.argv[1])]
cwd = next((event.get("cwd") for event in session if event.get("type") == "session"), "unknown")
print(f"\n=== PROJECT: {Path(cwd).name} ({cwd}) ===")

for ev in session:
    if ev.get("type") != "message":
        continue
    msg = ev.get("message", {})
    role = msg.get("role", "")
    content = msg.get("content", "")
    if isinstance(content, list):
        content = " ".join(
            p.get("text", "") for p in content
            if isinstance(p, dict) and p.get("type") == "text"
        )
    content = content.strip()
    if content and role in ("user", "assistant"):
        print(f"[{role}]: {content[:500]}")
EOF
done > "$TMPFILE"

if [ ! -s "$TMPFILE" ]; then
  echo "No sessions found for $TODAY — nothing to sync."
  exit 0
fi

echo "Summarizing $(wc -l < "$TMPFILE") lines from today's sessions..."

PROMPT="Below are today's pi session messages. Summarize what was actually done and what is still pending.
Output ONLY Markdown project sections, nothing else. The format is:
# <base folder name from the PROJECT header>
- [done] <what was completed>
- [ ] <what still needs doing>
- [blocked] <what is blocked and why>

The PROJECT header is authoritative. Merge sessions with the same base folder into one section. Keep each line short and actionable.

--- sessions ---
$(cat "$TMPFILE")"

SUMMARY=$(pi --print --no-session "$PROMPT" 2>/dev/null)

if [ -z "$SUMMARY" ]; then
  echo "pi summarization failed — check pi auth."
  exit 1
fi

# Replace today's report so repeated runs do not duplicate entries.
mkdir -p "$(dirname "$DIARY")"
printf "%s\n" "$SUMMARY" > "$DIARY"
echo "Written to $DIARY"

if [ -d "$LOGBOOK/.git" ]; then
  cd "$LOGBOOK"
  git add "journals/$TODAY.md"
  git diff --cached --quiet || { git commit -m "work diary $TODAY" && git push && echo "Pushed."; }
fi
