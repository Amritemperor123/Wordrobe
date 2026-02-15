import QtQuick
import QtQuick.Controls

// EditMenu exposes editing commands and shortcuts.
// It receives an editor-like object via `editor` and emits high-level
// signals for dialogs/toggles handled by Main.qml.
Menu {
    id: root
    title: qsTr("Edit")

    required property var editor
    required property bool wordWrapEnabled

    signal findRequested()
    signal replaceRequested()
    signal wordWrapToggled(bool enabled)

    Action {
        text: qsTr("Undo")
        shortcut: "Ctrl+Z"
        enabled: root.editor.canUndo
        onTriggered: root.editor.undo()
    }
    Action {
        text: qsTr("Redo")
        shortcut: "Ctrl+Y"
        enabled: root.editor.canRedo
        onTriggered: root.editor.redo()
    }

    MenuSeparator {}

    Action {
        text: qsTr("Cut")
        shortcut: "Ctrl+X"
        onTriggered: root.editor.cut()
    }
    Action {
        text: qsTr("Copy")
        shortcut: "Ctrl+C"
        onTriggered: root.editor.copy()
    }
    Action {
        text: qsTr("Paste")
        shortcut: "Ctrl+V"
        onTriggered: root.editor.paste()
    }
    Action {
        text: qsTr("Select All")
        shortcut: "Ctrl+A"
        onTriggered: root.editor.selectAll()
    }

    MenuSeparator {}

    Action {
        text: qsTr("Find")
        shortcut: "Ctrl+F"
        onTriggered: root.findRequested()
    }
    Action {
        text: qsTr("Replace")
        shortcut: "Ctrl+H"
        onTriggered: root.replaceRequested()
    }

    MenuSeparator {}

    Action {
        text: qsTr("Word Wrap")
        shortcut: "Ctrl+W"
        checkable: true
        checked: root.wordWrapEnabled
        onTriggered: root.wordWrapToggled(!root.wordWrapEnabled)
    }
}
