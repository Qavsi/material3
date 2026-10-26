// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

import QtQuick

// StyleKit instantiates this unbound factory in the native button's context.
QtObject {
    readonly property Component background: Component {
        Material3JoinedButtonBackground { }
    }
}
