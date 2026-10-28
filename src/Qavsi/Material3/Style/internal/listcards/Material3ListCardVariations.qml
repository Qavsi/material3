pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: registrations
    required property var sourceStyle
    default property list<QtObject> variations: [
        Material3ListVariation { name: "listOneLine"; lines: 1; sourceStyle: registrations.sourceStyle },
        Material3ListVariation { name: "listTwoLine"; lines: 2; sourceStyle: registrations.sourceStyle },
        Material3ListVariation { name: "listThreeLine"; lines: 3; sourceStyle: registrations.sourceStyle },
        Material3CardVariation { name: "cardFilled"; kind: "filled"; sourceStyle: registrations.sourceStyle },
        Material3CardVariation { name: "cardElevated"; kind: "elevated"; sourceStyle: registrations.sourceStyle },
        Material3CardVariation { name: "cardOutlined"; kind: "outlined"; sourceStyle: registrations.sourceStyle }
    ]
}
