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

// Exercise the native control and the consumer's public content override, not private timers.
int checkBusyIndicatorTiming(QQuickWindow &window)
{
    auto *busy = window.findChild<QQuickItem *>(QStringLiteral("comparison.progress.busy.delayed"));
    auto *quick = window.findChild<QQuickItem *>(QStringLiteral("comparison.progress.busy.quickTask"));
    auto *normal = window.findChild<QQuickItem *>(QStringLiteral("comparison.progress.busy.normalTask"));
    if (!busy || !quick || !normal)
        return 1;
    const auto painted = [busy]() {
        const auto grab = busy->grabToImage();
        if (!grab || !QTest::qWaitFor([&] { return !grab->image().isNull(); }))
            return false;
        const QImage image = grab->image();
        for (int y = 0; y < image.height(); ++y)
            for (int x = 0; x < image.width(); ++x)
                if (qAlpha(image.pixel(x, y)))
                    return true;
        return false;
    };
    const auto click = [&window](QQuickItem *item) {
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
            item->mapToScene(QPointF(item->width() / 2, item->height() / 2)).toPoint());
    };
    click(quick);
    const bool quickStarted = busy->property("running").toBool();
    const bool delayed = !painted();
    const bool quickDone = QTest::qWaitFor([&] { return !busy->property("running").toBool(); }, 500);
    const bool noFlash = !painted();
    click(normal);
    const bool appeared = QTest::qWaitFor(painted, 500);
    const bool normalDone = QTest::qWaitFor([&] { return !busy->property("running").toBool(); }, 700);
    const bool held = painted();
    const bool hidden = QTest::qWaitFor([&] { return !painted(); }, 800);
    busy->setProperty("shown", false);
    const bool callerHides = !busy->isVisible();
    busy->setProperty("shown", true);
    const bool bindingPreserved = busy->isVisible() && !busy->property("running").toBool();
    const bool passed = quickStarted && delayed && quickDone && noFlash && appeared && normalDone
        && held && hidden && callerHides && bindingPreserved;
    if (!passed)
        qCritical() << "FAIL: native busy timing" << quickStarted << delayed << quickDone << noFlash
                    << appeared << normalDone << held << hidden << callerHides << bindingPreserved;
    return passed ? 0 : 1;
}
