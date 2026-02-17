import QtQuick
import QtQuick.Controls

// PreferencesMenu currently owns theme selection only.
// Emit-only design keeps persistence and side effects in AppState/Main.
Menu {
    id: root
    title: qsTr("Preferences")

    required property bool darkTheme
    required property bool statusBarVisible
    required property int zoomPercent

    signal themeChanged(bool darkTheme)
    signal statusBarVisibilityChanged(bool visible)
    signal zoomInRequested()
    signal zoomOutRequested()

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

    MenuSeparator {}

    Action {
        text: qsTr("Show Status Bar")
        checkable: true
        checked: root.statusBarVisible
        onTriggered: root.statusBarVisibilityChanged(checked)
    }

    MenuSeparator {}

    Action {
        text: qsTr("Zoom In")
        enabled: root.zoomPercent < 200
        onTriggered: root.zoomInRequested()
    }
    Action {
        text: qsTr("Zoom Out")
        enabled: root.zoomPercent > 50
        onTriggered: root.zoomOutRequested()
    }
}
