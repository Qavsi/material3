# Shadow precommit review — 2026-10-26

Scope: Qavsi Material3 pending shadow changes and reproducible experiment artifacts.
Qt QML/C++ review skills ran deterministic lint, existing module-aware qmllint
verification, six paired read-only deep review missions, and consolidation.
The tool capacity required two waves instead of six simultaneous workers.

| Mission | Paired focus | Confirmed deep findings | Investigations |
|---|---|---:|---:|
| 1 | Bindings & Properties / Model Contracts | 0 | 0 |
| 2 | Layout & Anchoring / API & C++ Correctness | 0 | 0 |
| 3 | Loading & Lifecycle / Ownership | 0 | 0 |
| 4 | Delegates / Thread Safety | 0 | 0 |
| 5 | States & Structure / Error Validation | 2 P3 archived-harness findings | 0 |
| 6 | Performance & Quality | 0 | 0 |

Production correctness blockers: **0**. Two P3 findings are preserved in the
archived diagnostic fixtures, with mitigations and artifact checks. Frozen
measurement source code was not silently rewritten to clean up warnings.
The deterministic scans produced 6 QML and 45 C++ in-scope advisories;
51 raw-rule matches were not represented as a clean lint pass. The full
module-aware qmllint gates passed. See [QML review](QML-REVIEW.md),
[C++ review](CPP-REVIEW.md), raw lint outputs, and scope.json.

Reviewed verification: source ctest4/4; comparison software589/Metal620/OpenGL620;
relocated installed comparison software589/Metal620 and Small software159;
native Elevated/FAB halo matches one helper with RGBA error0; independent
Metal/OpenGL primitive parity and source hashes match the recorded evidence.
Three shader files had terminal blank lines removed during final whitespace
checks. A rebuild confirmed every QSB shader asset is byte-identical; source
ctest passed again4/4. The original native/parity evidence therefore covers
the same compiled shaders. Current source hashes and before/after hashes
are recorded separately. Native UI had already been shown on the left display
before the user's commit authorization.

The original generated benchmark CMake cache retains its terminal blank line
as an archived raw build artifact. The raw Qt test log likewise preserves
Qt font diagnostic trailing spaces. Source-code whitespace checks pass;
these verbatim outputs are intentionally not normalized.
