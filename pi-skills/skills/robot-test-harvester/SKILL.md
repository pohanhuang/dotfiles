---
name: robot-test-harvester
description: >
  Use when asked to write tests, "write robot tests", or "test this branch" for
  Harvester. Covers reading a source branch diff, mapping changes to Robot Framework
  test targets, writing tests bottom-up across libs/keywords/tests layers,
  dry-run validation, and producing a coverage report.
---

# Robot Test — Harvester

Write Robot Framework tests for a Harvester source branch. Run all 7 steps in
order without asking for confirmation. Stop only on a **STOP** condition.

**If invoked with no message, run all 7 steps immediately without waiting for input.**

- SRC repo: `~/harvester/harvester/`
- TEST repo: the current repo (Harvester test repo)
- New tests always go in Robot Framework (`harvester_robot_tests/`), not pytest.

## Step 1 — Resolve the branch

```bash
SRC=~/harvester/harvester
BRANCH=$(git -C "$SRC" branch --show-current)
```

**STOP** if `BRANCH` is empty (detached HEAD) or is `master` / `main` / `release-*`.

## Step 2 — Prepare TEST repo

```bash
git status --porcelain     # STOP if any tracked changes (M, A, D, R, C) — never stash/reset/discard
                           # Untracked files (??) are safe — checkout leaves them alone
git fetch origin

CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "$BRANCH" ]; then
  git checkout "$BRANCH" 2>/dev/null \
    || git checkout -b "$BRANCH" "origin/$BRANCH" 2>/dev/null \
    || git checkout -b "$BRANCH" origin/HEAD
fi
```

**TEST branch name must equal `$BRANCH` exactly.** Never run tests on a different branch.
If `origin/HEAD` is missing, run `git remote set-head origin -a` once.

## Step 3 — Collect the change set

```bash
UP=$(git -C "$SRC" remote -v \
  | awk '/github.com[:\/]harvester\/harvester(\.git)? \(fetch\)/ {print $1; exit}')
git -C "$SRC" fetch "$UP" master
BASE=$(git -C "$SRC" merge-base HEAD "$UP/master")

git -C "$SRC" log --oneline "$BASE"..HEAD
git -C "$SRC" diff --stat "$BASE"..HEAD -- . \
  ':!vendor' ':!pkg/generated' ':!go.mod' ':!go.sum' ':!**/zz_generated*'
git -C "$SRC" show <sha>   # per commit
```

**STOP** if `$BASE..HEAD` is empty. Always use `$BASE..HEAD`, never a fixed `-N`.

Skip: vendor, generated code/CRDs, dependency bumps, docs, CI files.
Read `*_test.go` changes — they show expected behavior and edge cases.
If SRC has uncommitted work, ignore it and mention it in the report.

## Step 4 — Plan: map changes to test targets

| Change in SRC | Test by |
|---|---|
| `pkg/webhook/**` | create/update resource; assert accepted vs rejected + error message |
| `pkg/controller/**` | create trigger resource; wait for status/condition/side effect |
| `pkg/api/**` new route | call endpoint; assert status code and body |
| `pkg/settings` new setting | update setting; assert effect; restore in teardown |
| `deploy/charts/**` | assert resources exist or are absent on cluster |

Behavior that only runs at install time or lives in another repo (e.g.
`harvester-installer`) is untestable here — list it as uncovered.

Write a short plan first: test case name → asserted behavior → commit sha.
Cover the happy path plus every new validation or error branch in the diff.

## Step 5 — Write tests, bottom-up

`libs/<component>/*.py` → `libs/keywords/*_keywords.py` →
`keywords/*.resource` → `tests/**/*.robot`

Search existing `libs/` and `keywords/` before adding anything — extend, don't duplicate.

**Robot Framework rules:**
- `.robot` file: only test cases + local suite setup/teardown (`Delete Suite Resources`). All other keywords → `keywords/*.resource`.
- Suite teardown deletes only its own resources. Never call global `Cleanup test resources` (breaks pabot).
- Use `Generate Unique Name` for every resource name.
- Test cases are independent: no ordering, no shared state a case didn't create itself.
- Restore any cluster setting changed by a test in teardown.

**Python:** flake8, max line 99 (`tox.ini`).

## Step 6 — Validate

```bash
cd harvester_robot_tests && source venv/bin/activate
robot --dryrun tests/<path>/<suite>.robot
cd .. && tox -e pep8
```

Fix until both pass. Never report done with a failing dry-run or lint.

## Step 7 — Report

Include:
- Branch, `BASE` sha, `$BASE..HEAD` commit list
- Coverage map: commit sha → test case(s)
- Files created or modified, grouped by layer
- Uncovered behavior with reason
- Note that tests were dry-run only, not executed against a cluster

Do not commit or push unless asked.

## Scope

Cover only what `$BASE..HEAD` changed. Do not add tests for unrelated behavior
or refactor existing tests unless the branch requires it.
