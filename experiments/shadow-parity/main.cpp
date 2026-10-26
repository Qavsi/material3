#include <QCommandLineParser>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlApplicationEngine>
#include <QQmlError>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>
#include <QSGRendererInterface>
#include <QSurfaceFormat>
#include <QTimer>
#include <algorithm>
#include <array>
#include <cmath>
#include <limits>
#include "blurmaskmaterial.h"
#include "shadowgeometry.h"

static void settle(int milliseconds)
{
    QEventLoop loop;
    QTimer::singleShot(milliseconds, &loop, &QEventLoop::quit);
    loop.exec();
}

static QQuickItem *findItem(QQuickItem *root, const QString &name)
{
    if (root->objectName() == name)
        return root;
    for (auto *child : root->childItems())
        if (auto *found = findItem(child, name))
            return found;
    return nullptr;
}

struct Case {
    QString name;
    bool unequal = false;
    QVector4D radii{16, 16, 16, 16};
    double elevation = 6;
    QColor ink = Qt::black;
    double opacity = 1;
    QSize caster{160, 96};
    QColor background{"#faf9fd"};
    bool strict = true;
};

static QJsonArray cutoutBoundaryChecks(int &failures)
{
    struct Boundary { const char *name; float sigma; float radius; bool expected; };
    const Boundary boundaries[] = {
        {"material3-elevation6-radius20", 7.2f, 20, true},
        {"zero-no-cutout", 0, 0, true},
        {"subthreshold-radius-no-cutout", 7.2f, .25f, true},
        {"negative-sigma", -.1f, 8, false},
        {"negative-radius", 1, -1, false},
        {"nan-sigma", std::numeric_limits<float>::quiet_NaN(), 8, false},
        {"infinite-radius", 7, std::numeric_limits<float>::infinity(), false},
        {"finite-huge-sigma", 1e20f, 8, false},
        {"finite-huge-radius", 1, 1e20f, false}
    };
    QJsonArray results;
    for (const auto &test : boundaries) {
        const bool actual = qavsi::shadow::blur::safeCutout(test.sigma, test.radius);
        const bool passed = actual == test.expected;
        failures += !passed;
        results.append(QJsonObject{{"case", test.name}, {"expectedSafe", test.expected},
            {"actualSafe", actual}, {"passed", passed}});
        if (!passed)
            qCritical() << "safeCutout boundary failed" << test.name;
    }
    return results;
}

static QJsonObject difference(const QImage &a, const QImage &b, const QRect &caster,
                              QColor background)
{
    qint64 error = 0;
    int maximum = 0, changed = 0, shadowPixels = 0;
    int referenceInk = 0, portedInk = 0;
    for (int y = 0; y < a.height(); ++y) {
        for (int x = 0; x < a.width(); ++x) {
            if (caster.contains(x, y))
                continue;
            const auto ca = a.pixelColor(x, y), cb = b.pixelColor(x, y);
            const int da = std::max({std::abs(ca.red() - background.red()),
                std::abs(ca.green() - background.green()), std::abs(ca.blue() - background.blue())});
            const int db = std::max({std::abs(cb.red() - background.red()),
                std::abs(cb.green() - background.green()), std::abs(cb.blue() - background.blue())});
            referenceInk += da >= 2;
            portedInk += db >= 2;
            if (da == 0 && db == 0)
                continue;
            ++shadowPixels;
            const int e = std::max({std::abs(ca.red() - cb.red()),
                std::abs(ca.green() - cb.green()), std::abs(ca.blue() - cb.blue()),
                std::abs(ca.alpha() - cb.alpha())});
            maximum = std::max(maximum, e);
            changed += e != 0;
            error += std::abs(ca.red() - cb.red()) + std::abs(ca.green() - cb.green())
                + std::abs(ca.blue() - cb.blue()) + std::abs(ca.alpha() - cb.alpha());
        }
    }
    return {{"maxChannelError8bit", maximum},
        {"meanChannelErrorOnShadowPixels8bit", shadowPixels ? double(error) / (shadowPixels * 4) : 0},
        {"differentShadowPixels", changed}, {"shadowPixels", shadowPixels},
        {"referenceInkPixels", referenceInk}, {"portedInkPixels", portedInk}};
}

