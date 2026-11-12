# Agent Rules

# ponytail  -> code minimalism + ladder + self-review, pi extension

# i-have-adhd -> output shape, pi extension

# Only put here what neither covers

## Efficiency

- Smallest context needed. Targeted rg/grep, not broad scans.
- Batch independent reads/searches in one turn.
- Read implementation, callers, tests together before editing.
- Never re-read unchanged files. Related edits in one pass.
- Preserve existing patterns unless refactoring explicitly requested.
- Narrowest test first; full suite once if passes. Never rerun unchanged tests.
- No progress narration. Final response: root cause -> change -> validation.
- Ask only when answer cannot be found in the repository.

## Workspace

On startup read `.pi/<current-branch>/workspace.md` if it exists.
Background only: intent, constraints, decisions. Code wins on conflict.

## Code references

When mentioning any code reference, append inline after the mention, use the absolute path:
`/absolute/path/to/file:line`

Example: the entrypoint (`/home/po/harvester/harvester-dev/cmd/main.go:12`) initializes the router.:> [!WARNING]
