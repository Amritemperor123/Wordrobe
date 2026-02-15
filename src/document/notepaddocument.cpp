#include "notepaddocument.h"

#include <QFile>
#include <QFileInfo>
#include <QStringConverter>
#include <QTextStream>
#include <QUrl>

// Internal-change guard:
// when loading/creating text programmatically we do not want to mark
// the document modified. User edits still set modified=true.
NotepadDocument::NotepadDocument(QObject *parent)
    : QObject(parent)
{
}

QString NotepadDocument::text() const
{
    return m_text;
}

QString NotepadDocument::filePath() const
{
    return m_filePath;
}

bool NotepadDocument::modified() const
{
    return m_modified;
}

QString NotepadDocument::displayName() const
{
    if (m_filePath.isEmpty()) {
        return QStringLiteral("Untitled");
    }
    return QFileInfo(m_filePath).fileName();
}

QString NotepadDocument::lastError() const
{
    return m_lastError;
}

void NotepadDocument::setText(const QString &text)
{
    if (m_text == text) {
        return;
    }

    m_text = text;
    emit textChanged();

    if (!m_internalChange) {
        setModified(true);
    }
}

void NotepadDocument::newDocument()
{
    m_internalChange = true;
    m_text.clear();
    emit textChanged();
    m_internalChange = false;

    if (!m_filePath.isEmpty()) {
        m_filePath.clear();
        emit filePathChanged();
    }
    setModified(false);
    setLastError(QString());
}

bool NotepadDocument::openFromPath(const QString &pathOrUrl)
{
    // QML file dialogs return file URLs; normalize to local OS path first.
    const QString path = normalizePath(pathOrUrl);
    if (path.isEmpty()) {
        setLastError(QStringLiteral("Invalid file path."));
        return false;
    }

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        setLastError(QStringLiteral("Could not open file: %1").arg(file.errorString()));
        return false;
    }

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    const QString fileText = in.readAll();

    m_internalChange = true;
    m_text = fileText;
    emit textChanged();
    m_internalChange = false;

    if (m_filePath != path) {
        m_filePath = path;
        emit filePathChanged();
    }
    setModified(false);
    setLastError(QString());
    return true;
}

bool NotepadDocument::save()
{
    if (m_filePath.isEmpty()) {
        setLastError(QStringLiteral("No file selected. Use Save As first."));
        return false;
    }
    return saveToPath(m_filePath);
}

bool NotepadDocument::saveAs(const QString &pathOrUrl)
{
    const QString path = normalizePath(pathOrUrl);
    if (path.isEmpty()) {
        setLastError(QStringLiteral("Invalid file path."));
        return false;
    }

    if (!saveToPath(path)) {
        return false;
    }

    if (m_filePath != path) {
        m_filePath = path;
        emit filePathChanged();
    }
    return true;
}

QString NotepadDocument::normalizePath(const QString &pathOrUrl) const
{
    const QUrl url(pathOrUrl);
    if (url.isValid() && url.isLocalFile()) {
        return url.toLocalFile();
    }
    return pathOrUrl;
}

bool NotepadDocument::saveToPath(const QString &path)
{
    // Save in UTF-8 so files remain portable across platforms/editors.
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) {
        setLastError(QStringLiteral("Could not save file: %1").arg(file.errorString()));
        return false;
    }

    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    out << m_text;

    if (out.status() != QTextStream::Ok) {
        setLastError(QStringLiteral("Write failed while saving file."));
        return false;
    }

    setModified(false);
    setLastError(QString());
    return true;
}

void NotepadDocument::setModified(bool modified)
{
    if (m_modified == modified) {
        return;
    }
    m_modified = modified;
    emit modifiedChanged();
}

void NotepadDocument::setLastError(const QString &errorText)
{
    if (m_lastError == errorText) {
        return;
    }
    m_lastError = errorText;
    emit lastErrorChanged();
}
