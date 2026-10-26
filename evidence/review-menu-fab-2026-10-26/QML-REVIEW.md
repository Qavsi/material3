## QML Code Review Report

**Scope**: pending diff against 3d56c86; changed tracked lines and complete new files
**Files reviewed**: 8
**Issues found**: 3 (3 lint, 0 deep)
**qmllint**: module-aware all_qmllint passed; installed consumer lint also passed

---

### Lint findings

#### [L-001] ORD-1
- **File**: `src/Qavsi/Material3/Style/Material3Style.qml:92`
- **Rule**: ORD-1
- **Finding**: property assignment appears after child object -- expected order: id, properties, signals, assignments, attached, states, transitions, handlers, children, functions
- **Mitigation**: Grouping-order advisory; StyleKit grouped control mappings follow the existing composition-root convention. No binding/type problem found.

#### [L-002] STY-1
- **File**: `src/Qavsi/Material3/Style/internal/menus/Material3MenuDelegate.qml:4`
- **Rule**: STY-1
- **Finding**: Top-level component should have id: root (enables qualified lookup, future-proofs for QML 3)
- **Mitigation**: Internal factory/data objects do not reference their own id. Adding an unused root id is not required for the existing typed context.

#### [L-003] STY-1
- **File**: `src/Qavsi/Material3/Style/internal/menus/Material3MenuParameters.qml:4`
- **Rule**: STY-1
- **Finding**: Top-level component should have id: root (enables qualified lookup, future-proofs for QML 3)
- **Mitigation**: Internal factory/data objects do not reference their own id. Adding an unused root id is not required for the existing typed context.

---

### Deep analysis findings

No confirmed semantic finding above 80/100 in the six paired missions.

---

### Investigation targets (human verification needed)

None.

---

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---:|---:|---:|---:|
| Nonblocking convention advisories | 3 | 0 | 0 | 3 |
| **Total** | **3** | **0** | **0** | **3** |

27 scanner matches on unchanged lines were excluded. Raw scanner output is retained; this is not a claim of warning-free deterministic lint.
