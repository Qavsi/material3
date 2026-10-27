// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include "menu-motion-checks.h"

#include <QByteArray>
#include <QMetaObject>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSignalSpy>
#include <QTest>
#include <QVariant>
#include <cmath>
#include <memory>

namespace {
QQuickItem *namedItem(QQuickItem *item, const QString &name)
{
    if (!item || item->objectName() == name)
        return item;
    for (auto *child : item->childItems()) {
        if (auto *found = namedItem(child, name))
            return found;
    }
    return nullptr;
}

bool near(qreal actual, qreal expected)
{
    return std::abs(actual - expected) < 0.002;
}
} // namespace

void checkMenuMotion(QQmlApplicationEngine &engine, QQuickWindow &window,
                     bool hardware, void (*expect)(bool, const char *))
{
    if (!expect)
        return;
    struct RestorePolicy {
        QQuickWindow &window;
        QVariant dark;
        QVariant reduced;
        ~RestorePolicy()
        {
            window.setProperty("darkMode", dark);
            window.setProperty("reducedMotion", reduced);
        }
    } restore {window, window.property("darkMode"), window.property("reducedMotion")};
    window.setProperty("reducedMotion", true);

    QQmlComponent component(&engine);
    component.setData(QByteArrayLiteral(R"qml(
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style as M3
Item {
    id: root
    property alias popup: menu
    property alias row: action
    SK.Menu {
        id: menu
        parent: root
        x: 24
        y: 96
        popupType: SK.Popup.Item
        modal: true
        dim: false
        focus: true
        enter: M3.Material3MenuEnterTransition { control: menu }
        exit: M3.Material3MenuExitTransition { control: menu }
        SK.MenuItem { id: action; text: "Action" }
        SK.MenuItem { text: "Unavailable"; enabled: false }
    }
}
)qml"), QUrl());
    std::unique_ptr<QObject> owner(component.createWithInitialProperties({
        {QStringLiteral("parent"), QVariant::fromValue(window.contentItem())}
    }));
    expect(owner != nullptr, "native menu and public transition helpers create through the module API");
    if (!owner)
        return;
    QPointer<QObject> menu = owner->property("popup").value<QObject *>();
    auto *row = qobject_cast<QQuickItem *>(owner->property("row").value<QObject *>());
    expect(menu && row, "menu smoke fixture keeps native Menu and MenuItem");
    if (!menu || !row)
        return;
    auto *enter = menu->property("enter").value<QObject *>();
    auto *exit = menu->property("exit").value<QObject *>();
    expect(enter && exit, "native popup owns the opt-in enter and exit helpers");
    if (!enter || !exit)
        return;
    expect(enter->property("effectiveDuration").toInt() == 0
               && exit->property("effectiveDuration").toInt() == 0,
           "reduced motion makes native popup transitions immediate");

    for (bool dark : {false, true}) {
        window.setProperty("darkMode", dark);
        QMetaObject::invokeMethod(menu, "open");
        expect(QTest::qWaitFor([&] { return menu->property("opened").toBool(); }, 1000),
               "native menu opens with reduced motion in both themes");
        auto *background = namedItem(row, QStringLiteral("material3.menuitem.background"));
        expect(background, "StyleKit MenuItem uses the shared ripple background");
        if (!background) {
            QMetaObject::invokeMethod(menu, "close");
            continue;
        }
        QSignalSpy triggered(row, SIGNAL(triggered()));
        const QPoint point = row->mapToScene(QPointF(row->width() / 4, row->height() / 4)).toPoint();
        QTest::mouseMove(&window, point);
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, point);
        expect(row->property("pressed").toBool(), "ripple observer preserves native pressed state");
        expect(near(background->property("stateLayerOpacity").toReal(), 0.10)
                   && near(background->property("rippleOpacity").toReal(), 0)
                   && !background->property("rippleRunning").toBool(),
               "reduced motion retains static QCM .10 menu feedback without an animated wave");
        const bool metal = window.rendererInterface()->graphicsApi() == QSGRendererInterface::Metal;
        expect(background->property("feedbackRenderer").toString() == (metal ? "shader" : "painter"),
               "menu feedback reuses the existing Metal shader or painter fallback");
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, point);
        expect(QTest::qWaitFor([&] { return !menu->property("visible").toBool(); }, 1000)
                   && triggered.size() == 1,
               "one native pointer action triggers once and closes its menu");
        expect(!background->property("rippleRunning").toBool(), "closed menu leaves no running ripple");
    }
    window.setProperty("reducedMotion", false);
    auto *style = window.property("materialStyle").value<QObject *>();
    const bool reduced = style && style->property("effectiveReducedMotion").toBool();
    expect(enter->property("effectiveDuration").toInt() == (reduced ? 0 : 300)
               && exit->property("effectiveDuration").toInt() == (reduced ? 0 : 150),
           "normal-motion helper recipe is QCM 300/150ms and respects the OS preference");
    qInfo() << "MENU MOTION smoke" << "hardware" << hardware << "effectiveReduced" << reduced;
}
