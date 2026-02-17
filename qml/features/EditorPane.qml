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
    property int zoomPercent: 100
    property real baseFontPointSize: 11
    property color editorBackgroundColor: "#ffffff"
    property color panelBackgroundColor: "#e9e9e9"
    property color foregroundColor: "#1f1f1f"
    property color selectionColor: "#3b82f6"
    property color gutterTextColor: "#666666"
    property color gutterDividerColor: "#d0d0d0"
    property color scrollbarTrackColor: Qt.darker(panelBackgroundColor, 1.1)
    property color scrollbarThumbColor: Qt.lighter(gutterDividerColor, 1.1)
    property color scrollbarThumbHoverColor: Qt.lighter(scrollbarThumbColor, 1.2)

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
        const starts = [0]
        for (let i = 0; i < editor.text.length; ++i) {
            if (editor.text[i] === "\n") {
                starts.push(i + 1)
            }
        }

        // Touch width so this binding recomputes when wrap geometry changes.
        const _editorWidth = editor.width

        let numbers = ""
        for (let i = 0; i < starts.length; ++i) {
            if (i > 0) {
                numbers += "\n"
            }
            numbers += (i + 1)

            if (!root.wordWrapEnabled) {
                continue
            }

            const currentRect = editor.positionToRectangle(starts[i])
            let nextY = currentRect.y + currentRect.height
            if (i + 1 < starts.length) {
                nextY = editor.positionToRectangle(starts[i + 1]).y
            } else {
                const endRect = editor.positionToRectangle(editor.text.length)
                nextY = endRect.y + endRect.height
            }

            const lineHeight = Math.max(1, currentRect.height)
            const visualLines = Math.max(1, Math.round((nextY - currentRect.y) / lineHeight))
            for (let extra = 1; extra < visualLines; ++extra) {
                numbers += "\n"
            }
        }
        return numbers
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        padding: 0
        LayoutMirroring.enabled: false
        contentWidth: editor.width
        contentHeight: editor.height

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            parent: scrollView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 11
            contentItem: Rectangle {
                radius: 5
                color: parent.pressed ? root.scrollbarThumbHoverColor
                                      : (parent.hovered ? root.scrollbarThumbHoverColor : root.scrollbarThumbColor)
            }
            background: Rectangle {
                radius: 5
                color: root.scrollbarTrackColor
            }
        }

        ScrollBar.horizontal: ScrollBar {
            policy: root.wordWrapEnabled ? ScrollBar.AlwaysOff : ScrollBar.AsNeeded
            parent: scrollView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 11
            contentItem: Rectangle {
                radius: 5
                color: parent.pressed ? root.scrollbarThumbHoverColor
                                      : (parent.hovered ? root.scrollbarThumbHoverColor : root.scrollbarThumbColor)
            }
            background: Rectangle {
                radius: 5
                color: root.scrollbarTrackColor
            }
        }

        TextArea {
            id: editor
            text: root.text
            wrapMode: root.wordWrapEnabled ? TextArea.Wrap : TextArea.NoWrap
            width: root.wordWrapEnabled
                   ? scrollView.availableWidth
                   : Math.max(scrollView.availableWidth, contentWidth + leftPadding + rightPadding)
            height: Math.max(scrollView.availableHeight, contentHeight + topPadding + bottomPadding)
            selectByMouse: true
            font.family: "Consolas"
            font.pointSize: (root.baseFontPointSize * root.zoomPercent) / 100.0
            color: root.foregroundColor
            selectionColor: root.selectionColor
            selectedTextColor: "#ffffff"
            leftPadding: root.gutterWidth
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
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
                    y: editor.topPadding - ((scrollView.contentItem
                                             && scrollView.contentItem.contentY !== undefined)
                                            ? scrollView.contentItem.contentY : 0)
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
}
