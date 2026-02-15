# Wordrobe

A modular Qt Quick Notepad application built with **Qt 6 + CMake**.

Wordrobe started from a basic Qt template and has been refactored into feature-based modules so each part of the app is easier to maintain, extend, and debug.

## Features

- Create, open, edit, and save text files
- Save As support
- Recent files list (persisted across restarts)
- Theme switching: Light / Dark (persisted)
- Edit menu actions:
  - Undo (`Ctrl+Z`)
  - Redo (`Ctrl+Y`)
  - Cut (`Ctrl+X`)
  - Copy (`Ctrl+C`)
  - Paste (`Ctrl+V`)
  - Select All (`Ctrl+A`)
  - Find (`Ctrl+F`)
  - Replace (`Ctrl+H`)
  - Word Wrap toggle (`Ctrl+W`, persisted)
- IDE-style line numbers in the editor gutter
- Bottom status metadata:
  - File path
  - Current line/column
  - Total line count
  - Modified/Saved state

## Tech Stack

- Qt 6 (Qt Quick / Qt Quick Controls / Qt Core)
- C++ backend for document/file I/O
- QML frontend with feature modules
- CMake build system

## Project Structure

```text
Wordrobe/
  src/
    main.cpp
    document/
      notepaddocument.h
      notepaddocument.cpp

  qml/
    Main.qml                # Composition root (feature wiring)
    AppState.qml            # Persistent UI/app state
    features/
      FileMenu.qml
      EditMenu.qml
      PreferencesMenu.qml
      EditorPane.qml
      StatusBarPane.qml
      FindDialog.qml
      ReplaceDialog.qml
      ErrorDialog.qml

  CMakeLists.txt
  .gitignore
```

## Architecture Overview

- `NotepadDocument` (`src/document`) is the non-UI document service.
  - Owns text, file path, modified state, and file I/O.
  - Exposed to QML as `document`.

- `qml/Main.qml` is the UI composition root.
  - Wires feature modules together.
  - Handles cross-feature orchestration (save/find/replace flow).

- `qml/AppState.qml` is shared app state.
  - Owns persisted preferences and recent-files list.
  - Exposes theme/color tokens and helper functions.

- `qml/features/*` are isolated UI feature modules.
  - Menus, dialogs, editor pane, and status bar are separate components.

## Build & Run

### Option 1: Qt Creator (recommended)

1. Open the project folder in Qt Creator.
2. Select a Qt 6 desktop kit (for example: `Desktop Qt 6.x MinGW 64-bit`).
3. Configure and run `appWordrobe`.

### Option 2: Command line

From the project root:

```powershell
cmake -S . -B build
cmake --build build
```

Run the executable from your build directory, e.g.:

```powershell
.\build\appWordrobe.exe
```

Note: executable location may vary by generator/kit.

## Development Notes

- Keep new feature UI in `qml/features/`.
- Keep `qml/Main.qml` focused on wiring and orchestration.
- Keep file/document logic in C++ (`NotepadDocument`) and avoid UI logic there.
- Add persistent user preferences in `qml/AppState.qml`.

## Known Gaps / Future Improvements

- Unsaved-changes confirmation on New/Open/Exit
- Case-sensitive / regex / whole-word find options
- Better text encoding detection on file open
- Keyboard shortcut customization
- Optional autosave

## License

No license file is currently included.
If you plan to share this project publicly, add a `LICENSE` file.
