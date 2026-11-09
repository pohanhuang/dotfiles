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

## File references

When mentioning, modifying, or recommending an existing local file, include a
separate **File references** section at the end of the response. Each reference
must be on its own plain-text line in this exact format:

```text
relative/path/to/file:line
relative/path/to/file:line:column
```

- Paths are relative to this project root.
- Verify references before replying and include the line number whenever it is
  known.
- Do not use absolute paths, Markdown links, or prose in the reference line.
- This format is consumed by a Neovim terminal Ctrl+click mapping.
