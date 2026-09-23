---
name: work-sync
description: >
  At the end of a session, summarize what was done and what's pending, then
  write a dated report to ~/logbook/journals/YYYY-MM-DD.md and push to git.
  Trigger: "done", "bye", "wrap up", "結束", "today's summary", "sync diary",
  "push diary", "work sync".
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

4. **Write the daily report** — replace `~/logbook/journals/YYYY-MM-DD.md` with those project sections.

5. **Push to git**:
   ```bash
   cd ~/logbook && git add journals/$(date +%Y-%m-%d).md && git commit -m "work diary $(date +%Y-%m-%d)" && git push
   ```

## Rules

- Replace only today's report; never modify a prior date.
- Keep entries short — one line, actionable.
- The repo is always `~/logbook`.
- Group by project if multiple projects were discussed (e.g., `neuvector:`, `harvester:`).
