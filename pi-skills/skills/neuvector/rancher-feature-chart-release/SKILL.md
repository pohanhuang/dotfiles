---
name: neuvector-rancher-feature-chart-release
description: >
  Publish NeuVector core/CRD and monitor Rancher feature charts, or create
  Rancher chart PRs from existing generated branches. Use when asked to bump,
  publish, release, or create rancher/charts PRs for NeuVector Rancher feature
  charts. Detects the next Rancher chart patch from released charts, dispatches
  the existing GitHub workflows serially, verifies generated chart versions,
  and creates PRs with the Rancher PR template.
argument-hint: "<upstream-helm-version> [Rancher releases]"
---

# NeuVector Rancher Feature Chart Release

Use this skill from the `neuvector/neuvector-tests` checkout. It orchestrates
existing workflows; it does not modify `neuvector-helm`, the Rancher chart
source, or the workflow/scripts.

## Start: ask for the entry point

Ask the user which step to start at before running any command:

1. **Full release** — detect the next versions, dispatch workflows, verify the
   generated branches, then create PRs.
2. **Generate branches only** — detect versions, dispatch workflows, and verify
   branches; do not create PRs.
3. **Create PRs only** — do not dispatch workflows; verify existing feature
   branches and create missing PRs.
4. **Status only** — read-only check of released versions, workflow runs,
   feature branches, and PRs.

For options 1–3, ask the user for the expected upstream NeuVector Helm chart
version (for example, `2.12.0`). Never infer or increment that version.

Then ask whether to process all active releases or selected releases. Active
releases are Rancher `2.15`, `2.14`, `2.13`, and `2.12`. Both core/CRD and
monitor are included by default; ask before omitting either chart.

Before dispatching any workflow, show the full calculated plan and ask for
confirmation. Before creating PRs, show every proposed PR and ask again for
confirmation.

## Release mapping

| Rancher | released-chart ref | workflow publish prefix | PR base branch | core head branch | monitor head branch |
|---|---|---|---|---|---|
| 2.15 | `release-v2.15` | `110.0.x` | `dev-v2.15` | `neuvector-dev-v2.15` | `nv-monitor-dev-v2.15` |
| 2.14 | `release-v2.14` | `109.0.x` | `dev-v2.14` | `neuvector-dev-v2.14` | `nv-monitor-dev-v2.14` |
| 2.13 | `release-v2.13` | `108.1.x` | `dev-v2.13` | `neuvector-dev-v2.13` | `nv-monitor-dev-v2.13` |
| 2.12 | `release-v2.12` | `107.1.x` | `dev-v2.12` | `neuvector-dev-v2.12` | `nv-monitor-dev-v2.12` |

Rancher 2.11 and older are EOL. Do not process them unless the user explicitly
asks and supplies the exact release mapping.

## Find the next publish version

The source of truth is the most recently published stable chart directory in
`rancher/charts`, not a local checkout, the comments in `run_wf.sh`, or a
feature branch. Query both chart paths on the corresponding `release-v2.*`
ref. This has no machine-path dependency:

```bash
latest_chart_version() {
  local chart_path=$1 ref=$2
  gh api "repos/rancher/charts/contents/${chart_path}?ref=${ref}" --jq '.[].name' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\+up[0-9]+\.[0-9]+\.[0-9]+$' |
    sort -V |
    tail -n 1
}

core_current=$(latest_chart_version charts/neuvector release-v2.15)
monitor_current=$(latest_chart_version charts/neuvector-monitor release-v2.15)
printf 'core: %s\nmonitor: %s\n' "$core_current" "$monitor_current"
```

A result has the form `110.0.4+up2.11.4`. Split it without depending on a
filesystem listing:

```bash
publish_version=${core_current%%+up*}  # 110.0.4
published_helm_version=${core_current#*+up}  # 2.11.4
```

Core and monitor must have the same current **publish** version. If they do
not, stop and ask the user for the intended version; do not choose one or
silently make them diverge.

Increment only the final patch component:

```bash
increment_patch() {
  local major minor patch
  IFS=. read -r major minor patch <<<"$1"
  printf '%s.%s.%s\n' "$major" "$minor" "$((patch + 1))"
}

next_publish_version=$(increment_patch "$publish_version")
```

Examples:

```text
110.0.4 -> 110.0.5
109.0.8 -> 109.0.9
108.1.1 -> 108.1.2
107.1.3 -> 107.1.4
```

For upstream Helm version `2.12.0`, present this plan for approval:

