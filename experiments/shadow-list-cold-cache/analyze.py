import hashlib,json,math,pathlib,statistics
root=pathlib.Path(__file__).resolve().parent
runs=[json.loads(p.read_text()) for p in (root/'results').glob('*.json') if p.name not in ('manifest.json','summary.json')]
assert len(runs)==24
for run in runs:
 assert run['count']==50 and run['qmlWarnings']==0
 assert run['shadowPixelCount']==(0 if run['scene']=='controls-off' else 50)
 assert run['nativeControls']==(50 if run['scene'].startswith('controls') else 0)
 for p in run['phases']:
  assert p['frames']>0 and math.isfinite(p['cpuMsPerFrame']) and p['cpuMsPerFrame']>=0
  if run['backend']=='metal':assert p['gpuMs']['samples']>0
  if p['phase']=='warm-retained-cache':assert p['cornerCacheMisses']==0
  if run['drawCallDiagnostic']:assert p['drawCalls']['samples']>0
summary=[]
for backend in ['metal','opengl']:
 for scene in ['controls-off','controls','blur-same','blur-mixed']:
  selected=[r for r in runs if r['backend']==backend and r['scene']==scene and not r['drawCallDiagnostic']]
  assert len(selected)==(3 if backend=='metal' else 1)
  diagnostic=next(r for r in runs if r['backend']==backend and r['scene']==scene and r['drawCallDiagnostic'])
  row={'backend':backend,'scene':scene,'repeats':len(selected),'phases':[]}
  for name in [p['phase'] for p in selected[0]['phases']]:
   a=[next(p for p in r['phases'] if p['phase']==name) for r in selected]
   median=lambda f:statistics.median(f(p) for p in a)
   point={'phase':name,'cpuMsPerFrameMedian':median(lambda p:p['cpuMsPerFrame']),
    'cpuMsPerFrameRange':[min(p['cpuMsPerFrame'] for p in a),max(p['cpuMsPerFrame'] for p in a)],
    'wallMsMedian':median(lambda p:p['wallMs']),
    'firstFrameQueuedMsMedian':median(lambda p:p['firstFrameQueuedMs']),
    'firstFrameQueuedMsRange':[min(p['firstFrameQueuedMs'] for p in a),max(p['firstFrameQueuedMs'] for p in a)],
    'frameMs':{k:median(lambda p:p['frameMs'][k]) for k in ['p50','p95','p99']},
    'worstFrameMs':max(p['frameMs']['max'] for p in a),
    'framesOver33':sum(p['frameMs']['over33'] for p in a),
    'gpuMeanMsMedian':median(lambda p:p['gpuMs']['mean']) if all(p['gpuMs']['samples'] for p in a) else None,
    'gpuP50P95P99Ms':{k:median(lambda p:p['gpuMs'][k]) for k in ['p50','p95','p99']} if all(p['gpuMs']['samples'] for p in a) else None,
    'cornerCacheMissesMedian':median(lambda p:p['cornerCacheMisses']),
    'convolutionElapsedMsMedian':median(lambda p:p['convolutionMs'])}
   d=next(p for p in diagnostic['phases'] if p['phase']==name)
   point['drawCallsDiagnostic']={k:d['drawCalls'][k] for k in ['samples','p50','p95','p99','max']}
   row['phases'].append(point)
  summary.append(row)
(root/'results/summary.json').write_text(json.dumps(summary,indent=2)+'\n')
num=lambda v:'—' if v is None else f'{v:.3f}'
steady=lambda r:next(p for p in r['phases'] if p['phase']=='steady')
labels={'controls-off':'50 SK.Button, shadow off','controls':'50 SK.Button, analytic shadow on','blur-same':'50 BlurMask cards, identical radii','blur-mixed':'50 BlurMask cards, five radius sets'}
lines=['# Shadow list and cold-cache study — 2026-10-27','',
'24 valid native runs: 12 Metal timing runs, 4 OpenGL compatibility timing runs and 8 separate draw-call diagnostics. Production files and Qt SDK are unchanged. No commit or push.',
'', '## Scope and environment','',
f"- Qt {runs[0]['qt']}, macOS {runs[0]['os']}, Apple M4, Release. Metal/threaded is the primary timing target; OpenGL requests a 3.3 Core context and uses the basic render loop required by this macOS setup.",
'- Left VA2419 display only, 1800x950 client area, DPR1/60Hz. All 50 items and their shadow margins are visible. Counts, backend, display, warnings and shadow pixels are validity gates.',
'- Real-control scene: 50 enabled native SK.Button controls, buttonSmall/elevated, 100x40, elevation1. The no-shadow scene keeps the same controls and disables only their elevation items. Hover is disabled to prevent pointer location changing the workload.',
'- Blur scenes: 50 80x56 cards. Same radii=(4,12,20,8); mixed adds index%5 to every radius. The exact Material3Elevation adapter is copied with one import added. This is a primitive/card workload, separate from the complete-control workload.',
'- Static controls and steady 6↔8dp BlurMask animation use a small repaint heartbeat. Four seconds per timing sample; Metal has three repetitions. OpenGL has one repetition and is a compatibility check, not a comparative performance claim.',
'- Initial animation is 0→12dp over 250ms. UI/scene setup is allowed 800ms before it starts; corner textures remain cold. This is a cold per-process corner cache, not a flushed driver/disk shader cache.',
'', '## Steady measurements','',
'CPU is process CPU time across all threads divided by queued frames; it is not frame latency. Frame columns are wall-clock intervals between QQuickWindow.frameSwapped notifications (queued for presentation, not confirmed display scanout). Each listed percentile is the median of per-run percentiles; worst is the largest observed interval across all repeats.',
'', '| Backend / scene | CPU ms/frame | GPU mean ms | Frame p50 / p95 / p99 ms | Worst ms | Draw calls/frame |', '|---|---:|---:|---|---:|---:|']
for row in summary:
 p=steady(row);f=p['frameMs'];lines.append(f"| {row['backend']} / {labels[row['scene']]} | {num(p['cpuMsPerFrameMedian'])} | {num(p['gpuMeanMsMedian'])} | {num(f['p50'])} / {num(f['p95'])} / {num(f['p99'])} | {num(p['worstFrameMs'])} | {p['drawCallsDiagnostic']['p50']:.0f} |")
