#!/usr/bin/env python3
"""Serial Release/Metal sanity check of the actual port against frozen QCM."""
import hashlib
import itertools
import json
import os
from pathlib import Path
import random
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "results"
EXE = ROOT / "build/shadow-port-benchmark.app/Contents/MacOS/shadow-port-benchmark"
OUT.mkdir(exist_ok=True)
PRODUCTION = Path("/Volumes/Mac/SCS/dev/Qavsi/material3")
QCM_LIBRARY = Path("/private/tmp/qavsi-shadow-benchmark/build/qcm/libqml_material.dylib")


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


jobs = []
rng = random.Random(20261026)
for repeat in range(1, 4):
    order = list(itertools.product((False, True), ("qcm", "ported")))
    rng.shuffle(order)
    jobs.extend((repeat, animated, mode) for animated, mode in order)
production_files = sorted((PRODUCTION / "src/Qavsi/Material3/Style/internal/shadows").rglob("*"))
manifest = {
    "seed": 20261026, "repetitions": 3, "items": 1000,
    "warmupMs": 1500, "sampleMs": 4000, "jobs": jobs,
    "execution": "serial native left-display Metal; no profiler or QML debug service",
    "geometry": "28x28 radius6; all1000 casters and shadow extents visible",
    "animation": "shared250ms elevation 6-to8-and-back; QCM internal Behavior disabled",
    "fixtureSources": {name: sha256(ROOT / name)
                       for name in ("main.cpp", "Scene.qml", "ShadowCell.qml", "CMakeLists.txt", "run.py")},
    "productionSources": {str(path.relative_to(PRODUCTION)): sha256(path)
                          for path in production_files if path.is_file()},
    "binaries": {str(EXE): sha256(EXE), str(QCM_LIBRARY): sha256(QCM_LIBRARY)},
}
for path in (ROOT / "build").rglob("libQavsiMaterial3Style*.dylib"):
    manifest["binaries"][str(path)] = sha256(path)
assert any("libQavsiMaterial3Style" in path for path in manifest["binaries"])
manifest_path = OUT / "manifest.json"
if manifest_path.exists():
    previous = json.loads(manifest_path.read_text())
    for key in ("fixtureSources", "productionSources", "binaries", "jobs"):
        # JSON converts the tuples in jobs to lists.
        assert previous[key] == json.loads(json.dumps(manifest[key])), f"Changed {key}; use a fresh results directory"
else:
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")

env = dict(os.environ)
for key in ("QT_QUICK_BACKEND", "QSG_RENDER_TIMING", "QT_LOGGING_RULES", "QML_IMPORT_TRACE",
            "QSG_VISUALIZE", "QSG_RHI_BACKEND", "QSG_NO_VSYNC", "QSG_RENDER_LOOP",
            "QT_QPA_PLATFORM", "QML_DISABLE_DISK_CACHE"):
    env.pop(key, None)
env["QSG_RHI_BACKEND"] = "metal"
results = []
for index, (repeat, animated, mode) in enumerate(jobs, 1):
    name = f"{index:02d}-r{repeat}-1000-{mode}-{'animated' if animated else 'static'}"
    output = OUT / (name + ".json")
    if output.exists():
        result = json.loads(output.read_text())
        print(f"RESUME {index:02d}/12 {name}", flush=True)
    else:
        command = [str(EXE), "--measure", "--mode", mode, "--count", "1000",
                   "--warmup-ms", "1500", "--sample-ms", "4000", "--output", str(output)]
        if animated:
            command.append("--animated")
        if repeat == 1:
            command += ["--snapshot", str(OUT / (name + ".png"))]
        completed = subprocess.run(command, env=env, capture_output=True, text=True, timeout=35)
        log = OUT / (name + ".log")
        if log.exists():
            log.rename(log.with_suffix(f".previous-{time.time_ns()}.log"))
        log.write_text(completed.stdout + completed.stderr)
        if completed.returncode or not output.exists():
            print(f"FAILED {name}: {completed.stderr[-1800:]}", flush=True)
            raise SystemExit(completed.returncode or 1)
        result = json.loads(output.read_text())
    assert result["mode"] == mode and result["animated"] == animated
    assert result["backend"] == "Metal" and result["items"] == 1000
    assert result["verifiedVisibleCasters"] == 1000 and result["pixelVerifiedShadows"] == 1000
    assert result["shadowRendererCount"] == 1000 and result["qmlWarningCount"] == 0
    assert result["gpuElapsed"]["samples"] > 0 and result["screenGeometry"][0] < 0
    if animated:
        assert result["elevationPixelsChanged"]
    if mode == "qcm":
        assert result["disabledQcmBehaviors"] == 1000
    result.update(repeat=repeat, order=index, label=name)
    results.append(result)
    (OUT / "all-results.json").write_text(json.dumps(results, indent=2) + "\n")
    print(f"{index:02d}/12 {name}: CPU {result['cpuMsPerFrame']:.3f}ms/frame; "
          f"GPU {result['gpuElapsed']['meanMs']:.3f}ms; FPS {result['fps']:.1f}", flush=True)

summary = []
for animated, mode in itertools.product((False, True), ("qcm", "ported")):
    runs = [r for r in results if r["animated"] == animated and r["mode"] == mode]
    assert len(runs) == 3
    row = {"mode": mode, "animated": animated}
    metrics = {"cpuMsPerFrame": lambda r: r["cpuMsPerFrame"],
               "gpuMeanMs": lambda r: r["gpuElapsed"]["meanMs"],
               "frameP95Ms": lambda r: r["frameIntervals"]["p95Ms"],
               "fps": lambda r: r["fps"], "rssMb": lambda r: r["rssMb"]}
    for name, get in metrics.items():
        values = [get(r) for r in runs]
        row[name] = statistics.median(values)
        row[name + "Range"] = [min(values), max(values)]
    summary.append(row)
(OUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print("Completed 12/12 valid native sanity runs", flush=True)
