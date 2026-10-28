#include <QImage>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QQuickWindow>
#include <QTest>

int checkProgressInactiveUpdates(QQuickWindow &window)
{
    auto *bar = window.findChild<QQuickItem *>(QStringLiteral("comparison.progress.linear"));
    if (!bar || bar->property("total").toReal() <= 0) {
        qCritical() << "FAIL: the consumer exposes a bounded native progress fixture";
        return 1;
    }
    const auto previousMotion = window.property("reducedMotion");
    const auto previousEnabled = bar->property("enabled");
    const auto previousCompleted = bar->property("completed");
    const auto previousUnknown = bar->property("unknown");
    const qreal total = bar->property("total").toReal();
    const auto capture = [bar]() -> QImage {
        const auto grab = bar->grabToImage();
        return grab && QTest::qWaitFor([&] { return !grab->image().isNull(); })
            ? grab->image() : QImage();
    };
    window.setProperty("reducedMotion", true);
    bar->setProperty("unknown", false);
    bar->setProperty("enabled", false);
    bar->setProperty("completed", total * 0.2);
    const auto before = capture();
    window.setProperty("reducedMotion", false);
    bar->setProperty("completed", total * 0.8);
    const auto after = capture();
    const bool rendered = !before.isNull() && before.size() == after.size()
        && before.pixelColor(before.width() / 2, before.height() / 2)
            != after.pixelColor(after.width() / 2, after.height() / 2);
    const bool updated = !bar->property("enabled").toBool()
        && qAbs(bar->property("position").toReal() - 0.8) < 0.001 && rendered;
    window.setProperty("reducedMotion", true);
    bar->setProperty("completed", previousCompleted);
    bar->setProperty("unknown", previousUnknown);
    bar->setProperty("enabled", previousEnabled);
    window.setProperty("reducedMotion", previousMotion);
    if (!updated)
        qCritical() << "FAIL: disabled native progress renders programmatic updates without a running animation clock";
    return updated ? 0 : 1;
}
