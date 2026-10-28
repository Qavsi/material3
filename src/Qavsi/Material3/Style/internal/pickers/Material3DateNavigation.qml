// QmlMaterial 0.6.1 (1912605, MIT): month header, year grid and month grid.
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3DatePicker picker
    readonly property Material3Theme tokens: picker.tokens
    spacing: 0

    Item {
        id: header
        width: root.width
        height: root.tokens.pickerNavigationHeight
        SK.Button {
            id: title
            anchors.left: parent.left
            anchors.leftMargin: root.tokens.pickerNavigationPadding
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, Math.max(0, previous.x - x - root.tokens.pickerNavigationGap))
            SK.StyleVariation.variations: ["ghost"]
            text: root.picker.makeDate(root.picker.year, root.picker.month, 1).toLocaleDateString(root.picker.locale, root.picker.monthTitleFormat)
            icon.name: root.picker.navigation === Material3DatePicker.Days ? "material:expand_more" : "material:expand_less"
            icon.width: root.tokens.smallIconSize
            icon.height: root.tokens.smallIconSize
            font: root.tokens.labelLarge
            Accessible.name: qsTr("Choose month and year")
            Accessible.description: text
            Accessible.expanded: root.picker.navigation !== Material3DatePicker.Days
            contentItem: Material3ButtonContent { control: title }
            onClicked: root.picker.toggleNavigation()
        }
        SK.Button {
            id: previous
            anchors.right: next.left
            anchors.rightMargin: root.tokens.pickerNavigationGap
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "material:chevron_left"
            Accessible.name: qsTr("Previous month")
            SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
            contentItem: Material3ButtonContent { control: previous }
            enabled: root.picker.monthEnabled(root.picker.month === 0 ? root.picker.year - 1 : root.picker.year, (root.picker.month + 11) % 12)
            onClicked: root.picker.shiftMonth(-1)
        }
        SK.Button {
            id: next
            anchors.right: parent.right
            anchors.rightMargin: root.tokens.pickerNavigationPadding
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "material:chevron_right"
            Accessible.name: qsTr("Next month")
            SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
            contentItem: Material3ButtonContent { control: next }
            enabled: root.picker.monthEnabled(root.picker.month === 11 ? root.picker.year + 1 : root.picker.year, (root.picker.month + 1) % 12)
            onClicked: root.picker.shiftMonth(1)
        }
    }
    GridView {
        id: years
        objectName: "datePickerYears"
        width: root.width
        height: root.tokens.pickerYearGridHeight
        visible: root.picker.navigation === Material3DatePicker.Years
        clip: true
        cellWidth: width / root.tokens.pickerNavigationColumns
        cellHeight: root.tokens.pickerYearCellHeight
        model: Math.max(0, root.picker.lastYear - root.picker.firstYear + 1)
        currentIndex: Math.max(0, Math.min(count - 1, root.picker.year - root.picker.firstYear))
        onVisibleChanged: { if (visible) positionViewAtIndex(currentIndex, GridView.Center); }
        delegate: SK.Button {
            id: yearButton
            required property int index
            readonly property int yearValue: root.picker.firstYear + index
            objectName: "datePickerYear" + yearValue
            width: years.cellWidth
            height: years.cellHeight
            text: String(yearValue)
            checked: yearValue === root.picker.year
            Accessible.selected: checked
            SK.StyleVariation.variations: ["pickerNavigationItem"]
            contentItem: Material3ButtonContent { control: yearButton }
            onClicked: root.picker.selectYear(yearValue)
        }
    }
    Grid {
        width: root.width
        visible: root.picker.navigation === Material3DatePicker.Months
        columns: root.tokens.pickerNavigationColumns
        Repeater {
            model: 12
            delegate: SK.Button {
                id: monthButton
                required property int index
                objectName: "datePickerMonth" + index
                width: root.width / root.tokens.pickerNavigationColumns
                height: root.tokens.pickerMonthCellHeight
                leftPadding: root.tokens.spacingSmall
                rightPadding: root.tokens.spacingSmall
                text: root.picker.locale.standaloneMonthName(index, Locale.LongFormat)
                enabled: root.picker.monthEnabled(root.picker.year, index)
                checked: index === root.picker.month
                Accessible.selected: checked
                SK.StyleVariation.variations: ["pickerNavigationItem"]
                contentItem: Material3ButtonContent { control: monthButton }
                onClicked: root.picker.selectMonth(index)
            }
        }
    }
}
