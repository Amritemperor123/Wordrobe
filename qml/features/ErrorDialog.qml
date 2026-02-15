import QtQuick
import QtQuick.Controls

// ErrorDialog is a generic modal message surface for file-operation failures.
// Callers set `errorText` and open it when needed.
Dialog {
    id: root
    modal: true
    title: qsTr("File Error")
    standardButtons: Dialog.Ok
    width: 420

    property string errorText: ""
    property color foregroundColor: "#1f1f1f"

    contentItem: Label {
        text: root.errorText
        wrapMode: Label.Wrap
        padding: 12
        color: root.foregroundColor
    }
}
