import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ReplaceDialog collects find/replace values and emits requested operations.
// Replace logic is intentionally kept outside so this dialog remains reusable.
Dialog {
    id: root
    title: qsTr("Replace")
    modal: false
    width: 460

    property alias findText: findField.text
    property alias replaceText: replaceField.text

    signal replaceNextRequested(string query, string replacement)
    signal replaceAllRequested(string query, string replacement)

    function focusInput() {
        findField.forceActiveFocus()
        findField.selectAll()
    }

    contentItem: ColumnLayout {
        spacing: 10

        TextField {
            id: findField
            Layout.fillWidth: true
            placeholderText: qsTr("Find text")
        }

        TextField {
            id: replaceField
            Layout.fillWidth: true
            placeholderText: qsTr("Replace with")
            onAccepted: root.replaceNextRequested(findField.text, text)
        }

        RowLayout {
            Layout.fillWidth: true
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("Replace Next")
                onClicked: root.replaceNextRequested(findField.text, replaceField.text)
            }
            Button {
                text: qsTr("Replace All")
                onClicked: root.replaceAllRequested(findField.text, replaceField.text)
            }
            Button {
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }
}
