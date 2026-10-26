#!/usr/bin/env python3
"""Run serial native Metal measurements; no profiler or UI inspection during samples."""
import hashlib
import itertools
import json
import os
from pathlib import Path
import random
import subprocess
import time

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "results"
EXE = ROOT / "build/shadow-benchmark.app/Contents/MacOS/shadow-benchmark"
OUT.mkdir(exist_ok=True)
cases = list(itertools.product((100, 1000), (False, True),
                              ("none", "rectangular1", "rectangular2", "qcm"), (False,)))
cases += [(100, animated, mode, True) for animated in (False, True)
          for mode in ("rectangular2", "qcm")]
rng = random.Random(20261026)
jobs = []
for repeat in range(1, 4):
    order = list(cases)
    rng.shuffle(order)
    jobs.extend((repeat, *case) for case in order)
manifest = {
    "seed": 20261026, "repetitions": 3, "warmupMs": 1500, "sampleMs": 4000,
    "execution": "serial; one benchmark process at a time; native left display; no profiler",
    "jobs": jobs,
    "files": {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
              for name in ("main.cpp", "Scene.qml", "ShadowCell.qml", "CMakeLists.txt")},
}
manifest_path = OUT / "manifest.json"
if manifest_path.exists():
    previous = json.loads(manifest_path.read_text())
    assert previous["files"] == manifest["files"], "Sources changed; use a new results directory"
else:
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
env = dict(os.environ)
for key in ("QT_QUICK_BACKEND", "QSG_RENDER_TIMING", "QT_LOGGING_RULES", "QML_IMPORT_TRACE",
            "QSG_VISUALIZE", "QSG_RHI_BACKEND", "QSG_NO_VSYNC", "QSG_RENDER_LOOP",
            "QT_QPA_PLATFORM", "QML_DISABLE_DISK_CACHE"):
    env.pop(key, None)
env["QSG_RHI_BACKEND"] = "metal"
all_results = []
for index, (repeat, count, animated, mode, real_fab) in enumerate(jobs, 1):
    name = f"{index:02d}-r{repeat}-{count}-{'fab56' if real_fab else 'stress28'}-{mode}-{'animated' if animated else 'static'}"
    result_path = OUT / (name + ".json")
    if result_path.exists():
        result = json.loads(result_path.read_text())
        result.update(repeat=repeat, order=index, label=name)
        all_results.append(result)
        print(f"RESUME {index:02d}/{len(jobs)} {name}", flush=True)
        continue
    cmd = [str(EXE), "--measure", "--mode", mode, "--count", str(count),
           "--warmup-ms", "1500", "--sample-ms", "4000", "--output", str(result_path)]
    if animated:
        cmd.append("--animated")
    if real_fab:
        cmd.append("--real-fab")
    if repeat == 1:
        cmd += ["--snapshot", str(OUT / (name + ".png"))]
    started = time.time()
    completed = subprocess.run(cmd, env=env, capture_output=True, text=True, timeout=35)
    log_path = OUT / (name + ".log")
    if log_path.exists():
        previous_log = log_path.with_suffix(f".previous-{time.time_ns()}.log")
        log_path.rename(previous_log)
    log_path.write_text(completed.stdout + completed.stderr)
    if completed.returncode or not result_path.exists():
        print(f"FAILED {index}/{len(jobs)} {name}: {completed.stderr[-1600:]}", flush=True)
        raise SystemExit(completed.returncode or 1)
    result = json.loads(result_path.read_text())
    assert result["backend"] == "Metal" and result["verifiedVisibleCasters"] == count
    assert result["qmlWarningCount"] == 0 and result["gpuElapsed"]["samples"] > 0
    assert result["screenGeometry"][0] < 0 and result["dpr"] == 1
    if mode != "none":
        assert result["pixelVerifiedShadows"] == count
    if mode in ("qcm", "rectangular2") and animated:
        assert result["elevationPixelsChanged"]
    result.update(repeat=repeat, order=index, label=name, elapsedSeconds=time.time()-started)
    all_results.append(result)
    (OUT / "all-results.json").write_text(json.dumps(all_results, indent=2) + "\n")
    print(f"{index:02d}/{len(jobs)} {name}: CPU {result['cpuMsPerFrame']:.3f}ms/frame; "
          f"GPU {result['gpuElapsed']['meanMs']:.3f}ms; FPS {result['fps']:.1f}", flush=True)
print(f"Completed {len(all_results)} native runs", flush=True)
