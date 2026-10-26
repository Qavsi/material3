#!/usr/bin/env python3
"""Aggregate three independent repetitions without mixing geometry or workload."""
from collections import defaultdict
import json
from pathlib import Path
import statistics

root = Path(__file__).resolve().parent
results_dir = root / "results"
results = json.loads((results_dir / "all-results.json").read_text())
assert len(results) == 60, f"Incomplete run: {len(results)}/60"
groups = defaultdict(list)
for result in results:
    assert result["backend"] == "Metal" and result["qmlWarningCount"] == 0
    assert result["verifiedVisibleCasters"] == result["items"]
    assert result["gpuElapsed"]["samples"] > 0
    groups[(result["items"], result["realFab"], result["animated"], result["mode"])].append(result)
summary = []
for key, runs in sorted(groups.items()):
    assert len(runs) == 3 and {r["repeat"] for r in runs} == {1, 2, 3}
    n, real_fab, animated, mode = key
    row = {"items": n, "realFab": real_fab, "animated": animated, "mode": mode}
    metrics = {
        "cpuMsPerFrame": lambda r: r["cpuMsPerFrame"],
        "gpuMeanMs": lambda r: r["gpuElapsed"]["meanMs"],
        "gpuP95Ms": lambda r: r["gpuElapsed"]["p95Ms"],
        "fps": lambda r: r["fps"],
        "frameP95Ms": lambda r: r["frameIntervals"]["p95Ms"],
        "renderStageElapsedMeanMs": lambda r: r["renderRecordingCpu"]["meanMs"],
        "syncStageElapsedMeanMs": lambda r: r["syncCpu"]["meanMs"],
        "rssMb": lambda r: r["rssMb"],
        "creationMs": lambda r: r["creationMs"],
    }
    for name, get in metrics.items():
        values = [get(r) for r in runs]
        row[name] = statistics.median(values)
        row[name + "Range"] = [min(values), max(values)]
    row["longFrames"] = sum(r["framesOver1_5RefreshBudget"] for r in runs)
    row["frames"] = sum(r["frames"] for r in runs)
    row["frameIntervals"] = sum(r["frameIntervals"]["samples"] for r in runs)
    summary.append(row)
(results_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
lines = ["| Casters | Geometry | Workload | Renderer | CPU ms/frame | GPU mean ms | Frame p95 ms | FPS | RSS MiB |",
         "|---:|---|---|---|---:|---:|---:|---:|---:|"]
for r in summary:
    lines.append(f"| {r['items']} | {'56x56 r16' if r['realFab'] else '28x28 r6'} | "
                 f"{'animated' if r['animated'] else 'static redraw'} | {r['mode']} | "
                 f"{r['cpuMsPerFrame']:.3f} | {r['gpuMeanMs']:.3f} | {r['frameP95Ms']:.2f} | "
                 f"{r['fps']:.1f} | {r['rssMb']:.1f} |")
(results_dir / "table.md").write_text("\n".join(lines) + "\n")
print("\n".join(lines))
