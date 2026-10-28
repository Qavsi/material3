#include <QColor>
#include <QDebug>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QScopedPointer>
#include <QTest>
#include <QImage>

namespace {
QQuickItem *findItem(QQuickItem *item, const QString &name)
{
    if (item->objectName() == name)
        return item;
    for (auto *child : item->childItems())
        if (auto *result = findItem(child, name))
            return result;
    return nullptr;
}
}

int checkInlineColorPicker(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool condition, const char *message) {
        if (!condition) { ++failures; qCritical() << "FAIL:" << message; }
    };
    auto *picker = findItem(window.contentItem(), QStringLiteral("comparison.pickers.color.inline"));
    expect(picker, "inline color picker is exposed by the consumer");
    if (!picker) return 1;
    auto *gallery = picker->parentItem();
    const auto original = gallery->property("selectedColor");
    const QColor initial = QColor::fromRgbF(0.2, 0.4, 0.6, 0.5);
    gallery->setProperty("selectedColor", initial);
    QSignalSpy requested(picker, SIGNAL(colorChangeRequested(QColor)));
    QMetaObject::invokeMethod(picker, "setHue", Q_ARG(double, 0.75));
    QMetaObject::invokeMethod(picker, "setSaturation", Q_ARG(double, 0.8));
    QMetaObject::invokeMethod(picker, "setValue", Q_ARG(double, 0.7));
    auto value = picker->property("color").value<QColor>();
    expect(requested.size() == 3 && qAbs(value.hsvHueF() - 0.75) < 0.002
        && qAbs(value.alphaF() - 0.5) < 0.002, "HSV edits request changes and preserve alpha");
    picker->setProperty("mode", 1);
    QMetaObject::invokeMethod(picker, "setR", Q_ARG(double, 0.3));
    value = picker->property("color").value<QColor>();
    expect(qAbs(value.redF() - 0.3) < 0.002 && qAbs(value.alphaF() - 0.5) < 0.002,
        "RGB mode edits preserve alpha");
    bool valid = false;
    QMetaObject::invokeMethod(picker, "setHex", Q_RETURN_ARG(bool, valid), Q_ARG(QString, QStringLiteral("#20408060")));
    value = picker->property("color").value<QColor>();
    expect(valid && value == QColor(0x20, 0x40, 0x80, 0x60), "hex input uses trailing RGBA8 alpha");
    const int beforeInvalid = requested.size();
    QMetaObject::invokeMethod(picker, "setHex", Q_RETURN_ARG(bool, valid), Q_ARG(QString, QStringLiteral("#not-a-color")));
    expect(!valid && requested.size() == beforeInvalid && picker->property("color").value<QColor>() == value,
        "invalid hex leaves the caller color unchanged without a request");
    gallery->setProperty("selectedColor", initial);
    expect(picker->property("color").value<QColor>() == initial, "caller color binding survives all editor requests");
    QMetaObject::invokeMethod(picker, "setSaturation", Q_ARG(double, 0.0));
    QMetaObject::invokeMethod(picker, "setHue", Q_ARG(double, 0.6));
    QMetaObject::invokeMethod(picker, "setSaturation", Q_ARG(double, 0.9));
    expect(qAbs(picker->property("color").value<QColor>().hsvHueF() - 0.6) < 0.002,
        "achromatic edits remember hue when saturation returns");

    QQmlComponent component(qmlEngine(picker));
    component.setData("import Qavsi.Material3.Style\nMaterial3ColorPicker { width: implicitWidth; height: implicitHeight }", QUrl());
    const auto isolated = QScopedPointer<QObject>(component.create());
    expect(!isolated.isNull(), "standalone public inline component can be created");
    if (isolated) {
        const auto before = isolated->property("color");
        QSignalSpy isolatedRequests(isolated.data(), SIGNAL(colorChangeRequested(QColor)));
        QMetaObject::invokeMethod(isolated.data(), "setAlpha", Q_ARG(double, -1.0));
        expect(isolatedRequests.size() == 1 && isolated->property("color") == before
            && isolatedRequests.at(0).at(0).value<QColor>().alpha() == 0,
            "unhandled requests clamp values without mutating the controlled color");

        auto *visual = qobject_cast<QQuickItem *>(isolated.data());
        visual->setParentItem(window.contentItem());
        visual->setZ(1000);
        isolated->setProperty("color", QColor::fromHsvF(0.75, 0.75, 0.5, 0.5));
        QImage painted;
        // The QCM wheel is 240px and centered; the surrounding chip may grow with the application font.
        const auto centerPoint = [&] { return QPoint(qRound(visual->width() / 2), 120); };
        const auto eastPoint = [&] { return centerPoint() + QPoint(108, 0); };
        const auto pixel = [&](QPoint point) {
            return painted.pixelColor(point * window.devicePixelRatio());
        };
        const bool rendered = QTest::qWaitFor([&] {
            painted = window.grabWindow();
            if (painted.isNull()) return false;
            const QColor ring = pixel(eastPoint());
            const QColor triangle = pixel(centerPoint());
            return ring.redF() > 0.85 && ring.greenF() < 0.2 && ring.blueF() < 0.2
                && triangle.blueF() - triangle.redF() > 0.1;
        }, 2000);
        expect(rendered, "the public picker paints its conical ring and SV triangle on the active renderer");
        isolatedRequests.clear();
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, eastPoint());
        expect(isolatedRequests.size() == 1
            && isolatedRequests.last().at(0).value<QColor>().hsvHueF() < 0.002,
            "clicking the reference wheel's east side requests red hue");
        QTest::keyClick(&window, Qt::Key_Right);
        expect(isolatedRequests.size() == 2
            && qAbs(isolatedRequests.last().at(0).value<QColor>().hsvHueF() - (0.75 + 1.0/360)) < 0.002,
            "the focused hue ring requests one degree per arrow key without stealing the caller color");
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, centerPoint());
        const QColor center = isolatedRequests.isEmpty() ? QColor() : isolatedRequests.last().at(0).value<QColor>();
        expect(isolatedRequests.size() == 3 && qAbs(center.hsvSaturationF() - 0.5) < 0.01
            && qAbs(center.valueF() - 2.0/3) < 0.01 && qAbs(center.alphaF() - 0.5) < 0.002,
            "the triangle center requests its barycentric SV color while preserving alpha");
        visual->setEnabled(false);
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, eastPoint());
        expect(isolatedRequests.size() == 3, "disabled wheel input emits no request");
    }
    picker->setProperty("mode", 0);
    gallery->setProperty("selectedColor", original);
    return failures ? 1 : 0;
}
