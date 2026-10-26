## Qt Code Review Report

**Scope**: pending diff against 3d56c86; changed tracked lines and complete new files
**Files reviewed**: 3
**Issues found**: 1 (1 lint, 0 deep)

---

### Lint findings

#### [L-001] DEP-7
- **File**: `examples/qmlmaterial-comparison/checks.cpp:307`
- **Rule**: DEP-7
- **Finding**: qMin/qMax/qBound — use (std::min)()/(std::max)()/std::clamp()
- **Mitigation**: Test-only max calculation uses the established Qt helper. A future convention cleanup can use std::max; result and bounds are unaffected.

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
| Nonblocking convention advisories | 1 | 0 | 0 | 1 |
| **Total** | **1** | **0** | **0** | **1** |

14 scanner matches on unchanged lines were excluded. Raw scanner output is retained; this is not a claim of warning-free deterministic lint.
