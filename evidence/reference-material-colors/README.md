# Actual QCM color reference probe

These are the exact sources used to record ../material-color-reference.json.
They link the existing pinned QCM build and instantiate its actual MdColorMgr.
No Qavsi color algorithm is used to generate expected colors. Source and CMake
hashes match the recorded reference. CMake contains this run's local checkout
paths; adjust those paths when reproducing on another machine. This probe is
evidence only and is never added to the kit/consumer build or installed package.
