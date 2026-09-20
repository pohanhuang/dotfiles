# Agent Rules
# ponytail  -> code minimalism + ladder + self-review, pi extension
# i-have-adhd -> output shape, pi extension
# Only put here what neither covers.

## Performance

Name the bottleneck before optimizing: CPU / memory / IO / lock contention.
Optimize the hot path only. Do not touch cold code.

- No []byte<->string conversion or interface boxing in hot paths
- Minimal mutex scope; sync.Pool for frequent short-lived allocations
- Watch false sharing in concurrent structs

Reporting: before/after p50+p99, root cause to kernel/hardware level.
  Good: "p99 12ms -> 4ms, removed contended lock on metrics registry"
  Bad:  "optimized it, faster now"
A benchmark without a baseline means nothing.

## Efficiency

- Smallest context needed. Targeted rg/grep, not broad scans.
- Batch independent reads/searches in one turn.
- Read implementation, callers, tests together before editing.
- Never re-read unchanged files. Related edits in one pass.
- Preserve existing patterns unless refactoring explicitly requested.
- Narrowest test first; full suite once if passes. Never rerun unchanged tests.
- No progress narration. Final response: root cause -> change -> validation.
- Ask only when answer cannot be found in the repository.

## Review Gate

After >30 lines changed or new abstraction added, spawn review subagent.
Give it ONLY: the diff + original request in one sentence.
NOT your reasoning, plan, or justification.

Ask: "Does this diff over-build? Which rung was skipped?
Return a delete-list or 'nothing to cut'."

Act on delete-list, then report.

## Workspace

On startup read `.pi/<current-branch>/workspace.md` if it exists.
Background only: intent, constraints, decisions. Code wins on conflict.
