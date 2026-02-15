import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// StatusBarPane renders document metadata at the bottom of the window.
// Inputs are passed in as properties so this component stays stateless.
ToolBar {
    id: root

    property string filePath: ""
    property bool modified: false
    property int currentLineNumber: 1
    property int currentColumnNumber: 1
    property int totalLineCount: 1
    property color panelBackgroundColor: "#e9e9e9"
    property color foregroundColor: "#1f1f1f"

    background: Rectangle {
        color: root.panelBackgroundColor
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Label {
            text: root.filePath === "" ? "Unsaved document" : root.filePath
            Layout.fillWidth: true
            elide: Label.ElideRight
            color: root.foregroundColor
        }
        Label {
            text: "Ln " + root.currentLineNumber + ", Col " + root.currentColumnNumber
            color: root.foregroundColor
        }
        Label {
            text: "Lines " + root.totalLineCount
            color: root.foregroundColor
        }
        Label {
            text: root.modified ? "Modified" : "Saved"
            color: root.foregroundColor
        }
    }
}
