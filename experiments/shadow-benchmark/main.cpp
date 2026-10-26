#include <QCommandLineParser>
#include <QElapsedTimer>
#include <QEventLoop>
#include <QFile>
#include <QGuiApplication>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlError>
#include <QQuickGraphicsConfiguration>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QSGRendererInterface>
#include <QSysInfo>
#include <QTest>
#include <QTimer>
#include <rhi/qrhi.h>
#include <algorithm>
#include <cmath>
#include <ctime>
#include <memory>
#include <mutex>
#ifdef Q_OS_MACOS
#include <mach/mach.h>
#endif

static double residentMb()
{
#ifdef Q_OS_MACOS
    mach_task_basic_info_data_t info{};
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO,
                  reinterpret_cast<task_info_t>(&info), &count) == KERN_SUCCESS)
        return info.resident_size / (1024.0 * 1024.0);
#endif
    return -1;
}

static void eventWait(int milliseconds)
{
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    timer.setTimerType(Qt::PreciseTimer);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(milliseconds);
    loop.exec();
}

static QJsonObject distribution(QList<double> values)
{
    if (values.isEmpty())
        return {{"samples", 0}};
    std::sort(values.begin(), values.end());
    const auto percentile = [&](double p) {
        return values.at(std::clamp(qsizetype(std::ceil(p * values.size())) - 1,
                                    qsizetype(0), values.size() - 1));
    };
    double sum = 0;
    for (double value : values)
        sum += value;
    return {{"samples", int(values.size())}, {"meanMs", sum / values.size()},
            {"p50Ms", percentile(.50)}, {"p95Ms", percentile(.95)},
            {"p99Ms", percentile(.99)}, {"maxMs", values.last()}};
}

struct Samples {
    std::mutex mutex;
    QElapsedTimer clock;
    bool recording = false;
    double syncStart = 0;
    double renderStart = 0;
    double lastFrame = 0;
    QList<double> intervals;
    QList<double> sync;
    QList<double> render;
    QList<double> gpu;
    QString device;
    bool timestamps = false;
    double now() const { return clock.nsecsElapsed() / 1e6; }
};

static int disableBehaviors(QObject *object)
{
    int count = 0;
    if (object->inherits("QQuickBehavior")) {
        if (!object->setProperty("enabled", false))
            return -1000000;
        ++count;
    }
    for (auto *child : object->children())
        count += disableBehaviors(child);
    return count;
}

static QList<QQuickItem *> namedItems(QQuickItem *root, const QString &name)
{
    QList<QQuickItem *> result;
    if (root->objectName() == name)
        result.append(root);
    for (auto *child : root->childItems())
        result.append(namedItems(child, name));
    return result;
}