```text
Rancher 2.15: 110.0.4+up2.11.4 -> 110.0.5+up2.12.0
Rancher 2.14: 109.0.8+up2.11.4 -> 109.0.9+up2.12.0
Rancher 2.13: 108.1.1+up2.11.4 -> 108.1.2+up2.12.0
Rancher 2.12: 107.1.3+up2.11.4 -> 107.1.4+up2.12.0
```

## Preflight

Before workflow dispatch or PR creation, confirm authentication and access:

```bash
gh auth status
gh repo view neuvector/neuvector-tests
gh repo view neuvector/rancher-charts
gh repo view rancher/charts
gh workflow view Publish_Rancher_Feature_Chart.yml
gh workflow view Publish_Rancher_Feature_Monitor_Chart.yml
```

The workflows default to the repository default branch, currently `main`; do
not pass `--ref main`. Only pass `--ref` if the user explicitly requests a
non-default workflow ref.

## Dispatch workflows serially

For a full release or generate-branches-only run, dispatch every workflow in
strict sequence. Do **not** run core and monitor in parallel, and do not start
the next Rancher release until the preceding workflow has completed. The
existing scripts update shared fork branches including `dev-v2.*` and
`automation-core`, so concurrent runs can race.

For each selected release, run core, wait for success, then run monitor and
wait for success:

```bash
gh workflow run Publish_Rancher_Feature_Chart.yml -F version=<publish-version>
# Find the just-dispatched workflow_dispatch run, record its URL, then:
gh run watch <core-run-id> --exit-status

gh workflow run Publish_Rancher_Feature_Monitor_Chart.yml -F version=<publish-version>
# Find the just-dispatched workflow_dispatch run, record its URL, then:
gh run watch <monitor-run-id> --exit-status
```

Use `gh run list --workflow <workflow-file> --event workflow_dispatch --limit 5`
to locate the newly dispatched run and verify its creation time before
watching it. If any run fails, stop immediately, inspect its logs with
`gh run view <run-id> --log-failed`, and ask the user whether to stop or retry.
Never blindly retry: the scripts delete and recreate feature branches.

## Verify generated feature branches

For each successful workflow, verify that the head branch exists in
`neuvector/rancher-charts` and compare it with its mapped `rancher/charts`
base branch:

```bash
gh api repos/neuvector/rancher-charts/branches/<head-branch>
gh api "repos/neuvector/rancher-charts/compare/<base>...<head-branch>" \
  --jq '{status, ahead_by, files: [.files[].filename]}'
```

The feature branch must be ahead of the corresponding base. Confirm that the
changed chart directories contain the expected exact version:

```text
<publish-version>+up<user-supplied-helm-version>
```

For PR-only mode, perform these same checks without dispatching workflows. If
the expected version is absent, stop and report the mismatch; do not create a
PR.

## Create PRs

Search `rancher/charts` for an existing open PR before creating one:

```bash
gh pr list --repo rancher/charts --state open \
  --head 'neuvector:<head-branch>' --base '<base-branch>' \
  --json number,title,url
```

If an equivalent PR exists, report it and do not alter it. For each missing PR,
show the title, head, and base to the user and obtain final confirmation.

Use the exact Rancher PR template from the **target base branch** as the body.
Do not add generated release details, workflow URLs, testing claims, or any
custom content. Only the title is generated. Fetch the template and create the
PR as follows:

```bash
template_file=$(mktemp)
gh api "repos/rancher/charts/contents/.github/pull_request_template.md?ref=<base-branch>" \
  --jq '.content' | base64 --decode >"$template_file"

gh pr create --repo rancher/charts \
  --head 'neuvector:<head-branch>' \
  --base '<base-branch>' \
  --title '<title>' \
  --body-file "$template_file"

rm -f "$template_file"
```

Use these title formats exactly; they match the Rancher PR template convention:

```text
[dev-v2.<minor>] neuvector <publish-version>+up<helm-version> bump
[dev-v2.<minor>] neuvector-monitor <publish-version>+up<helm-version> bump
```

Examples for Rancher 2.15:

```text
[dev-v2.15] neuvector 110.0.5+up2.12.0 bump
[dev-v2.15] neuvector-monitor 110.0.5+up2.12.0 bump
```

## Completion report

Report, for every selected release:

- detected current core and monitor versions;
- proposed and used publish version;
- requested upstream Helm version;
- core and monitor workflow URLs and conclusions, if run;
- core and monitor feature branches and `rancher/charts` base branch;
- created PR URLs or pre-existing PR URLs;
- skipped or failed operations and their reason.

Never merge, close, edit, or retarget a PR unless the user explicitly requests
that separate action.
