import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "features" as Features

// Main.qml is the UI composition root.
// It wires feature modules together, connects them to `document` (C++),
// and keeps cross-feature orchestration logic (save/find/replace flows).
//
// Editing guideline:
// - add visual/interaction features in `qml/features/*`
// - keep this file focused on wiring, not feature internals
ApplicationWindow {
    id: root
    width: 900
    height: 640
    visible: true
    title: (document.modified ? "* " : "") + document.displayName + " - Wordrobe"

    AppState {
        id: appState
    }

    color: appState.windowBackgroundColor
    palette.window: appState.windowBackgroundColor
    palette.windowText: appState.foregroundColor
    palette.base: appState.editorBackgroundColor
    palette.text: appState.foregroundColor
    palette.button: appState.panelBackgroundColor
    palette.buttonText: appState.foregroundColor
    palette.highlight: appState.selectionColor
    palette.highlightedText: "#ffffff"

    function saveDocument() {
        // Save is routed through a single function so menus/shortcuts share behavior.
        if (document.filePath === "") {
            saveDialog.open()
            return
        }
        if (document.save()) {
            appState.addRecentFile(document.filePath)
        }
    }

    function findNext(query, fromPosition) {
        // Wrap-around search: if not found after cursor, retry from start.
        if (query === "") {
            return false
        }

        const textValue = editorPane.text
        const start = fromPosition !== undefined ? fromPosition : editorPane.selectionEnd
        let index = textValue.indexOf(query, Math.max(0, start))
        if (index === -1 && start > 0) {
            index = textValue.indexOf(query, 0)
        }
        if (index === -1) {
            return false
        }

        editorPane.selectRange(index, index + query.length)
        editorPane.focusEditor()
        return true
    }

    function replaceNext(query, replacement) {
        if (query === "") {
            return false
        }

        if (editorPane.selectedText !== query) {
            if (!findNext(query)) {
                return false
            }
        }

        if (editorPane.selectedText === query) {
            editorPane.replaceSelection(replacement)
            editorPane.focusEditor()
            return true
        }
        return false
    }

    function replaceAll(query, replacement) {
        if (query === "") {
            return 0
        }

        let value = editorPane.text
        let count = 0
        let index = value.indexOf(query)
        while (index !== -1) {
            value = value.slice(0, index) + replacement + value.slice(index + query.length)
            count += 1
            index = value.indexOf(query, index + replacement.length)
        }

        if (count > 0) {
            editorPane.text = value
            editorPane.focusEditor()
        }
        return count
    }

    menuBar: MenuBar {
        Features.FileMenu {
            recentFilesModel: appState.recentFilesModel
            displayNameForPath: appState.displayNameForPath
            onNewRequested: document.newDocument()
            onOpenRequested: openDialog.open()
            onOpenRecentRequested: function(path) {
                if (document.openFromPath(path)) {
                    appState.addRecentFile(document.filePath)
                }
            }
            onClearRecentRequested: appState.clearRecentFiles()
            onSaveRequested: root.saveDocument()
            onSaveAsRequested: saveDialog.open()
            onExitRequested: Qt.quit()
        }

        Features.EditMenu {
            editor: editorPane
            wordWrapEnabled: appState.wordWrapEnabled
            onFindRequested: {
                if (editorPane.selectedText !== "") {
                    findDialog.findText = editorPane.selectedText
                }
                findDialog.open()
                findDialog.focusInput()
            }
            onReplaceRequested: {
                if (editorPane.selectedText !== "") {
                    replaceDialog.findText = editorPane.selectedText
                }
                replaceDialog.open()
                replaceDialog.focusInput()
            }
            onWordWrapToggled: function(enabled) {
                appState.wordWrapEnabled = enabled
            }
        }

        Features.PreferencesMenu {
            darkTheme: appState.darkTheme
            onThemeChanged: function(darkTheme) {
                appState.darkTheme = darkTheme
            }
        }
    }

    Features.FindDialog {
        id: findDialog
        onFindNextRequested: function(query) {
            root.findNext(query)
        }
    }

    Features.ReplaceDialog {
        id: replaceDialog
        onReplaceNextRequested: function(query, replacement) {
            root.replaceNext(query, replacement)
        }
        onReplaceAllRequested: function(query, replacement) {
            root.replaceAll(query, replacement)
        }
    }

    FileDialog {
        id: openDialog
        title: qsTr("Open File")
        fileMode: FileDialog.OpenFile
        nameFilters: ["Text Files (*.txt)", "All Files (*)"]
        onAccepted: {
            if (document.openFromPath(selectedFile.toString())) {
                appState.addRecentFile(document.filePath)
            }
        }
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save File As")
        fileMode: FileDialog.SaveFile
        nameFilters: ["Text Files (*.txt)", "All Files (*)"]
        onAccepted: {
            if (document.saveAs(selectedFile.toString())) {
                appState.addRecentFile(document.filePath)
            }
        }
    }

    Features.ErrorDialog {
        id: errorDialog
        errorText: document.lastError
        foregroundColor: appState.foregroundColor
    }

    Connections {
        target: document
        function onTextChanged() {
            if (editorPane.text !== document.text) {
                editorPane.text = document.text
            }
        }
        function onLastErrorChanged() {
            if (document.lastError !== "") {
                errorDialog.open()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Features.EditorPane {
            id: editorPane
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: ""
            wordWrapEnabled: appState.wordWrapEnabled
            editorBackgroundColor: appState.editorBackgroundColor
            panelBackgroundColor: appState.panelBackgroundColor
            foregroundColor: appState.foregroundColor
            selectionColor: appState.selectionColor
            gutterTextColor: appState.gutterTextColor
            gutterDividerColor: appState.gutterDividerColor
            onTextEdited: function(value) {
                if (value !== document.text) {
                    document.text = value
                }
            }
        }

        Features.StatusBarPane {
            Layout.fillWidth: true
            filePath: document.filePath
            modified: document.modified
            currentLineNumber: editorPane.currentLineNumber
            currentColumnNumber: editorPane.currentColumnNumber
            totalLineCount: editorPane.totalLineCount
            panelBackgroundColor: appState.panelBackgroundColor
            foregroundColor: appState.foregroundColor
        }
    }
}
