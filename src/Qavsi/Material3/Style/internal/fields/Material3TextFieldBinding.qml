pragma ComponentBehavior: Bound
import QtQuick

Binding {
    id: root
    required property var defaultValue
    property bool requested: true
    property bool managed: false
    property bool ready: false
    property bool applying: false
    readonly property var currentValue: target ? target[property] : undefined
    property bool atDefault: currentValue === defaultValue
    when: ready && applying
    function updateRequested(): void {
        if (!root.ready)
            return
        if (!root.requested || !root.managed)
            root.applying = false
        else if (!root.applying) {
            root.managed = root.atDefault
            root.applying = root.managed
        }
    }
    onRequestedChanged: updateRequested()
    Component.onCompleted: {
        // shortcut: an initial binding equal to the style default is indistinguishable; nondefault geometry stays caller-owned.
        managed = atDefault
        ready = true
        updateRequested()
    }
    Component.onDestruction: applying = false
    onCurrentValueChanged: {
        if (root.when && root.target && root.currentValue !== root.value) {
            // A later caller assignment owns the property from this point on.
            root.restoreMode = Binding.RestoreNone
            root.managed = false
            root.applying = false
        }
    }
}
