#pragma once

#include <QObject>
#include <QString>

// NotepadDocument is the non-UI document service used by QML.
// Responsibilities:
// - hold current text and file path
// - track modified state
// - perform UTF-8 file I/O
// - expose user-facing errors
//
// Integration note:
// This type is injected into QML as the context property `document`.
// Keep UI concerns out of this class so it remains testable and reusable.
class NotepadDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString filePath READ filePath NOTIFY filePathChanged)
    Q_PROPERTY(bool modified READ modified NOTIFY modifiedChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY filePathChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit NotepadDocument(QObject *parent = nullptr);

    QString text() const;
    QString filePath() const;
    bool modified() const;
    QString displayName() const;
    QString lastError() const;

    void setText(const QString &text);

    Q_INVOKABLE void newDocument();
    Q_INVOKABLE bool openFromPath(const QString &pathOrUrl);
    Q_INVOKABLE bool save();
    Q_INVOKABLE bool saveAs(const QString &pathOrUrl);

signals:
    void textChanged();
    void filePathChanged();
    void modifiedChanged();
    void lastErrorChanged();

private:
    QString normalizePath(const QString &pathOrUrl) const;
    bool saveToPath(const QString &path);
    void setModified(bool modified);
    void setLastError(const QString &errorText);

    QString m_text;
    QString m_filePath;
    QString m_lastError;
    bool m_modified = false;
    bool m_internalChange = false;
};
