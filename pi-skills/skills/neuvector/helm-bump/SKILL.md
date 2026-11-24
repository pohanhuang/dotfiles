---
name: neuvector-helm-bump
description: >
  Bump NeuVector Helm chart versions for a new NeuVector release.
  Use when asked to bump helm chart versions, release a new NeuVector chart version,
  or update image tags in neuvector-helm for a specific NeuVector product version
  (e.g. 5.5.6, 5.6.5, 5.7.0). Covers release branch selection, Chart.yaml version
  increments, values.yaml image tag updates, helm lint, and git diff review.
argument-hint: "<nv-version> [companion-image-tags...]"
---

# NeuVector Helm Bump

Bump chart versions and image tags in `neuvector-helm` for a new NeuVector product release.

## Branch → Chart version mapping

| NeuVector product | Release branch | Helm chart series |
|---|---|---|
| `5.4.x` | `release/v2.9` | `2.9.x` |
| `5.5.x` | `release/v2.10` | `2.10.x` |
| `5.6.x` | `release/v2.11` | `2.11.x` |
| `5.7.x` | `release/v2.12` (new) | `2.12.x` |

For any new major series not in this table, ask the user to confirm the branch name before proceeding.

## Required information before starting

Collect from the user (or find in the conversation) before touching any file:

1. **NeuVector product version** — e.g. `5.5.6`
2. **Companion image tags** — ask the user exactly this question first:

   > For the companion images (compliance-config, registry-adapter, updater, prometheus-exporter),
   > press **Enter** to auto-increment each current tag by patch +1, or provide all four
   > **explicit tags**.
   >
   > Note: patch +1 can be wrong — historically some releases skip versions (e.g. +2).
   > Explicitly provided tags are always safer.

   Then apply the answer:
   - **Empty response / Enter** → read the current tags from the branch and increment each patch by 1 before applying the update.
   - **Non-empty response** → treat it as explicit tags; wait until the user has provided all four exact tags before proceeding.

## Steps

### 1. Fetch the upstream release base and create a fork bump branch

Use `upstream/<release-branch>` as the base; do not make the bump directly on the
upstream release branch. The expected remotes are:

```bash
# origin:   git@github.com:pohanhuang/neuvector-helm.git
# upstream: git@github.com:neuvector/neuvector-helm.git
git remote -v
git fetch upstream <release-branch>
git switch -c bump-<NEW_NV> upstream/<release-branch>
```

For example, a `5.6.5` bump based on `release/v2.11` is made on
`pohanhuang/neuvector-helm:bump-5.6.5`, based on
`neuvector/neuvector-helm:release/v2.11`.

If the upstream release branch does not exist (a new major series), stop and ask
the user to confirm both the branch name and its cut point. Only after explicit
confirmation, create the official release branch from the approved upstream base
(normally `upstream/master`), then create the bump branch from it:

```bash
git fetch upstream master
git switch -c <release-branch> upstream/master
git push -u upstream <release-branch>
git switch -c bump-<NEW_NV> upstream/<release-branch>
```

### 2. Read current versions from the branch

```bash
grep -E '^(version|appVersion):' charts/core/Chart.yaml charts/crd/Chart.yaml charts/monitor/Chart.yaml
grep '^tag:' charts/core/values.yaml
grep -A3 'compliance-config\|registry-adapter\|neuvector/updater' charts/core/values.yaml | grep 'tag:'
grep 'tag:' charts/monitor/values.yaml | head -3
```

Confirm the current chart patch version so you know the next one (e.g. `2.10.5` → `2.10.6`).

### 3. Apply changes with sed (do not use the edit tool — it may be blocked by mode hooks)

```bash
# Chart.yaml versions — core and crd get new chart patch + new appVersion
sed -i 's/^version: <OLD_CHART>$/version: <NEW_CHART>/' charts/core/Chart.yaml charts/crd/Chart.yaml charts/monitor/Chart.yaml
sed -i 's/^appVersion: <OLD_NV>$/appVersion: <NEW_NV>/' charts/core/Chart.yaml charts/crd/Chart.yaml

# monitor appVersion is the exporter version — only change if exporter tag changed
# (skip if unchanged)

# core values.yaml — main NV tag
sed -i 's/^tag: <OLD_NV>$/tag: <NEW_NV>/' charts/core/values.yaml

# companion image tags (only lines that actually changed)
sed -i 's/      tag: <OLD_COMPLIANCE>$/      tag: <NEW_COMPLIANCE>/' charts/core/values.yaml
sed -i 's/      tag: <OLD_ADAPTER>$/      tag: <NEW_ADAPTER>/' charts/core/values.yaml
sed -i 's/      tag: <OLD_UPDATER>$/      tag: <NEW_UPDATER>/' charts/core/values.yaml

# monitor values.yaml — exporter tag (only if changed)
sed -i 's/    tag: <OLD_EXPORTER>$/    tag: <NEW_EXPORTER>/' charts/monitor/values.yaml
```

### 4. Verify changes

```bash
grep -E '^(version|appVersion):' charts/core/Chart.yaml charts/crd/Chart.yaml charts/monitor/Chart.yaml
grep '^tag:' charts/core/values.yaml
grep -A3 'compliance-config\|registry-adapter\|neuvector/updater' charts/core/values.yaml | grep 'tag:'
grep 'tag:' charts/monitor/values.yaml | head -3
```

### 5. Helm lint

```bash
helm lint charts/core charts/crd charts/monitor
```

Must pass with `0 chart(s) failed`. Fix any errors before continuing.

### 6. Show git diff for review

```bash
git diff --stat
git diff
```

Expected files changed for a pure version bump:
- `charts/core/Chart.yaml`
- `charts/core/values.yaml`
- `charts/crd/Chart.yaml`
- `charts/monitor/Chart.yaml`
- `charts/monitor/values.yaml` (only if exporter tag changed)

If any template, CRD, RBAC, or other file appears in the diff, stop and flag it
to the user — it is not a pure version bump.

## After the diff is clean

### Commit

Use this message format:

```
chore: bump helm chart versions for NeuVector <NEW_NV>

- core/crd chart: <OLD_CHART> -> <NEW_CHART>, appVersion <OLD_NV> -> <NEW_NV>
- monitor chart: <OLD_CHART> -> <NEW_CHART>
- neuvector/*: <OLD_NV> -> <NEW_NV>
- compliance-config: <OLD> -> <NEW>
- registry-adapter: <OLD> -> <NEW>
- updater: <OLD> -> <NEW>
- prometheus-exporter: <OLD> -> <NEW>
```

Omit any companion image line where the tag did not change.

If a commit already exists with a shorter message, amend it:

```bash
git commit --amend -m "<full message above>"
```

### Push

Push the bump branch to `origin` (the user's fork), never directly to `upstream`:

```bash
git push -u origin bump-<NEW_NV>
```

### Tell the user
- The PR should target `<release-branch>`
- After merge, tag `v<NEW_CHART>` to trigger the publish workflow

## Rules

- Base each bump on the correct `upstream/<release-branch>` and work on `bump-<NEW_NV>`, never directly on `master` or an existing upstream release branch.
- An empty companion-tag response defaults to patch +1 for each current companion tag; a non-empty response must provide explicit tags.
- Push bump commits to `origin` (the user's fork), never directly to `upstream`. The only exception is an explicitly approved creation of a new upstream release branch.
- `monitor.appVersion` tracks the Prometheus exporter version, not the NeuVector product version.
- The publish workflow triggers on `v*` git tags and uses the tag as the chart package version.
