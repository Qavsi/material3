#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QScreen>
#include <QStyleHints>
#include <algorithm>

int checkComparison(QQmlApplicationEngine &engine, QQuickWindow &window);

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::styleHints()->setTabFocusBehavior(Qt::TabFocusAllControls);
    QQmlApplicationEngine engine;
    const auto screens = QGuiApplication::screens();
    if (screens.isEmpty())
        return 1;
    auto *leftScreen = *std::min_element(screens.begin(), screens.end(), [](auto *a, auto *b) {
        return a->geometry().left() < b->geometry().left();
    });
    engine.setInitialProperties({{"previewArea", leftScreen->availableGeometry()}});
    engine.loadFromModule("Qavsi.Material3.Comparison", "Main");
    if (engine.rootObjects().isEmpty())
        return 2;
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    if (!window)
        return 3;
    qInfo() << "Preview screen:" << leftScreen->name() << leftScreen->availableGeometry()
            << "window:" << window->geometry();
    if (app.arguments().contains("--check"))
        return checkComparison(engine, *window);
    return app.exec();
}
