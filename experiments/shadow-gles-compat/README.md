# Shadow shader GLES portability check

Qt 6.12/macOS diagnostic. Checks the actual CMake-built `.qsb` outputs; it does
not duplicate the production shader compiler invocation. No extra dependency,
SDK modification or routine private-detail test.

```sh
python3 check.py --qsb /Users/techalp/Qt/6.12.0/macos/bin/qsb \
  --packages /path/to/current-build/src/Qavsi/Material3/Style/.qsb/shaders \
  --baseline /path/to/before-fix/shaders \
  --output result.json
```

Build the library normally before running. The baseline packages must come
from the same Qt version/target configuration before the fix (e73fa2b).
Without `--baseline`, the script still checks ES300 portability and extraction
of all 48 standard/batchable target variants, but makes no native equality claim.
This fixture expects the macOS shader target set; it is not a WASM package gate.

`red.json` records the previous packages failing all 6 ES checks. `green.json`
records zero failures and byte-identical non-ES outputs. Per-variant hashes,
source/package hashes and compiler baseline are retained. No `.qsb` binaries
or new PNGs are committed.

Four short native runs reuse the existing shadow-list harness with `--drawcalls
--require-cache-reuse`: 50 elevated controls and 50 mixed-corner cards on Metal
and OpenGL, only on the left display. These are functional checks, not a new
performance benchmark. `native/` contains JSON/logs; `native-summary.json`
contains temporary snapshot hashes and baseline matches. The two BlurMask
PNGs match the previous committed snapshots exactly. Complete control PNGs
are not byte-identical; native shader equality, visible-shadow gates and
unchanged draw counts are the analytic-path evidence.

See [SHADOW-GLES.md](../../evidence/SHADOW-GLES.md) for the implementation,
proof scope and missing real-device GLES validation.
