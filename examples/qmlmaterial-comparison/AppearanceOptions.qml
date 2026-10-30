// QCM reference inputs, not control styling colors.
import QtQuick
import Qavsi.Material3.Theme

QtObject {
    readonly property color defaultSeedColor: "#bee7fd"
    readonly property var schemes: [
        { key: "neutral", label: qsTr("Neutral"), value: MaterialColorScheme.Neutral },
        { key: "rainbow", label: qsTr("Rainbow"), value: MaterialColorScheme.Rainbow },
        { key: "tonalSpot", label: qsTr("Tonal spot"), value: MaterialColorScheme.TonalSpot },
        { key: "monochrome", label: qsTr("Monochrome"), value: MaterialColorScheme.Monochrome },
        { key: "vibrant", label: qsTr("Vibrant"), value: MaterialColorScheme.Vibrant },
        { key: "content", label: qsTr("Content"), value: MaterialColorScheme.Content },
        { key: "fidelity", label: qsTr("Fidelity"), value: MaterialColorScheme.Fidelity },
        { key: "expressive", label: qsTr("Expressive"), value: MaterialColorScheme.Expressive },
        { key: "fruitSalad", label: qsTr("Fruit salad"), value: MaterialColorScheme.FruitSalad }
    ]
    readonly property var seeds: [
        { key: "red", label: qsTr("Red"), color: "#f44336" },
        { key: "pink", label: qsTr("Pink"), color: "#e91e63" },
        { key: "purple", label: qsTr("Purple"), color: "#9c27b0" },
        { key: "indigo", label: qsTr("Indigo"), color: "#3f51b5" },
        { key: "teal", label: qsTr("Teal"), color: "#009688" },
        { key: "lightGreen", label: qsTr("Light green"), color: "#8bc34a" },
        { key: "yellow", label: qsTr("Yellow"), color: "#ffeb3b" },
        { key: "amber", label: qsTr("Amber"), color: "#ffc107" },
        { key: "orange", label: qsTr("Orange"), color: "#ff9800" }
    ]
}
