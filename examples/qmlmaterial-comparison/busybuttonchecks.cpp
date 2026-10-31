// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include <QImage>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QQuickWindow>
#include <QTest>

int checkBusyButtons(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool ok, const char *message) {
        if (!ok) { ++failures; qCritical() << "FAIL:" << message; }
    };
    auto *gallery = window.findChild<QQuickItem *>("comparison.buttonIndicators");
    auto *button = window.findChild<QQuickItem *>("comparison.buttonIndicator.button");
    auto *icon = window.findChild<QQuickItem *>("comparison.buttonIndicator.icon");
    expect(gallery && button && icon, "the consumer exposes native loading buttons");
    if (!gallery || !button || !icon) return failures;
    const auto content = [](QQuickItem *item) { return item->property("contentItem").value<QQuickItem *>(); };
    auto *buttonContent = content(button);
    auto *iconContent = content(icon);
    if (!buttonContent || !iconContent) return 1;
    const auto previousMotion = window.property("reducedMotion");
    const auto previousBusy = gallery->property("iconBusy");
    const auto previousProgress = gallery->property("iconProgress");
    window.setProperty("reducedMotion", true);
    const auto reveal = [&](QQuickItem *target) {
        window.grabWindow();
        for (auto *ancestor = target->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
            auto *viewportContent = ancestor->property("contentItem").value<QQuickItem *>();
            if (!viewportContent || !ancestor->property("contentY").isValid()) continue;
            const qreal maximum = qMax<qreal>(0, ancestor->property("contentHeight").toReal() - ancestor->height());
            ancestor->setProperty("contentY", qBound<qreal>(0,
                target->mapToItem(viewportContent, QPointF()).y() - 16, maximum));
        }
        window.grabWindow();
    };
    const auto capture = [](QQuickItem *item) -> QImage {
        const auto grab = item->grabToImage();
        return grab && QTest::qWaitFor([&] { return !grab->image().isNull(); })
            ? grab->image() : QImage();
    };
    reveal(button);
    const auto buttonSize = button->size();
    const auto caption = button->property("text");
    const auto enabled = button->property("enabled");
    const auto checked = button->property("checked");
    const auto idleButton = capture(button);
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
                     button->mapToScene(QPointF(button->width() / 2, button->height() / 2)).toPoint());
    expect(buttonContent->property("busy").toInt() == 1 && capture(button) != idleButton
               && button->size() == buttonSize,
           "native activation shows busy content without changing intrinsic button size");
    expect(QTest::qWaitFor([&] { return buttonContent->property("busy").toInt() == 0; }, 2500)
               && button->property("text") == caption && button->property("enabled") == enabled
               && button->property("checked") == checked && button->size() == buttonSize,
           "job completion restores content while native state and caller bindings remain intact");
    const auto iconSize = icon->size();
    const auto idleIcon = capture(icon);
    gallery->setProperty("iconBusy", 1);
    const auto busy = capture(icon);
    gallery->setProperty("iconBusy", 2);
    gallery->setProperty("iconProgress", 0.0);
    const auto empty = capture(icon);
    gallery->setProperty("iconProgress", .25);
    const auto quarter = capture(icon);
    gallery->setProperty("iconProgress", .75);
    expect(!busy.isNull() && busy != empty && quarter != capture(icon) && icon->size() == iconSize,
           "static reduced-motion busy remains visible and determinate progress changes the arc");
    gallery->setProperty("iconBusy", previousBusy);
    gallery->setProperty("iconProgress", previousProgress);
    expect(capture(icon) == idleIcon && icon->size() == iconSize,
           "the same native icon-only button restores its icon and dimensions");
    window.setProperty("reducedMotion", previousMotion);
    return failures;
}
