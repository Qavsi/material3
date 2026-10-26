# Material Color Utilities — private subset

Source: https://github.com/material-foundation/material-color-utilities
Pinned revision: ca894db8b6aebb2833f1805ae61573c92e3f1660
License: Apache-2.0, see LICENSE and preserved headers.

Neutral/TonalSpot seed-only transitive closure:29 files,13 compilation units.
No network fetch at configure/build. OBJECTs are PIC with hidden visibility;
they are compiled into QavsiMaterial3Theme and never exported as an MCU target.
No installed consumer needs these sources or headers.

Local changes are marked in the files: C++ aggregate initialization for MSVC,
standard pi constant, optional include if needed, and std::to_chars instead of
Abseil string formatting. All upstream/local hashes are in provenance.json.
The 20 used semantic roles are tested against actual QCM MdColorMgr outputs at
the matching MCU algorithm revision. Update revision, hashes and independent
goldens together; never regenerate expected values from Qavsi itself.
