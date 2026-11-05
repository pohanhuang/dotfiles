# AGENTS.md

Harvester test repo: pytest (`harvester_e2e_tests/`) and Robot Framework
(`harvester_robot_tests/`, see its README). New tests go in Robot Framework.

## Default Task: Robot Tests for a Harvester Branch

The source repo is `~/harvester/harvester/` (SRC). This repo is the test repo (TEST).

When invoked with no other instruction, or asked to "write tests", run steps 1-7 in order
without asking for confirmation between them. Stop only on a **STOP** condition and report why.

### 1. Resolve the branch

# AGENTS.md

Harvester test repo: pytest (`harvester_e2e_tests/`) and Robot Framework
(`harvester_robot_tests/`, see its README). New tests go in Robot Framework.

## Default Task: Robot Tests for a Harvester Branch

The source repo is `~/harvester/harvester/` (SRC). This repo is the test repo (TEST).

When invoked with no other instruction, or asked to "write tests", run steps 1-7 in order
without asking for confirmation between them. Stop only on a **STOP** condition and report why.

### 1. Resolve the branch

```bash
SRC=~/harvester/harvester
BRANCH=$(git -C "$SRC" branch --show-current)
```

- **STOP** if `BRANCH` is empty (detached HEAD) or is `master` / `main` / `release-*`.
  There is nothing to mirror; never guess a branch name.

### 2. Prepare TEST

Switch the TEST repo to the same branch as SRC (`$BRANCH`).

```bash
git status --porcelain     # STOP if not empty: never stash, reset or discard user changes
git fetch origin
git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/HEAD
```

- **The TEST branch must match `$BRANCH` exactly.** Never run tests on a different branch.
- If `origin/HEAD` is missing, run `git remote set-head origin -a` once.

### 3. Collect the change set (branch commits only)

Diff against the upstream Harvester remote, not a fork, or the base will be stale.

```bash
UP=$(git -C "$SRC" remote -v \
  | awk '/github.com[:\/]harvester\/harvester(\.git)? \(fetch\)/ {print $1; exit}')
git -C "$SRC" fetch "$UP" master
BASE=$(git -C "$SRC" merge-base HEAD "$UP/master")

git -C "$SRC" log --oneline "$BASE"..HEAD
git -C "$SRC" diff --stat "$BASE"..HEAD -- . \
  ':!vendor' ':!pkg/generated' ':!go.mod' ':!go.sum' ':!**/zz_generated*'
git -C "$SRC" show <sha>   # per commit, to read intent from the message and diff
```

- Always use `$BASE..HEAD`. A fixed `git log -N` pulls in unrelated master history.
- **STOP** if `$BASE..HEAD` is empty.
- Skip as test targets: vendor, generated code and CRDs, dependency bumps, docs, CI files.
- Do read the `*_test.go` changes: they show the expected behavior and edge cases.
- If `git -C "$SRC" status --porcelain` is not empty, ignore uncommitted SRC work and
  mention it in the report.

### 4. Plan: map changes to test targets

For each behavior change, find the surface and how to observe it on a live cluster:

| Change in SRC                          | Test by                                                        |
|----------------------------------------|----------------------------------------------------------------|
| `pkg/webhook/**` validator / mutator   | create/update the resource; assert accepted vs rejected and the error message |
| `pkg/controller/**`                    | create the trigger resource; wait for the status, condition or side effect |
| `pkg/api/**`, new route                | call the endpoint; assert status code and body                 |
| `pkg/settings`, new setting            | update the setting; assert the effect; restore it in teardown  |
| `deploy/charts/**` values / templates  | assert resources exist or are absent on the cluster            |

- Behavior that only runs at install time, or that lives in another repo (for example
  `harvester-installer`), cannot be tested here. Do not fake it. List it as uncovered.
- Before writing code, write a short plan: test case name → asserted behavior → commit sha.
- Cover the happy path plus every new validation or error branch in the diff.

### 5. Write tests, one layer at a time

Bottom-up: `libs/<component>/*.py` → `libs/keywords/*_keywords.py` →
`keywords/*.resource` → `tests/**/*.robot`.

- Search `harvester_robot_tests/libs/` and `keywords/` for an existing component and keyword
  before adding new ones. Extend; do not duplicate.
- Follow the Robot Framework rules below.

### 6. Validate

```bash
cd harvester_robot_tests && source venv/bin/activate
robot --dryrun tests/<path>/<suite>.robot
cd .. && tox -e pep8
```

- Fix until both pass. Never report done with a failing dry-run or lint.

### 7. Report

- Branch, `BASE` sha, and the `$BASE..HEAD` commit list
- Coverage map: commit sha → test case(s)
- Files created or modified, grouped by layer
- Uncovered behavior, with the reason for each
- A note that tests were dry-run only and not executed against a cluster

Do not commit or push unless asked.

## Python

- flake8, max line length 99 (`tox.ini`). CI runs `tox -e pep8` on the whole repo,
  including `harvester_robot_tests/libs/`.

## Robot Framework

- Layers, never skip one: `tests/**/*.robot` → `keywords/*.resource` →
  `libs/keywords/*_keywords.py` → `libs/<component>/*.py`.
- A `.robot` file holds only its test cases and its local suite setup/teardown
  (incl. `Delete Suite Resources`). All other keywords belong in `keywords/*.resource`
  (review rule, PR #2949).
- Suite teardown deletes only the suite's own resources, never the global
  `Cleanup test resources` (breaks parallel runs under pabot).
- Use `Generate Unique Name` for every resource name.
- Test cases are independent: no ordering between cases, no shared state that a case
  does not create itself.
- Any cluster setting a test changes is restored in teardown.
- Verify without a cluster: `robot --dryrun <suite>` from `harvester_robot_tests/`
  (use its `venv`).

## Scope

Cover only what `$BASE..HEAD` in SRC changed. Do not add tests for unrelated behavior and do not
refactor existing tests unless a change in the branch requires it.
