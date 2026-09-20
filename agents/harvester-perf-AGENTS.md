# Benchmark Agent Rules
# Appends to global AGENTS.md — benchmark-specific only.

## Benchmark Methodology

Every benchmark requires:
- Baseline: p50, p99, throughput before change
- Isolation: one variable at a time
- Repetition: ≥3 runs, report median
- System state: CPU freq governor, NUMA topology, hugepages noted

Tracing chain: metric anomaly → perf/bpftrace → kernel call → hardware event.
Never stop at "latency increased" — name the layer.

## Live Migration

Key metrics: migration_data_processed_bytes, migration_data_remaining_bytes,
vmi_migration_phase_transition_seconds.

Regression threshold: p99 >20% above baseline → block merge.

## Prometheus

- Include time range and step in every query.
- Label matchers must be specific (no bare metric names).
- No rate() on gauges. No irate() on slow counters.

## Finding Format

number → root cause → evidence (query/trace output) → fix.
No speculation without data.

## Benchmark Cleanup

Teardown order is mandatory: VM → VMI → PVC → Longhorn Volume.
Never delete bottom-up; dangling PVCs block scheduling.

### Survey first (always)

```bash
kubectl get vm,vmi -A
kubectl get pvc -A
kubectl -n longhorn-system get volumes -o json | \
  jq -r '.items[] | "\(.status.state)\t\(.status.robustness)"' | sort | uniq -c
```

Show counts, confirm namespace and which volumes must survive before deleting.

### Delete top-down

```bash
kubectl delete vm --all -n <ns>
kubectl delete vmi --all -n <ns>
kubectl delete pvc --all -n <ns>
# Longhorn volumes that survived PVC GC:
kubectl -n longhorn-system get volumes -o json | \
  jq -r '.items[] | select(.status.state=="detached") | .metadata.name' | \
  xargs -r kubectl -n longhorn-system delete volume
```

### Verify

```bash
kubectl get vm,vmi,pvc -A
kubectl -n longhorn-system get volumes -o json | jq '[.items[] | .status.state] | group_by(.) | map({state: .[0], count: length})'
```

### UI stuck after mass deletion

```bash
kubectl get pods -A | grep -v "Running\|Completed"  # confirm pods healthy
kubectl rollout restart deployment rancher -n cattle-system
```

Wait 30-60s. Do not debug browser-side when pods are healthy.

### Parser traps

- Never `awk` on kubectl column position — columns shift between versions
- Always `-o json | jq` for programmatic selection
- Print selection before piping to delete
- `xargs -r` to suppress empty-stdin error
