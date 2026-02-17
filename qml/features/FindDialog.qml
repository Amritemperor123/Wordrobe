import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// FindDialog is a reusable presenter for search input.
// Search execution is delegated to Main via findNextRequested/findPreviousRequested.
Dialog {
    id: root
    title: qsTr("Find")
    modal: false
    width: 420

    property color headerBackgroundColor: "#e9e9e9"
    property color headerTextColor: "#1f1f1f"
    property alias findText: findField.text

    signal findPreviousRequested(string query)
    signal findNextRequested(string query)

    header: Rectangle {
        implicitHeight: 34
        color: root.headerBackgroundColor

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            text: root.title
            color: root.headerTextColor
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.SizeAllCursor
            property real pressX: 0
            property real pressY: 0

            onPressed: function(mouse) {
                pressX = mouse.x
                pressY = mouse.y
            }

            onPositionChanged: function(mouse) {
                if (!pressed) {
                    return
                }
                root.x += mouse.x - pressX
                root.y += mouse.y - pressY
            }
        }
    }

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
                text: qsTr("^")
                onClicked: root.findPreviousRequested(findField.text)
            }
            Button {
                text: qsTr("v")
                onClicked: root.findNextRequested(findField.text)
            }
            Button {
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }
}
