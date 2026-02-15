import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// FindDialog is a reusable presenter for search input.
// Search execution is delegated to Main via `findNextRequested`.
Dialog {
    id: root
    title: qsTr("Find")
    modal: false
    width: 420

    property alias findText: findField.text

    signal findNextRequested(string query)

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
            onAccepted: root.findNextRequested(text)
        }

        RowLayout {
            Layout.fillWidth: true
            Item {
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("Find Next")
                onClicked: root.findNextRequested(findField.text)
            }
            Button {
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }
}
