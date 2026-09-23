---
name: work-sync
description: >
  At the end of a session, summarize what was done and what's pending, then
  write a dated report to ~/logbook/journals/YYYY-MM-DD/hostname.md and push to git.
  Trigger: "done", "bye", "wrap up", "結束", "today's summary", "sync diary",
  "push diary", "work sync". Optionally accepts a date (YYYY-MM-DD) to backfill a past day.
argument-hint: "[YYYY-MM-DD]"
---

# Work Sync

Summarize the session and sync a daily report to the logbook git repo.

## Steps

1. **Review the session** — look back at what was discussed and accomplished.

2. **Classify each item** into one of:
   - `[done]` — completed this session
   - `[ ]` — still pending / follow-up needed
   - `[blocked]` — waiting on something external

3. **Format entries** — group all sessions by the base folder of their workspace:
   ```
   # project-name
   - [done] <what was completed>
   - [ ] <what still needs doing>
   - [blocked] <what's blocked and why>
   ```

4. **Determine the target date** — if a date argument was passed (e.g. `work sync 2026-09-23`), use it; otherwise use today (`date +%Y-%m-%d`).

5. **Write the daily report** — replace `~/logbook/journals/<DATE>/$(hostname -s).md` with those project sections.

6. **Push to git**:
   ```bash
   DATE=<resolved-date>
   cd ~/logbook && mkdir -p journals/$DATE && git add journals/$DATE/$(hostname -s).md && git commit -m "work diary $DATE $(hostname -s)" && git push
   ```

## Rules

- Replace only the target date's report for this machine; never touch other machines' files.
- Keep entries short — one line, actionable.
- The repo is always `~/logbook`.
- Group by project if multiple projects were discussed (e.g., `neuvector:`, `harvester:`).
