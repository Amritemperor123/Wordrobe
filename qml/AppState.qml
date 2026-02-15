import QtQuick
import QtCore

// AppState centralizes persistent UI settings and shared app-wide state.
// Current responsibilities:
// - theme + word-wrap persistence
// - recent-files list management and persistence
// - shared color tokens consumed by feature components
//
// Editing guideline:
// add new persistent preferences here, and expose simple properties/functions
// so feature modules remain presentation-focused.
Item {
    id: root
    visible: false
    width: 0
    height: 0

    property int maxRecentFiles: 10
    property bool darkTheme: false
    property bool wordWrapEnabled: true

    property color windowBackgroundColor: darkTheme ? "#202124" : "#f5f5f5"
    property color panelBackgroundColor: darkTheme ? "#2b2d31" : "#e9e9e9"
    property color editorBackgroundColor: darkTheme ? "#1a1b1e" : "#ffffff"
    property color foregroundColor: darkTheme ? "#f1f3f4" : "#1f1f1f"
    property color selectionColor: darkTheme ? "#4d8dff" : "#3b82f6"
    property color gutterTextColor: darkTheme ? "#9aa1ad" : "#666666"
    property color gutterDividerColor: darkTheme ? "#3a3f46" : "#d0d0d0"

    property alias recentFilesModel: recentFilesModel

    Settings {
        id: settings
        category: "Appearance"
        property bool darkTheme: false
        property bool wordWrapEnabled: true
        property string recentFilesJson: "[]"
    }

    ListModel {
        id: recentFilesModel
    }

    Component.onCompleted: {
        root.darkTheme = settings.darkTheme
        root.wordWrapEnabled = settings.wordWrapEnabled
        root.loadRecentFiles()
    }

    onDarkThemeChanged: {
        settings.darkTheme = root.darkTheme
    }

    onWordWrapEnabledChanged: {
        settings.wordWrapEnabled = root.wordWrapEnabled
    }

    function displayNameForPath(path) {
        const normalized = String(path).replace(/\\/g, "/")
        const parts = normalized.split("/")
        return parts.length > 0 ? parts[parts.length - 1] : path
    }

    function persistRecentFiles() {
        const paths = []
        for (let i = 0; i < recentFilesModel.count; ++i) {
            paths.push(recentFilesModel.get(i).path)
        }
        settings.recentFilesJson = JSON.stringify(paths)
    }

    function loadRecentFiles() {
        recentFilesModel.clear()
        let parsed = []
        try {
            parsed = JSON.parse(settings.recentFilesJson)
        } catch (e) {
            parsed = []
        }

        for (let i = 0; i < parsed.length; ++i) {
            const path = String(parsed[i])
            if (path !== "") {
                recentFilesModel.append({ "path": path })
            }
        }
    }

    function addRecentFile(path) {
        const value = String(path)
        if (value === "") {
            return
        }

        for (let i = 0; i < recentFilesModel.count; ++i) {
            if (recentFilesModel.get(i).path === value) {
                recentFilesModel.remove(i)
                break
            }
        }

        recentFilesModel.insert(0, { "path": value })

        while (recentFilesModel.count > root.maxRecentFiles) {
            recentFilesModel.remove(recentFilesModel.count - 1)
        }
        root.persistRecentFiles()
    }

    function clearRecentFiles() {
        recentFilesModel.clear()
        root.persistRecentFiles()
    }
}
