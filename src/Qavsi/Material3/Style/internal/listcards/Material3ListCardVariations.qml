pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: registrations
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    default property list<QtObject> variations: [
        Material3ListVariation { name: "listOneLine"; lines: 1; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ListVariation { name: "listTwoLine"; lines: 2; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ListVariation { name: "listThreeLine"; lines: 3; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3CardVariation { name: "cardFilled"; kind: "filled"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3CardVariation { name: "cardElevated"; kind: "elevated"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3CardVariation { name: "cardOutlined"; kind: "outlined"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens }
    ]
}
