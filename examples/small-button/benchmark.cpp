#include <QElapsedTimer>
#include <QGuiApplication>
#include <QImage>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlError>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QSGRendererInterface>
#include <QSignalSpy>
#include <QTest>
#include <algorithm>
#include <ctime>
#include <memory>
#include <mutex>

int benchmarkFeedback(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    window.raise();
    window.requestActivate();
    if (!QTest::qWaitForWindowExposed(&window, 1500)
        || !QTest::qWaitForWindowActive(&window, 1500)) {
        qCritical() << "Benchmark window must be exposed and active";
        return 5;
    }
    QTest::qWait(1500);
    const auto api = window.rendererInterface()->graphicsApi();
    if (api != QSGRendererInterface::Metal) {
        qCritical() << "Renderer comparison requires actual Metal; got" << api;
        return 5;
    }
    const bool painter = window.property("usePainter").toBool();
    const int requested = window.property("itemCount").toInt();
    QList<QQuickItem *> cells;
    QList<QQuickItem *> shaders;
    QList<QQuickItem *> painters;
    const auto collect = [&](const auto &self, QQuickItem *item) -> void {
        if (item->objectName() == "benchmarkCell")
            cells.append(item);
        else if (item->objectName() == "benchmarkShader")
            shaders.append(item);
        else if (item->objectName() == "benchmarkPainter")
            painters.append(item);
        for (auto *child : item->childItems())
            self(self, child);
    };
    collect(collect, window.contentItem());
    if (cells.size() != requested || shaders.size() != (painter ? 0 : requested)
        || painters.size() != (painter ? requested : 0)) {
        qCritical() << "Benchmark visual workload differs: requested" << requested
                    << "cells" << cells.size() << "shaders" << shaders.size()
                    << "painters" << painters.size()
                    << "QObject shaders" << window.findChildren<QQuickItem *>("benchmarkShader").size();
        return 5;
    }
    for (const auto *cell : cells) {
        const auto bounds = cell->mapRectToScene(cell->boundingRect());
        if (!cell->isVisible() || cell->width() != 72 || cell->height() != 40
            || !QRectF(QPointF(), window.size()).contains(bounds)) {
            qCritical() << "Benchmark cell is hidden, mis-sized or outside the window" << bounds;
            return 5;
        }
    }
    auto *animation = window.findChild<QObject *>("benchmarkPulse");
    auto *tokens = window.property("tokens").value<QObject *>();
    if (!animation || !tokens || !animation->setProperty("paused", true)) {
        qCritical() << "Benchmark pulse or theme is unavailable";
        return 5;
    }
    window.setProperty("phase", 0.0);
    const auto idle = window.grabWindow();
    const auto expansionMs = tokens->property("rippleExpansionDuration").toDouble();
    const auto cycleMs = window.property("cycleDuration").toDouble();
    window.setProperty("phase", expansionMs / cycleMs);
    const auto pressed = window.grabWindow();
    animation->setProperty("paused", false);
    if (idle.isNull() || pressed.isNull()) {
        qCritical() << "Benchmark scene produced no snapshot";
        return 5;
    }
    const auto pixel = [](const QImage &image, QQuickItem *cell, QPointF local) {
        const auto point = cell->mapToScene(local) * image.devicePixelRatio();
        return image.pixelColor(qRound(point.x()), qRound(point.y()));
    };
    const auto near = [](QColor a, QColor b) {
        return qAbs(a.red() - b.red()) <= 2 && qAbs(a.green() - b.green()) <= 2
            && qAbs(a.blue() - b.blue()) <= 2 && qAbs(a.alpha() - b.alpha()) <= 2;
    };
    for (auto *cell : cells) {
        const auto base = cell->property("color").value<QColor>();
        const auto ink = cell->property("ink").value<QColor>();
        const auto alpha = ink.alphaF();
        const QColor expected(qRound(base.red() * (1 - alpha) + ink.red() * alpha),
                              qRound(base.green() * (1 - alpha) + ink.green() * alpha),
                              qRound(base.blue() * (1 - alpha) + ink.blue() * alpha));
        const QPointF inside(8, cell->height() / 2);
        const QPointF outside(1, 1);
        if (!near(pixel(idle, cell, inside), base)
            || !near(pixel(pressed, cell, inside), expected)
            || !near(pixel(idle, cell, outside), window.color())
            || !near(pixel(pressed, cell, outside), window.color())) {
            qCritical() << "Benchmark cell pixels failed: index" << cell->property("index")
                        << "idle" << pixel(idle, cell, inside)
                        << "pressed" << pixel(pressed, cell, inside) << "expected" << expected
                        << "corner" << pixel(pressed, cell, outside);
            return 5;
        }
    }
    int compiledShaders = 0;
    int cachedShaders = 0;
    for (const auto *shader : shaders) {
        const int status = shader->property("status").toInt();
        if (status == 0)
            ++compiledShaders;
        else if (status == 1)
            ++cachedShaders;
        if ((status != 0 && status != 1) || !shader->property("log").toString().isEmpty()) {
            qCritical() << "Benchmark shader failed: status" << status
                        << "log" << shader->property("log");
            return 5;
        }
    }
    // Qt 6.12 cached .qsb instances render but retain Uncompiled; pixels verify every instance.
    if (!painter && compiledShaders < 1) {
        qCritical() << "Benchmark has no compiled shader instance";
        return 5;
    }
    qInfo() << "Benchmark pipeline verified: cells" << cells.size()
            << "compiledShaders" << compiledShaders << "cachedUncompiledShaders" << cachedShaders;
    QTest::qWait(500);

    struct FrameTimes {
        std::mutex mutex;
        QElapsedTimer elapsed;
        QList<double> intervals;
        double lastFrame = 0;
    };
    auto times = std::make_shared<FrameTimes>();
    times->elapsed.start();
    const auto cpuStart = std::clock();
    const auto phaseStart = window.property("phase");
    const auto connection = QObject::connect(&window, &QQuickWindow::frameSwapped, &window, [times] {
        const double now = times->elapsed.nsecsElapsed() / 1e6;
        std::lock_guard lock(times->mutex);
        if (times->lastFrame > 0)
            times->intervals.append(now - times->lastFrame);
        times->lastFrame = now;
    }, Qt::DirectConnection);
    QTest::qWait(5000);
    QObject::disconnect(connection);
    const double wallMs = times->elapsed.nsecsElapsed() / 1e6;
    const double cpuMs = 1000.0 * (std::clock() - cpuStart) / CLOCKS_PER_SEC;
    QList<double> intervals;
    {
        std::lock_guard lock(times->mutex);
        intervals = times->intervals;
    }
    if (intervals.size() < 10 || !warnings.isEmpty()) {
        auto *animation = window.findChild<QObject *>("benchmarkPulse");
        qCritical() << "Benchmark did not receive sufficient frames or emitted QML warnings:"
                    << "frameIntervals" << intervals.size() << "warningBatches" << warnings.size()
                    << "visible" << window.isVisible() << "exposed" << window.isExposed()
                    << "active" << window.isActive() << "visibility" << window.visibility()
                    << "windowState" << window.windowState() << "geometry" << window.geometry()
                    << "screen" << window.screen()->name() << "phaseStart" << phaseStart
                    << "phaseEnd" << window.property("phase")
                    << "animationRunning" << (animation ? animation->property("running") : QVariant())
                    << "animationPaused" << (animation ? animation->property("paused") : QVariant());
        for (const auto &batch : warnings)
            for (const auto &error : qvariant_cast<QList<QQmlError>>(batch.first()))
                qCritical().noquote() << error.toString();
        return 5;
    }
    std::sort(intervals.begin(), intervals.end());
    const auto percentile = [&](double fraction) {
        return intervals.at(qMin(intervals.size() - 1, qsizetype(fraction * intervals.size())));
    };
    QJsonObject report{
        {"renderer", painter ? "painter" : "shader"},
        {"graphicsApi", "Metal"},
        {"qt", qVersion()},
#ifdef QT_NO_DEBUG
        {"buildType", "Release"},
#else
        {"buildType", "Debug"},
#endif
        {"screen", window.screen()->name()},
        {"items", requested},
        {"verifiedCells", int(cells.size())},
        {"verifiedShaders", int(shaders.size())},
        {"verifiedPainters", int(painters.size())},
        {"pixelVerifiedCells", int(cells.size())},
        {"compiledShaders", compiledShaders},
        {"cachedUncompiledShaders", cachedShaders},
        {"itemWidth", 72},
        {"itemHeight", 40},
        {"windowWidth", window.width()},
        {"windowHeight", window.height()},
        {"dpr", window.devicePixelRatio()},
        {"refreshHz", window.screen()->refreshRate()},
        {"frames", int(intervals.size() + 1)},
        {"wallMs", wallMs},
        {"cpuMs", cpuMs},
        {"cpuMsPerFrame", cpuMs / (intervals.size() + 1)},
        {"fps", (intervals.size() + 1) * 1000.0 / wallMs},
        {"frameMedianMs", percentile(0.5)},
        {"frameP95Ms", percentile(0.95)},
        {"warmupMs", 2000},
        {"sampleMs", 5000},
        {"measurement", "vsync-paced feedback-only scene; process CPU; frameSwapped intervals; no GPU timer"}
    };
    qInfo().noquote() << "BENCHMARK" << QJsonDocument(report).toJson(QJsonDocument::Compact);
    return 0;
}
