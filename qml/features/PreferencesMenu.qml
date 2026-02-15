import QtQuick
import QtQuick.Controls

// PreferencesMenu currently owns theme selection only.
// Emit-only design keeps persistence and side effects in AppState/Main.
Menu {
    id: root
    title: qsTr("Preferences")

    required property bool darkTheme

    signal themeChanged(bool darkTheme)

    Menu {
        title: qsTr("Theme")
        Action {
            text: qsTr("Light")
            checkable: true
            checked: !root.darkTheme
            onTriggered: root.themeChanged(false)
        }
        Action {
            text: qsTr("Dark")
            checkable: true
            checked: root.darkTheme
            onTriggered: root.themeChanged(true)
        }
    }
}
