import QtQuick
import QtQuick.Controls

// FileMenu provides file-related actions and emits intent signals.
// It does not call C++ document APIs directly; Main.qml owns routing.
// This keeps menu presentation separate from document behavior.
Menu {
    id: root
    title: qsTr("File")

    required property var recentFilesModel
    required property var displayNameForPath

    signal newRequested()
    signal openRequested()
    signal openRecentRequested(string path)
    signal clearRecentRequested()
    signal saveRequested()
    signal saveAsRequested()
    signal exitRequested()

    Action {
        text: qsTr("New")
        shortcut: StandardKey.New
        onTriggered: root.newRequested()
    }
    Action {
        text: qsTr("Open...")
        shortcut: StandardKey.Open
        onTriggered: root.openRequested()
    }

    Menu {
        id: recentFilesMenu
        title: qsTr("Recent Files")
        enabled: root.recentFilesModel.count > 0

        Instantiator {
            model: root.recentFilesModel
            delegate: MenuItem {
                required property int index
                required property string path
                text: (index + 1) + ". " + root.displayNameForPath(path)
                onTriggered: root.openRecentRequested(path)
            }
            onObjectAdded: function(index, object) {
                recentFilesMenu.insertItem(index, object)
            }
            onObjectRemoved: function(index, object) {
                recentFilesMenu.removeItem(object)
            }
        }

        MenuSeparator {
            visible: root.recentFilesModel.count > 0
        }

        MenuItem {
            text: qsTr("Clear Recent Files")
            enabled: root.recentFilesModel.count > 0
            onTriggered: root.clearRecentRequested()
        }
    }

    MenuSeparator {}

    Action {
        text: qsTr("Save")
        shortcut: StandardKey.Save
        onTriggered: root.saveRequested()
    }
    Action {
        text: qsTr("Save As...")
        shortcut: StandardKey.SaveAs
        onTriggered: root.saveAsRequested()
    }

    MenuSeparator {}

    Action {
        text: qsTr("Exit")
        shortcut: StandardKey.Quit
        onTriggered: root.exitRequested()
    }
}
