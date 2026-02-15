import QtQuick
import QtQuick.Controls

// EditorPane owns the central text editor surface.
// Responsibilities:
// - text editing UI
// - line-number gutter rendering
// - cursor/line metadata exposed to status bar
// - editor commands exposed as a small API used by menus
//
// Editing guideline:
// keep document/file logic outside this component; this module should remain
// focused on editing behavior and visual presentation.
Item {
    id: root

    property string text: ""
    property bool wordWrapEnabled: true
    property color editorBackgroundColor: "#ffffff"
    property color panelBackgroundColor: "#e9e9e9"
    property color foregroundColor: "#1f1f1f"
    property color selectionColor: "#3b82f6"
    property color gutterTextColor: "#666666"
    property color gutterDividerColor: "#d0d0d0"

    readonly property int totalLineCount: lineCountFromText(editor.text)
    readonly property int currentLineNumber: lineNumberAt(editor.cursorPosition)
    readonly property int currentColumnNumber: columnNumberAt(editor.cursorPosition)
    readonly property int gutterWidth: Math.max(44, (String(totalLineCount).length * 10) + 16)

    readonly property bool canUndo: editor.canUndo
    readonly property bool canRedo: editor.canRedo
    readonly property int cursorPosition: editor.cursorPosition
    readonly property int selectionStart: editor.selectionStart
    readonly property int selectionEnd: editor.selectionEnd
    readonly property string selectedText: editor.selectedText

    signal textEdited(string text)

    function undo() { editor.undo() }
    function redo() { editor.redo() }
    function cut() { editor.cut() }
    function copy() { editor.copy() }
    function paste() { editor.paste() }
    function selectAll() { editor.selectAll() }
    function focusEditor() { editor.forceActiveFocus() }
    function selectRange(start, end) { editor.select(start, end) }
    function replaceSelection(newText) {
        const start = editor.selectionStart
        editor.remove(editor.selectionStart, editor.selectionEnd)
        editor.insert(start, newText)
        editor.select(start, start + newText.length)
        editor.cursorPosition = start + newText.length
    }

    function lineCountFromText(value) {
        if (value.length === 0) {
            return 1
        }
        let count = 1
        for (let i = 0; i < value.length; ++i) {
            if (value[i] === "\n") {
                count += 1
            }
        }
        return count
    }

    function lineNumberAt(position) {
        const value = editor.text
        const end = Math.min(Math.max(position, 0), value.length)
        let line = 1
        for (let i = 0; i < end; ++i) {
            if (value[i] === "\n") {
                line += 1
            }
        }
        return line
    }

    function columnNumberAt(position) {
        const value = editor.text
        const safePos = Math.min(Math.max(position, 0), value.length)
        const lastNewLine = value.lastIndexOf("\n", Math.max(0, safePos - 1))
        return safePos - lastNewLine
    }

    function lineNumbersText() {
        let numbers = ""
        for (let i = 1; i <= totalLineCount; ++i) {
            if (i > 1) {
                numbers += "\n"
            }
            numbers += i
        }
        return numbers
    }

    TextArea {
        id: editor
        anchors.fill: parent
        text: root.text
        wrapMode: root.wordWrapEnabled ? TextArea.Wrap : TextArea.NoWrap
        selectByMouse: true
        font.family: "Consolas"
        font.pointSize: 11
        color: root.foregroundColor
        selectionColor: root.selectionColor
        selectedTextColor: "#ffffff"
        leftPadding: root.gutterWidth + 12
        rightPadding: 12
        topPadding: 12
        bottomPadding: 12
        background: Rectangle {
            color: root.editorBackgroundColor

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: root.gutterWidth
                color: root.panelBackgroundColor
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: root.gutterWidth - 1
                width: 1
                color: root.gutterDividerColor
            }

            Text {
                x: 0
                y: editor.topPadding
                width: root.gutterWidth - 8
                height: parent.height - editor.topPadding - editor.bottomPadding
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignTop
                color: root.gutterTextColor
                font.family: editor.font.family
                font.pointSize: editor.font.pointSize
                text: root.lineNumbersText()
            }
        }

        onTextChanged: {
            if (text !== root.text) {
                root.text = text
                root.textEdited(text)
            }
        }
    }
}