lines += ['', 'GPU values are medians of per-run means of asynchronous completed-frame QRhi timestamps; they are not paired to the current CPU frame. OpenGL returned no usable GPU timestamps, shown as unavailable. Full GPU p50/p95/p99, CPU ranges and per-run data remain in JSON.',
'', '## Initial animation and cache lifetime — Metal','',
'Animation wall time ends at the QML animation-finished signal. First-frame queue time starts at the animation request, excluding the previous idle interval. Frame maxima exclude that separate first-frame latency. Short animations contain roughly 15 frames, so tail percentiles have low sample counts.',
'', '| Scene / phase | Animation wall ms | First frame queued ms | Worst interval ms | New corner textures | Convolution elapsed ms |', '|---|---:|---:|---:|---:|---:|']
for row in summary:
 if row['backend']!='metal' or row['scene'].startswith('controls'):continue
 for p in row['phases']:
  if p['phase']=='steady':continue
  lines.append(f"| {row['scene']} / {p['phase']} | {num(p['wallMsMedian'])} | {num(p['firstFrameQueuedMsMedian'])} | {num(p['worstFrameMs'])} | {p['cornerCacheMissesMedian']:.0f} | {num(p['convolutionElapsedMsMedian'])} |")
lines += ['', 'The warm-retained-cache phase explicitly populates all 29 half-pixel sigma buckets outside timing, then starts at 0.012dp so the materials retain cache ownership. Zero new textures are required and verified. This differs from returning every elevation to exactly0.',
'', 'The repeat-after-zero phase returns all 50 elevations to 0 for 100ms. Material3Elevation destroys its renderers, the last strong BlurMask cache owner disappears, and the next animation generates corner textures again. The measured cold cost can recur; a one-time warmup is not sufficient if cache ownership is later released.',
'', 'Convolution time is steady_clock elapsed time around mask convolution on the render thread, summed over new textures. It is not thread CPU time and does not isolate GPU upload. Only the frozen measurement copy contains this probe (atomic miss count plus elapsed timer); production renderer files are untouched.',
'', '## Draw-call method','',
'Diagnostic processes load libdrawcounter.dylib through DYLD_INSERT_LIBRARIES. Mach-O interposition counts actual QRhiCommandBuffer::draw/drawIndexed API submissions for each frame. Counts are whole Qt Quick scene draw submissions, including bodies, labels and heartbeat; they are not inferred from nodes or batches. This fixture uses neither indirect draws nor external render nodes. This is not an OS-compositor draw count.',
'', 'The injected library is absent from every timing process, and the application rejects an injected timing run. Each diagnostic uses a separate 600ms steady sample; its CPU/GPU timings are excluded from the tables. The counter requires nonzero observed calls to pass.',
'', '50 native analytic shadows add one draw submission (151→152). Each BlurMask scene submits101 whole-scene calls, including card bodies and the heartbeat. This is not an isolated shadow-only count. Repeated versus mixed radius sets have the same call count; the source RequiresFullMatrix restriction remains in effect. Do not compare the152 complete-button calls directly with101 card-scene calls.',
'', '## Interpretation','',
'- At 50 native controls on this M4, the analytic shadow adds one draw and about 0.1ms mean GPU time. CPU ranges overlap; the lower on-shadow CPU median is measurement variation, not an optimization benefit.',
'- Unequal-corner first animation has measurable render-thread texture-generation cost, especially with multiple radius sets. Warm retained cache removes generation work. Preserve this scope: it does not affect the analytic button/FAB path.',
'- Consider cache ownership/lifetime before choosing pre-warm. Crossfade and vertex-attribute batching are not implemented by this study. The steady workload does not by itself justify either change on this device.',
'- OpenGL/basic passed all rendering/counter gates. Its first-frame latency can exceed 50ms in this one-run compatibility sample. Metal and OpenGL render loops differ; do not interpret their CPU figures as an isolated backend comparison.',
'', '## Evidence and limits','',
'- results/manifest.json: shuffled order, binary hash, exits and durations. results/summary.json: per-scenario medians/ranges. Each raw JSON, log and PNG is retained.',
'- inputs.json: frozen revisions, production shadow hashes and harness/counter hashes. All 19 production shadow source files matched the frozen committed revision before the study.',
'- An initial forced-threaded OpenGL diagnostic crashed with `-[NSOpenGLContext setView:] must be called from the main thread.` Its excluded log is retained outside results. Validation-only attempts are not timing evidence.',
'- An existing Material3 preview process was temporarily SIGSTOP-paused for the series and SIGCONT-resumed in finally. No build, QML Preview connection, UI automation or draw-call instrumentation ran inside the timing processes.',
'- No GLES/Vulkan/D3D/device run; no1000-item unequal-corner claim. No software-shadow policy change. Three Metal repeats and one OpenGL repeat are a targeted check, not a universal FPS guarantee.',
'', 'AI assistance has been used to create this output.','']
(root/'REPORT.md').write_text('\n'.join(lines))
print('Validated24 runs; report:',root/'REPORT.md')