static QJsonObject geometryProbe(const Case &test)
{
    if (test.unequal)
        return {{"path", "blur"}, {"analyticProbeApplicable", false}};
    auto geometry = qavsi::shadow::createShadowGeometry();
    qavsi::shadow::ShadowParameters p{float(test.elevation), test.radii, test.ink,
        .039f, .25f, QVector3D(0, -1, 1), 800.f / 600};
    const bool generated = qavsi::shadow::updateShadowGeometry(geometry.get(), p,
        QRectF(QPointF(), QSizeF(test.caster)));
    int finiteVertices = 0;
    const auto *vertices = static_cast<const qavsi::shadow::ShadowVertex *>(geometry->vertexData());
    for (int i = 0; i < geometry->vertexCount(); ++i) {
        const auto &v = vertices[i];
        finiteVertices += std::isfinite(v.x) && std::isfinite(v.y) && std::isfinite(v.r)
            && std::isfinite(v.g) && std::isfinite(v.b) && std::isfinite(v.a)
            && std::isfinite(v.offset_x) && std::isfinite(v.offset_y)
            && std::isfinite(v.distance_correction);
    }
    return {{"path", "analytic"}, {"generated", generated},
        {"vertices", geometry->vertexCount()}, {"finiteVertices", finiteVertices},
        {"indices", geometry->indexCount()}};
}

static int linearError(const QImage &full, const QImage &half, const QRect &caster,
                       QColor background)
{
    int maximum = 0;
    for (int y = 0; y < full.height(); ++y)
        for (int x = 0; x < full.width(); ++x) {
            if (caster.contains(x, y))
                continue;
            const auto a = full.pixelColor(x, y), b = half.pixelColor(x, y);
            for (const auto [base, f, h] : {std::array{background.red(), a.red(), b.red()},
                    std::array{background.green(), a.green(), b.green()},
                    std::array{background.blue(), a.blue(), b.blue()}})
                maximum = std::max(maximum, std::abs(h - qRound(base + .5 * (f - base))));
        }
    return maximum;
}

static int sourceOverBoundsError(const QImage &image, const QRect &caster,
                                 QColor background, QColor ink)
{
    int maximum = 0;
    for (int y = 0; y < image.height(); ++y)
        for (int x = 0; x < image.width(); ++x) {
            if (caster.contains(x, y))
                continue;
            const auto pixel = image.pixelColor(x, y);
            for (const auto [base, source, actual] : {std::array{background.red(), ink.red(), pixel.red()},
                    std::array{background.green(), ink.green(), pixel.green()},
                    std::array{background.blue(), ink.blue(), pixel.blue()}})
                maximum = std::max({maximum, std::min(base, source) - actual,
                    actual - std::max(base, source)});
        }
    return maximum;
}

