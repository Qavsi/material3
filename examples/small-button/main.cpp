#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QScreen>
#include <QStyleHints>
#include <algorithm>

int checkSmallButton(QQmlApplicationEngine &engine, QQuickWindow &window);
int benchmarkFeedback(QQmlApplicationEngine &engine, QQuickWindow &window);

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
    const auto arguments = app.arguments();
    QString benchmark;
    int itemCount = 100;
    for (const auto &argument : arguments) {
        if (argument.startsWith("--benchmark="))
            benchmark = argument.sliced(12);
        if (argument.startsWith("--items=")) {
            bool valid = false;
            itemCount = argument.sliced(8).toInt(&valid);
            if (!valid || itemCount < 1 || itemCount > 400) {
                qCritical() << "--items must be between 1 and 400";
                return 4;
            }
        }
    }
    if (!benchmark.isEmpty() && benchmark != "shader" && benchmark != "painter") {
        qCritical() << "--benchmark must be shader or painter";
        return 4;
    }
    QVariantMap properties{{"previewArea", leftScreen->availableGeometry()}};
    if (!benchmark.isEmpty()) {
        properties.insert("usePainter", benchmark == "painter");
        properties.insert("itemCount", itemCount);
    }
    engine.setInitialProperties(properties);
    engine.loadFromModule("Qavsi.Material3.SmallButton", benchmark.isEmpty() ? "Main" : "Benchmark");
    if (engine.rootObjects().isEmpty())
        return 2;
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());
    if (!window)
        return 3;
    qInfo() << "Preview screen:" << leftScreen->name() << leftScreen->availableGeometry()
            << "window:" << window->geometry();
    if (!benchmark.isEmpty())
        return benchmarkFeedback(engine, *window);
    if (arguments.contains("--check"))
        return checkSmallButton(engine, *window);
    return app.exec();
}
