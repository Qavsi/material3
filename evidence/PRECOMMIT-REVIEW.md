# Pre-commit Qt review — 2026-10-26

Scope: current Qavsi Icons + Material3 changes only. Merce experiments and
unchanged vendored MCU implementations excluded. No native test rerun during
read-only review; successful source/installed Metal/software evidence is linked
in ICONS.md and RIPPLE-QCM.md. Six logical missions per Qt skill completed in
two waves under the three-worker concurrency limit.

## QML Code Review Report

**Scope**: modified/new own files in [files.json](review-2026-10-26/files.json).
**Files reviewed**: 31
**Issues found**: 80 raw lint flags;0 additional confirmed functional blockers.
**qmllint**: ran through module-aware CMake all_qmllint; clean.

### Lint findings

Complete file/line/rule/mitigation output: [qml-lint.log](review-2026-10-26/qml-lint.log).

| Rule | Flags |
|---|---:|
| BND-1 | 19 |
| BND-2 | 11 |
| BND-5 | 2 |
| ORD-1 | 32 |
| PRF-1 | 2 |
| PRF-3 | 2 |
| STY-1 | 10 |
| STY-3 | 2 |

Raw mechanical flags remain visible; this review does not rename them a clean
lint run. Existing project conventions and deliberate API choices are retained:
opaque provider appearance/JS recipe maps use var; internal animation state uses
imperative assignments with explicit binding restore; clipping and transparent
border rectangles serve visible geometry. Test assertions check QFile::open,
while the scanner flags the call pattern. Naming/order/style suggestions are
not mass-refactored as part of committing tested work. No production error is
silently waived by this statement; six semantic passes traced the actual paths.

### Deep analysis findings

No new confirmed functional finding above80 confidence. Each mission excluded
duplicates already present in deterministic lint output.

### Investigation targets (human verification needed)

#### [I-001] Stacked extended FAB sizing
- **File**: Material3ButtonContent.qml:40
- **Category**: Layout & Anchoring
- **Confidence**:75/100
- **Finding**: expandedExtent sums icon+spacing+label while TextUnderIcon uses a
  single GridLayout column. An explicitly stacked extended FAB may be wider
  than needed and retain a horizontal optical offset.
- **Unverified because**: no current caller uses this display mode; the kit's
  acceptance contract for stacked extended FAB is not established.
- **How to verify**: define that contract and add a targeted TextUnderIcon
  fixture before claiming this mode as reference-equivalent.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---:|---:|---:|---:|
| QML | 80 |0|1|81|

Findings below confidence60 were suppressed.

## Qt Code Review Report

**Scope**: modified/new own files in [files.json](review-2026-10-26/files.json).
**Files reviewed**: 19
**Issues found**: 56 raw lint flags;0 additional confirmed functional blockers.

### Lint findings

Complete file/line/rule/mitigation output: [cpp-lint.log](review-2026-10-26/cpp-lint.log).

| Rule | Flags |
|---|---:|
| DEP-10 | 33 |
| DEP-7 | 9 |
| ENM-2 | 2 |
| ENM-9 | 4 |
| ERR-1 | 2 |
| HDR-3 | 5 |
| VAR-3 | 1 |

Raw mechanical flags remain visible; this review does not rename them a clean
lint run. Existing project conventions and deliberate API choices are retained:
opaque provider appearance/JS recipe maps use var; internal animation state uses
imperative assignments with explicit binding restore; clipping and transparent
border rectangles serve visible geometry. Test assertions check QFile::open,
while the scanner flags the call pattern. Naming/order/style suggestions are
not mass-refactored as part of committing tested work. No production error is
silently waived by this statement; six semantic passes traced the actual paths.

### Deep analysis findings

No new confirmed functional finding above80 confidence. Each mission excluded
duplicates already present in deterministic lint output.

### Investigation targets (human verification needed)

#### [I-002] Test warning collector reentrancy
- **File**: icons/tests/checks.cpp:36,154,375
- **Category**: Thread Safety
- **Confidence**:75/100
- **Finding**: the process-wide message handler appends to a QStringList while
  test code iterates/joins it without a mutex. A render-thread warning could
  race those reads; Qt requires message handlers to be reentrant.
- **Unverified because**: no overlapping warning/read was observed in passed
  native gates; production registry/render code does not share this list.
- **How to verify**: inject worker warnings during collection or run TSan, then
  protect every list read/write with one mutex if concurrency is retained.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---:|---:|---:|---:|
| CPP | 56 |0|1|57|

Findings below confidence60 were suppressed.

## Completed deep-analysis missions

| Mission | QML | C++ | Result |
|---|---|---|---|
|1|Bindings/properties|Model contracts|No blockers; QAIM not present|
|2|Layout/anchoring|Ownership/lifecycle|No blockers; I-001|
|3|Loading/lifecycle|Thread safety|No blockers; I-002|
|4|Delegates/models|API/correctness|No blockers|
|5|States/structure|Errors/validation|No blockers|
|6|Performance/quality|Performance/quality|No blockers|

## Commit boundary verification

Color generation is staged independently of button recipes, Icons and ripple.
An exported HEAD+color-only snapshot was configured with examples OFF and color
tests ON, built and tested independently:2/2 PASS (291 color assertions plus4
utility assertions). The live worktree was never replaced by this snapshot.
Full combined working-tree gates were already completed in RIPPLE-QCM.md.
No appearance changed during commit preparation; the live UI had been shown.

Recipe tooling tests passed; generate.mjs --check verified all12 committed outputs.
