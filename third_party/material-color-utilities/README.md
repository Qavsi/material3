# Material Color Utilities — private subset

Source: https://github.com/material-foundation/material-color-utilities
Pinned revision: ca894db8b6aebb2833f1805ae61573c92e3f1660
License: Apache-2.0, see LICENSE and preserved headers.

All nine seed-scheme transitive closure: 47 files, 22 compilation units.
Neutral/TonalSpot retain their existing public enum values; Rainbow, Monochrome,
Vibrant, Content, Fidelity, Expressive and FruitSalad add their scheme sources.
Temperature harmony uses the small Lab conversion pair under cpp/quantize;
no image quantizer, score or image extraction pipeline is included.
No network fetch occurs at configure/build. OBJECTs are PIC with hidden visibility;
they are compiled into QavsiMaterial3Theme and never exported as an MCU target.
No installed consumer needs these sources or headers.

Local changes are marked in the files: C++ aggregate initialization for MSVC,
standard pi constant, explicit optional headers and std::to_chars instead of
Abseil string formatting. All upstream/local hashes are in provenance.json.
The 34 semantic roles are tested against actual QCM MdColorMgr outputs at the
matching MCU algorithm revision: three seeds, nine schemes, both modes. Update
revision, hashes and independent goldens together; never generate expected
values from Qavsi itself. QCM fixes contrast to 0; its oracle does not claim
nonzero-contrast parity.
