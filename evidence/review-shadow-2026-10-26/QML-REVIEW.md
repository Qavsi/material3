## QML Code Review Report

**Scope**: pending diff against a093a0e plus new files; changed tracked lines with surrounding context, full new files.
**Files reviewed**: 12
**Issues found**: 6 (6 deterministic lint advisories, 0 deep findings)
**qmllint**: module-aware source and relocated installed-comparison gates passed with the recorded source hashes.

No production correctness blocker was found. Advisory scans are not reported as warning-free.

### Lint findings

#### [L-001] STY-1
- **File**: `experiments/shadow-benchmark/ShadowCell.qml:6`
- **Rule**: STY-1
- **Finding**: Top-level component should have id: root (enables qualified lookup, future-proofs for QML 3)
- **Mitigation**: Use the conventional root id in a future mutable fixture; the recorded cell id is intentionally preserved with its source hash.

#### [L-002] ORD-1
- **File**: `experiments/shadow-benchmark/ShadowCell.qml:9`
- **Rule**: ORD-1
- **Finding**: property declaration appears after property assignment -- expected order: id, properties, signals, assignments, attached, states, transitions, handlers, children, functions
- **Mitigation**: Ordering-only advisory. Keep the recorded fixture and existing project conventions; no binding/type defect was found.

#### [L-003] STY-1
- **File**: `experiments/shadow-port-validation/ShadowCell.qml:7`
- **Rule**: STY-1
- **Finding**: Top-level component should have id: root (enables qualified lookup, future-proofs for QML 3)
- **Mitigation**: Use the conventional root id in a future mutable fixture; the recorded cell id is intentionally preserved with its source hash.

#### [L-004] ORD-1
- **File**: `experiments/shadow-port-validation/ShadowCell.qml:10`
- **Rule**: ORD-1
- **Finding**: property declaration appears after property assignment -- expected order: id, properties, signals, assignments, attached, states, transitions, handlers, children, functions
- **Mitigation**: Ordering-only advisory. Keep the recorded fixture and existing project conventions; no binding/type defect was found.

#### [L-005] ORD-1
- **File**: `src/Qavsi/Material3/Style/internal/shadows/Material3Elevation.qml:8`
- **Rule**: ORD-1
- **Finding**: property declaration appears after property assignment -- expected order: id, properties, signals, assignments, attached, states, transitions, handlers, children, functions
- **Mitigation**: Ordering-only advisory. Keep the recorded fixture and existing project conventions; no binding/type defect was found.

#### [L-006] BND-5
- **File**: `src/Qavsi/Material3/Theme/Material3Theme.qml:134`
- **Rule**: BND-5
- **Finding**: list<> property has no granular change signals -- add/move/remove won't notify; consider a ListModel or notify manually
- **Mitigation**: This readonly six-value easing list is consumed as a whole and is never mutated; granular list notifications are not required.

### Deep analysis findings

No additional confirmed QML semantic finding.

### Investigation targets (human verification needed)

None above the configured threshold. Vulkan/Direct3D/GLES and unequal-corner performance remain unverified scope, not newly confirmed defects.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---:|---:|---:|---:|
| STY-1 | 2 | 0 | 0 | 2 |
| ORD-1 | 3 | 0 | 0 | 3 |
| BND-5 | 1 | 0 | 0 | 1 |
| **Total** | **6** | **0** | **0** | **6** |

20 scanner matches on unchanged tracked lines were excluded from new findings. Raw full-file output is retained separately.

Six paired review missions were executed read-only in two waves constrained by the available worker slots.
