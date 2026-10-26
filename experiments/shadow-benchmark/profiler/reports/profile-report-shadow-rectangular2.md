# Shadow renderer diagnostic: rectangular2

Profile: rendering(scenegraph,animations,painting,pixmapcache).
Trace: `../traces/qmlprofiler-trace-shadow-rectangular2.qtd`.
Qt 6.12.0 / Metal / left display / 1000 animated 28x28 casters.
Approximate captured run duration: 2842ms, inferred from animation events.
Captured events: 168.
Sum of captured range-event durations: 0.0ms. This is not wall time or total CPU; ranges can nest. No QML range events were captured by this rendering profile, so this value does not mean CPU usage was zero.

## Animation cadence

Frame-time values below are estimated from the trace's animation frame-rate records. Native frameSwapped measurements in the separate benchmark report are the primary presentation-timing evidence.

- p50: 17.24ms; p95: 17.24ms; p99: 27.03ms; max: 43.48ms.
- Frames over 25/33/50 ms: 3/2/0.
- Frame records: 168; estimated average animation rate: 59.1Hz.
- p50 is the median; p95/p99 are values with at most 5%/1% higher values. At 60 Hz the reference budget is 16.67 ms; over 33 ms is noticeable stutter and over 50 ms is a severe stall. Quantized rates cause percentile ties.

## Hotspots and coverage

There are no captured QML range hotspots to map to source lines. Binding, JavaScript, object-creation, and memory profiles were not enabled. No memory/pixmap event summary is available. No source change is justified from this trace alone.

The instrumented run is a standalone diagnostic and is excluded from the uninstrumented three-repeat performance matrix. Its JSON in the parent profiler directory must not be pooled with benchmark results.
