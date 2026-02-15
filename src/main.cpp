#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "document/notepaddocument.h"

int main(int argc, char *argv[])
{
    // Application composition root:
    // - creates the C++ document backend
    // - exposes it to QML as `document`
    // - loads the modular QML UI from the Wordrobe module
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    NotepadDocument document;
    engine.rootContext()->setContextProperty("document", &document);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Wordrobe", "Main");

    return app.exec();
}