int main(int argc, char **argv)
{
    QSurfaceFormat format;
    format.setVersion(3, 3);
    format.setProfile(QSurfaceFormat::CoreProfile);
    QSurfaceFormat::setDefaultFormat(format);
    QGuiApplication app(argc, argv);
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addOptions({{"backend", "metal or opengl", "backend", "metal"},
        {"output", "JSON report", "path", "/private/tmp/qavsi-shadow-parity/result.json"},
        {"snapshots", "Optional PNG directory", "directory"}});
    parser.process(app);
    const auto backend = parser.value("backend");
    if (backend != "metal" && backend != "opengl")
        return 2;
    int failures = 0;
    const auto boundaryChecks = cutoutBoundaryChecks(failures);
    const auto expectedApi = backend == "metal" ? QSGRendererInterface::Metal : QSGRendererInterface::OpenGL;
    QQuickWindow::setGraphicsApi(expectedApi);
    QScreen *left = nullptr;
    for (auto *screen : app.screens())
        if (screen->geometry().left() < 0 && (!left || screen->geometry().left() < left->geometry().left()))
            left = screen;
    if (!left || left->devicePixelRatio() != 1)
        return qCritical("Parity requires the left display at DPR1"), 3;
    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral(QCM_BUILD "/qml_modules"));
    engine.addImportPath(QStringLiteral(M3_BUILD "/src"));
    engine.addImportPath(QStringLiteral(M3_BUILD "/qavsi-icons/src"));
    QStringList warnings;
    QObject::connect(&engine, &QQmlEngine::warnings, &engine, [&](const QList<QQmlError> &errors) {
        for (const auto &error : errors)
            warnings.append(error.toString());
    });
    engine.setInitialProperties({{"previewArea", left->availableGeometry()}});
    engine.load(QUrl::fromLocalFile(QStringLiteral(PARITY_SOURCE "/Scene.qml")));
    auto *window = engine.rootObjects().isEmpty() ? nullptr
        : qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window || !warnings.isEmpty())
        return qCritical() << "Cannot load parity scene" << warnings, 4;
    window->setScreen(left);
    window->show();
    settle(500);
    if (!window->isExposed() || window->rendererInterface()->graphicsApi() != expectedApi
        || !left->availableGeometry().contains(window->geometry()))
        return qCritical("Requested native backend/left exposure unavailable"), 5;
    auto *reference = findItem(window->contentItem(), "referenceCaster");
    auto *ported = findItem(window->contentItem(), "portedCaster");
    if (!reference || !ported)
        return 5;
    QList<Case> cases;
    for (double elevation : {1., 3., 6., 8., 12.})
        cases.append({QString("uniform-black-e%1").arg(elevation), false, {16,16,16,16}, elevation});
    cases.append({"uniform-circle", false, {48,48,48,48}, 6, Qt::black, 1, {96,96}});
    cases.append({"uniform-pill", false, {28,28,28,28}, 6, Qt::black, 1, {160,56}});
    cases.append({"uniform-square", false, {0,0,0,0}});
    for (double elevation : {1., 6., 8., 12.})
        cases.append({QString("unequal-black-e%1").arg(elevation), true, {4,12,20,8}, elevation});
    cases.append({"unequal-fractional", true, {4.25,12.5,20.75,8.125}});
    cases.append({"unequal-zero-corner", true, {0,12,20,8}});
    for (bool unequal : {false, true}) {
        const QString prefix = unequal ? "unequal" : "uniform";
        const QVector4D radii = unequal ? QVector4D(4,12,20,8) : QVector4D(16,16,16,16);
        cases.append({prefix + "-dark-background", unequal, radii, 6, Qt::black, 1,
            {160,96}, QColor("#141218")});
        cases.append({prefix + "-colored", unequal, radii, 6, QColor("#2864a0"), 1,
            {160,96}, QColor("#faf9fd"), false});
        cases.append({prefix + "-color-alpha-half", unequal, radii, 6,
            QColor::fromRgbF(0,0,0,.5), 1, {160,96}, QColor("#faf9fd"), unequal});
        cases.append({prefix + "-opacity-half", unequal, radii, 6, Qt::black,
            .5, {160,96}, QColor("#faf9fd"), unequal});
        cases.append({prefix + "-colored-alpha-opacity-half", unequal, radii, 6,
            QColor::fromRgbF(.15,.4,.65,.5), .5, {160,96}, QColor("#faf9fd"), false});
    }
    QJsonArray results, invariants;
    if (parser.isSet("snapshots"))
        QDir().mkpath(parser.value("snapshots"));
    auto capture = [&](const Case &test) {
        window->setProperty("unequal", test.unequal);
        window->setProperty("radii", QVariant::fromValue(test.radii));
        window->setProperty("elevation", test.elevation);
        window->setProperty("shadowColor", test.ink);
        window->setProperty("sampleOpacity", test.opacity);
        window->setProperty("casterWidth", test.caster.width());
        window->setProperty("casterHeight", test.caster.height());
        window->setProperty("surface", test.background);
        settle(60);
        return window->grabWindow();
    };
    for (const auto &test : cases) {
        const QImage image = capture(test);
        if (image.isNull() || !findItem(window->contentItem(), "referenceShadow")
            || !findItem(window->contentItem(), "portedShadow"))
            return qCritical("Missing reference or ported rendering"), 6;
        const QSize size(test.caster.width() + 160, test.caster.height() + 160);
        const QImage a = image.copy(QRect(QPoint(40,80), size));
        const QImage b = image.copy(QRect(QPoint(560,80), size));
        const QRect caster(QPoint(80,80), test.caster);
        auto metric = difference(a, b, caster, test.background);
        const auto geometry = geometryProbe(test);
        const bool pixels = metric["maxChannelError8bit"].toInt() <= 2
            && metric["meanChannelErrorOnShadowPixels8bit"].toDouble() <= .20
            && metric["referenceInkPixels"].toInt() > 20 && metric["portedInkPixels"].toInt() > 20;
        const bool finite = test.unequal || (geometry["generated"].toBool()
            && geometry["finiteVertices"].toInt() == geometry["vertices"].toInt());
        const bool passed = finite && (!test.strict || pixels);
        failures += !passed;
        metric.insert("case", test.name);
        metric.insert("path", test.unequal ? "blur" : "analytic");
        metric.insert("strictRawParity", test.strict);
        metric.insert("passed", passed);
        metric.insert("geometry", geometry);
        metric.insert("expectedDifference", test.strict ? "none" : "QCM straight RGB / dropped analytic color alpha / cubed analytic scene opacity; port uses Qt premultiplied color and linear opacity");
        results.append(metric);
        if (parser.isSet("snapshots")) {
            a.save(parser.value("snapshots") + "/" + test.name + "-qcm.png");
            b.save(parser.value("snapshots") + "/" + test.name + "-qavsi.png");
        }
    }
    for (bool unequal : {false, true}) {
        Case test{unequal ? "blur" : "analytic", unequal,
            unequal ? QVector4D(4,12,20,8) : QVector4D(16,16,16,16)};
        auto patch = [&](const Case &value) {
            return capture(value).copy(QRect(QPoint(560,80),
                QSize(value.caster.width() + 160, value.caster.height() + 160)));
        };
        const auto full = patch(test);
        test.opacity = .5;
        const auto half = patch(test);
        if (full.isNull() || half.isNull())
            return 6;
        const QRect caster(QPoint(80,80), test.caster);
        const int opacityError = linearError(full, half, caster, test.background);
        test.opacity = 1;
        test.ink = QColor::fromRgbF(0,0,0,.5);
        const int alphaError = linearError(full, patch(test), caster, test.background);
        test.ink = QColor::fromRgbF(.15,.4,.65,.5);
        const auto colored = patch(test);
        if (colored.isNull())
            return 6;
        const int premultipliedError = sourceOverBoundsError(colored, caster, test.background, test.ink);
        test.ink = QColor::fromRgbF(.15,.4,.65,0);
        const auto clear = patch(test);
        if (clear.isNull())
            return 6;
        const QImage background = [&] { QImage out(clear.size(), clear.format()); out.fill(test.background); return out; }();
        const auto clearMetric = difference(clear, background, caster, test.background);
        const bool passed = opacityError <= 2 && alphaError <= 2 && premultipliedError <= 1
            && clearMetric["maxChannelError8bit"].toInt() == 0;
        failures += !passed;
        invariants.append(QJsonObject{{"path", test.name}, {"linearOpacityMaxError8bit", opacityError},
            {"colorAlphaMaxError8bit", alphaError}, {"transparentColorMaxError8bit", clearMetric["maxChannelError8bit"]},
            {"premultipliedSourceOverBoundsMaxError8bit", premultipliedError},
            {"passed", passed}});
    }
    failures += !warnings.isEmpty() || !window->isExposed();
    QJsonObject report{{"qt", qVersion()}, {"backend", backend}, {"screen", left->name()},
        {"dpr", window->devicePixelRatio()}, {"source", "same-process QCM229bc3e6 / current Qavsi native patches, same frame, integer-aligned DPR1"},
        {"cases", results}, {"qtOpacityInvariants", invariants}, {"warnings", QJsonArray::fromStringList(warnings)},
        {"safeCutoutBoundaryChecks", boundaryChecks},
        {"failures", failures}, {"note", "Raw colored cases are diagnostic; no reference normalization. ROI excludes opaque caster AABB, keeps complete80px halo."}};
    const auto output = parser.value("output");
    QDir().mkpath(QFileInfo(output).absolutePath());
    QFile file(output);
    const auto json = QJsonDocument(report).toJson(QJsonDocument::Indented);
    if (!file.open(QIODevice::WriteOnly) || file.write(json) != json.size())
        return 7;
    qInfo().noquote() << "PARITY_REPORT" << output << "failures" << failures;
    return failures ? 1 : 0;
}
