## Qt Code Review Report

**Scope**: pending diff against a093a0e plus new files; changed tracked lines with surrounding context, full new files.
**Files reviewed**: 19
**Issues found**: 47 (45 deterministic lint advisories, 2 deep findings)
**qmllint**: module-aware source and relocated installed-comparison gates passed with the recorded source hashes.

No production correctness blocker was found. Advisory scans are not reported as warning-free.

### Lint findings

#### [L-001] DEP-7
- **File**: `examples/qmlmaterial-comparison/checks.cpp:465`
- **Rule**: DEP-7
- **Finding**: qMin/qMax/qBound — use (std::min)()/(std::max)()/std::clamp()
- **Mitigation**: Migration advisory in test-only pixel arithmetic. A future mutable cleanup may use standard min/max/clamp; current checks remain valid.

#### [L-002] DEP-7
- **File**: `examples/qmlmaterial-comparison/checks.cpp:466`
- **Rule**: DEP-7
- **Finding**: qMin/qMax/qBound — use (std::min)()/(std::max)()/std::clamp()
- **Mitigation**: Migration advisory in test-only pixel arithmetic. A future mutable cleanup may use standard min/max/clamp; current checks remain valid.

#### [L-003] DEP-7
- **File**: `examples/qmlmaterial-comparison/checks.cpp:467`
- **Rule**: DEP-7
- **Finding**: qMin/qMax/qBound — use (std::min)()/(std::max)()/std::clamp()
- **Mitigation**: Migration advisory in test-only pixel arithmetic. A future mutable cleanup may use standard min/max/clamp; current checks remain valid.

#### [L-004] DEP-10
- **File**: `examples/qmlmaterial-comparison/checks.cpp:537`
- **Rule**: DEP-10
- **Finding**: .count()/.length() — prefer .size() for std consistency
- **Mitigation**: Style advisory for a test signal-spy size; the existing method is available in the selected Qt version.

#### [L-005] VAR-3
- **File**: `experiments/shadow-benchmark/main.cpp:33`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-006] VAR-3
- **File**: `experiments/shadow-benchmark/main.cpp:168`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-007] VAR-3
- **File**: `experiments/shadow-benchmark/main.cpp:347`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-008] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:46`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-009] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:50`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-010] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:51`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-011] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:93`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-012] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:95`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-013] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:102`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-014] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:105`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-015] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:122`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-016] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:152`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-017] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:169`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-018] HDR-3
- **File**: `experiments/shadow-parity/main.cpp:170`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-019] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:296`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-020] VAR-3
- **File**: `experiments/shadow-parity/main.cpp:332`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-021] VAR-3
- **File**: `experiments/shadow-port-validation/main.cpp:33`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-022] VAR-3
- **File**: `experiments/shadow-port-validation/main.cpp:169`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-023] VAR-3
- **File**: `experiments/shadow-port-validation/main.cpp:349`
- **Rule**: VAR-3
- **Finding**: Direct brace initialization — prefer copy-init (var = {...}) for safety
- **Mitigation**: Initialization-style advisory; direct list initialization is intentional and consistent with the surrounding implementation.

#### [L-024] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmaterial.cpp:217`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-025] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:29`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-026] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:35`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-027] PAT-12
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:42`
- **Rule**: PAT-12
- **Finding**: Non-const range-for reference — may trigger COW detach; use const auto& if read-only
- **Mitigation**: The non-const references intentionally write a std::span-backed Gaussian kernel; this is not iteration over an implicitly shared Qt container.

#### [L-028] PAT-12
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:54`
- **Rule**: PAT-12
- **Finding**: Non-const range-for reference — may trigger COW detach; use const auto& if read-only
- **Mitigation**: The non-const references intentionally write a std::span-backed Gaussian kernel; this is not iteration over an implicitly shared Qt container.

#### [L-029] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:95`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-030] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskmath.cpp:106`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-031] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskshadow.cpp:32`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-032] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskshadow.cpp:34`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-033] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/blurmaskshadow.cpp:120`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-034] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/roundedrectshadow.cpp:63`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-035] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowgeometry.cpp:43`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-036] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowgeometry.cpp:48`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-037] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowgeometry.cpp:65`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-038] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowgeometry.cpp:66`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-039] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:229`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-040] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:231`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-041] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:232`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-042] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:233`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-043] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:317`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-044] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:320`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

#### [L-045] HDR-3
- **File**: `src/Qavsi/Material3/Style/internal/shadows/shadowmesh.cpp:324`
- **Rule**: HDR-3
- **Finding**: Unprotected std::min/max — use (std::min)(a,b) for Windows macro safety
- **Mitigation**: Portability advisory: protect min/max in a future Windows/unity-build pass. No introducing Windows macro include chain was verified; Windows execution is not claimed.

### Deep analysis findings

#### [D-001] Requested PNG output failures are not propagated
- **File**: `experiments/shadow-parity/main.cpp:291`
- **Category**: Error Handling & Validation
- **Confidence**: 99/100
- **Severity**: P3; archived diagnostic fixture only
- **Finding**: The requested snapshot directory and PNG save return values are not checked. An unwritable snapshot path can leave the pixel checks successful without the requested PNG artifacts.
- **Trace**: Optional mkpath is unchecked; both QImage::save results are discarded; final status counts numerical checks, warnings, exposure and JSON write, not PNG output.
- **Mitigation**: In the next mutable fixture revision, reject directory/save failures with nonzero status. Preserve the source hashes for already recorded runs. All committed paired images exist; the recorded parity results are not invalidated.

#### [D-002] Resume skips common result validation and aggregate rebuild
- **File**: `experiments/shadow-benchmark/run.py:54`
- **Category**: Error Handling & Validation
- **Confidence**: 95/100
- **Severity**: P3; archived diagnostic runner only
- **Finding**: Existing case files take an early continue before the validation and aggregate write shared by fresh runs. A completed resume can leave all-results.json missing or stale.
- **Trace**: The resume branch loads/appends and continues; backend/visibility/pixel validation and all-results.json update occur only after the fresh subprocess branch.
- **Mitigation**: A future mutable runner should validate and rebuild its aggregate after both branches. The archived 60-run aggregate and all individual cases were separately verified; do not interpret resume exit status alone as artifact validation.

### Investigation targets (human verification needed)

None above the configured threshold. Vulkan/Direct3D/GLES and unequal-corner performance remain unverified scope, not newly confirmed defects.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---:|---:|---:|---:|
| DEP-7 | 3 | 0 | 0 | 3 |
| DEP-10 | 1 | 0 | 0 | 1 |
| VAR-3 | 12 | 0 | 0 | 12 |
| HDR-3 | 27 | 0 | 0 | 27 |
| PAT-12 | 2 | 0 | 0 | 2 |
| Error Handling & Validation (archived tooling) | 0 | 2 | 0 | 2 |
| **Total** | **45** | **2** | **0** | **47** |

9 scanner matches on unchanged tracked lines were excluded from new findings. Raw full-file output is retained separately.

Six paired review missions were executed read-only in two waves constrained by the available worker slots.