int main(int argc, char **argv)
{
    QQuickWindow::setGraphicsApi(QSGRendererInterface::Metal);
    QGuiApplication app(argc, argv);
    app.setApplicationName("Qavsi shadow benchmark");
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addOptions({
        {{"m", "mode"}, "none, rectangular1, rectangular2, qcm", "mode", "qcm"},
        {{"n", "count"}, "Visible caster count", "count", "100"},
        {"animated", "Animate elevation with a shared driver"},
        {"real-fab", "Use 100 real56x56 FAB-sized casters"},
        {"level", "Base elevation", "level", "6"},
        {"measure", "Measure and exit automatically"},
        {"sample-ms", "Sampling duration", "ms", "5000"},
        {"warmup-ms", "Warmup duration", "ms", "2000"},
        {"snapshot", "Save validation screenshot", "path"},
        {"output", "JSON result path", "path"}
    });
    parser.process(app);
#ifndef QT_NO_DEBUG
    qCritical() << "Performance measurements require an optimized Release build";
    return 2;
#endif
    const auto mode = parser.value("mode");
    bool countOk = false;
    const int requested = parser.value("count").toInt(&countOk);
    bool levelOk = false;
    const double level = parser.value("level").toDouble(&levelOk);
    bool sampleOk = false, warmupOk = false;
    const int sampleMs = parser.value("sample-ms").toInt(&sampleOk);
    const int warmupMs = parser.value("warmup-ms").toInt(&warmupOk);
    if (!QStringList{"none", "rectangular1", "rectangular2", "qcm"}.contains(mode)
        || !countOk || (requested != 100 && requested != 1000) || !levelOk
        || (level != 1 && level != 6) || !sampleOk || sampleMs < 1000
        || !warmupOk || warmupMs < 500 || (parser.isSet("real-fab") && requested != 100)) {
        qCritical() << "Invalid benchmark parameters";
        return 2;
    }
    QScreen *left = nullptr;
    for (auto *screen : app.screens()) {
        if (screen->geometry().left() < 0 && screen->availableGeometry().width() >= 1800
            && screen->availableGeometry().height() >= 950
            && (!left || screen->geometry().left() < left->geometry().left()))
            left = screen;
    }
    if (!left) {
        qCritical() << "Required left display unavailable; right display will not be used";
        return 3;
    }

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral(QCM_QML_DIR));
    engine.addImportPath("qrc:/");
    QStringList warnings;
    QObject::connect(&engine, &QQmlEngine::warnings, &engine, [&](const QList<QQmlError> &errors) {
        for (const auto &error : errors)
            warnings.append(error.toString());
    });
    QVariantMap initial{{"rendererMode", mode}, {"itemCount", requested},
        {"elevationLevel", level}, {"animateElevation", parser.isSet("animated")},
        {"previewArea", left->availableGeometry()}};
    if (parser.isSet("real-fab")) {
        initial.insert("columnCount", 10);
        initial.insert("cellStepX", 160);
        initial.insert("cellStepY", 84);
        initial.insert("casterWidth", 56);
        initial.insert("casterHeight", 56);
        initial.insert("casterRadius", 16);
    }
    engine.setInitialProperties(initial);
    QElapsedTimer creation;
    creation.start();
    engine.load(QUrl::fromLocalFile(QStringLiteral(BENCH_QML_DIR "/Scene.qml")));
    const double creationMs = creation.nsecsElapsed() / 1e6;
    auto *window = engine.rootObjects().isEmpty() ? nullptr
        : qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window || !warnings.isEmpty()) {
        qCritical() << "Scene creation failed" << warnings;
        return 4;
    }
    window->setScreen(left);
    QQuickGraphicsConfiguration config;
    config.setTimestamps(true);
    window->setGraphicsConfiguration(config);
    window->show();
    if (!QTest::qWaitForWindowExposed(window, 4000)) {
        qCritical() << "Left benchmark window not exposed";
        return 5;
    }
    eventWait(750);
    if (window->rendererInterface()->graphicsApi() != QSGRendererInterface::Metal
        || window->screen() != left || !left->availableGeometry().contains(window->geometry())) {
        qCritical() << "Actual backend/display/geometry differs" << window->geometry();
        return 5;
    }
    int behaviorsDisabled = 0;
    if (mode == "qcm") {
        for (auto *renderer : namedItems(window->contentItem(), "qcmElevation"))
            behaviorsDisabled += disableBehaviors(renderer);
        if (behaviorsDisabled != requested) {
            qCritical() << "QCM built-in Behaviors could not be disabled" << behaviorsDisabled;
            return 6;
        }
    }
    const auto visibleCells = namedItems(window->contentItem(), "shadowBenchmarkCell");
    const QSizeF casterSize(window->property("casterWidth").toDouble(), window->property("casterHeight").toDouble());
    if (visibleCells.size() != requested) {
        qCritical() << "Caster count mismatch" << visibleCells.size();
        return 6;
    }
    const QRectF viewport(QPointF(), QSizeF(window->size()));
    for (const auto *cell : visibleCells) {
        if (!cell->isVisible() || cell->size() != casterSize
            || !viewport.contains(cell->mapRectToScene(cell->boundingRect()).adjusted(-12, -12, 40, 40))) {
            qCritical() << "Caster or shadow clipped/outside viewport";
            return 6;
        }
    }
    const int rendererCount = mode == "qcm" ? namedItems(window->contentItem(), "qcmElevation").size()
        : mode == "rectangular1" ? namedItems(window->contentItem(), "rectangularShadow").size()
        : mode == "rectangular2" ? namedItems(window->contentItem(), "rectangularAmbient").size()
            + namedItems(window->contentItem(), "rectangularSpot").size() : 0;
    if (rendererCount != (mode == "none" ? 0 : requested * (mode == "rectangular2" ? 2 : 1))) {
        qCritical() << "Shadow renderer count mismatch" << rendererCount;
        return 6;
    }
    const QImage image = window->grabWindow();
    if (image.isNull()) {
        qCritical() << "No validation pixels";
        return 6;
    }
    const auto background = window->color();
    int verifiedShadowCells = 0;
    for (const auto *cell : visibleCells) {
        const auto p = cell->mapToScene(QPointF(cell->width() / 2, cell->height() + 1)) * image.devicePixelRatio();
        const auto color = image.pixelColor(qRound(p.x()), qRound(p.y()));
        if (background.red() - color.red() >= 2)
            ++verifiedShadowCells;
    }
    if (mode != "none" && verifiedShadowCells != requested) {
        qCritical() << "Some shadows have no visible pixels" << verifiedShadowCells << requested;
        return 6;
    }
    if (parser.isSet("snapshot") && !image.save(parser.value("snapshot"))) {
        qCritical() << "Cannot save snapshot";
        return 6;
    }
    bool elevationPixelsChanged = false;
    if (parser.isSet("animated") && (mode == "qcm" || mode == "rectangular2")) {
        window->setProperty("phase", 1.0);
        eventWait(80);
        const QImage raised = window->grabWindow();
        elevationPixelsChanged = raised != image;
        if (!elevationPixelsChanged || qAbs(window->property("elevation").toDouble() - (level + 2)) > .001) {
            qCritical() << "Animated elevation did not change rendered pixels";
            return 6;
        }
        if (parser.isSet("snapshot")) {
            const auto path = parser.value("snapshot");
            if (!raised.save(path.left(path.size() - 4) + "-raised.png"))
                return 6;
        }
        window->setProperty("phase", 0.0);
        eventWait(80);
    }
    window->setProperty("animationsStarted", true);
    if (!parser.isSet("measure"))
        return app.exec();

    auto data = std::make_shared<Samples>();
    data->clock.start();
    QList<QMetaObject::Connection> connections;
    connections.append(QObject::connect(window, &QQuickWindow::beforeSynchronizing, window, [data] {
        std::lock_guard guard(data->mutex);
        data->syncStart = data->now();
    }, Qt::DirectConnection));
    connections.append(QObject::connect(window, &QQuickWindow::afterSynchronizing, window, [data] {
        const double now = data->now();
        std::lock_guard guard(data->mutex);
        if (data->recording)
            data->sync.append(now - data->syncStart);
    }, Qt::DirectConnection));
    connections.append(QObject::connect(window, &QQuickWindow::beforeRendering, window, [data, window] {
        const double now = data->now();
        std::lock_guard guard(data->mutex);
        data->renderStart = now;
        if (auto *rhi = window->rhi()) {
            data->device = QString::fromUtf8(rhi->driverInfo().deviceName);
            data->timestamps = rhi->isFeatureSupported(QRhi::Timestamps);
            if (data->recording && window->swapChain()) {
                const double gpuMs = window->swapChain()->currentFrameCommandBuffer()->lastCompletedGpuTime() * 1000;
                if (std::isfinite(gpuMs) && gpuMs > 0)
                    data->gpu.append(gpuMs);
            }
        }
    }, Qt::DirectConnection));
    connections.append(QObject::connect(window, &QQuickWindow::afterRendering, window, [data] {
        const double now = data->now();
        std::lock_guard guard(data->mutex);
        if (data->recording)
            data->render.append(now - data->renderStart);
    }, Qt::DirectConnection));
    connections.append(QObject::connect(window, &QQuickWindow::frameSwapped, window, [data] {
        const double now = data->now();
        std::lock_guard guard(data->mutex);
        if (data->recording) {
            if (data->lastFrame > 0)
                data->intervals.append(now - data->lastFrame);
            data->lastFrame = now;
        }
    }, Qt::DirectConnection));
    eventWait(warmupMs);
    const auto cpuStart = std::clock();
    QElapsedTimer wall;
    wall.start();
    {
        std::lock_guard guard(data->mutex);
        data->recording = true;
    }
    eventWait(sampleMs);
    {
        std::lock_guard guard(data->mutex);
        data->recording = false;
    }
    const double wallMs = wall.nsecsElapsed() / 1e6;
    const double cpuMs = (std::clock() - cpuStart) * 1000.0 / CLOCKS_PER_SEC;
    for (const auto &connection : connections)
        QObject::disconnect(connection);
    std::lock_guard guard(data->mutex);
    if (data->intervals.size() < 30 || !warnings.isEmpty() || !window->isExposed()) {
        qCritical() << "Invalid measurement" << data->intervals.size() << warnings << window->isExposed();
        return 7;
    }
    const double frameBudget = 1000.0 / left->refreshRate();
    int longFrames = 0;
    for (double interval : data->intervals)
        longFrames += interval > frameBudget * 1.5;
    QJsonObject report{
        {"mode", mode}, {"items", requested}, {"animated", parser.isSet("animated")},
        {"baseElevation", level}, {"endElevation", level + 2},
        {"qt", qVersion()}, {"build", "Release"},
        {"os", QSysInfo::prettyProductName()}, {"cpuArchitecture", QSysInfo::currentCpuArchitecture()},
        {"backend", "Metal"}, {"gpuDevice", data->device}, {"gpuTimestampsSupported", data->timestamps},
        {"gpuTiming", "QRhi lastCompletedGpuTime; asynchronous previous completed frames, not current-frame paired"},
        {"screen", left->name()}, {"screenGeometry", QJsonArray{left->geometry().x(), left->geometry().y(), left->geometry().width(), left->geometry().height()}},
        {"windowSize", QJsonArray{window->width(), window->height()}},
        {"dpr", window->devicePixelRatio()}, {"refreshHz", left->refreshRate()},
        {"casterSize", QJsonArray{casterSize.width(), casterSize.height()}},
        {"radius", window->property("casterRadius").toDouble()}, {"realFab", parser.isSet("real-fab")},
        {"verifiedVisibleCasters", int(visibleCells.size())}, {"shadowRendererCount", rendererCount},
        {"pixelVerifiedShadows", verifiedShadowCells}, {"disabledQcmBehaviors", behaviorsDisabled},
        {"elevationPixelsChanged", elevationPixelsChanged},
        {"creationMs", creationMs}, {"rssMb", residentMb()},
        {"warmupMs", warmupMs}, {"sampleMs", sampleMs}, {"wallMs", wallMs},
        {"frames", int(data->intervals.size() + 1)},
        {"fps", (data->intervals.size() + 1) * 1000.0 / wallMs},
        {"cpuMs", cpuMs}, {"cpuMsPerFrame", cpuMs / (data->intervals.size() + 1)},
        {"cpuPercentOneCore", cpuMs / wallMs * 100},
        {"frameIntervals", distribution(data->intervals)}, {"syncCpu", distribution(data->sync)},
        {"renderRecordingCpu", distribution(data->render)}, {"gpuElapsed", distribution(data->gpu)},
        {"framesOver1_5RefreshBudget", longFrames},
        {"animationPolicy", "renderer-only shared250ms OutCubic elevation; QCM internal Behavior disabled; rectangular1 intentionally fixed current-shadow baseline"},
        {"staticPolicy", "2x2 heartbeat forces complete Metal scene repaint; idle power not measured"},
        {"qmlWarningCount", warnings.size()}
    };
    const auto json = QJsonDocument(report).toJson(QJsonDocument::Indented);
    if (parser.isSet("output")) {
        QFile file(parser.value("output"));
        if (!file.open(QIODevice::WriteOnly) || file.write(json) != json.size()) {
            qCritical() << "Cannot write benchmark result";
            return 8;
        }
    }
    qInfo().noquote() << "SHADOW_BENCHMARK" << QJsonDocument(report).toJson(QJsonDocument::Compact);
    return 0;
}
