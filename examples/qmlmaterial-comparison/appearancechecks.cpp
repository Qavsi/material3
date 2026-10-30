// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include <QColor>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTest>

int checkAppearancePanel(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool ok, const char *message) {
        if (!ok) { ++failures; qCritical() << "FAIL:" << message; }
    };
    QPointer<QObject> panel;
    const auto findVisual = [](auto &&self, QQuickItem *root, const QString &name) -> QQuickItem * {
        if (!root) return nullptr;
        if (root->objectName() == name) return root;
        for (auto *child : root->childItems())
            if (auto *found = self(self, child, name)) return found;
        return nullptr;
    };
    const auto item = [&](const char *name) -> QQuickItem * {
        return findVisual(findVisual, window.contentItem(), QString::fromLatin1(name));
    };
    const auto click = [&](QQuickItem *target) {
        if (target) QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
            target->mapToScene(QPointF(target->width() / 2, target->height() / 2)).toPoint());
    };
    auto *open = item("comparison.appearance.open");
    expect(open, "the comparison exposes its appearance drawer");
    if (!open) return failures;

    const auto seed = window.property("seedColor");
    const auto scheme = window.property("colorScheme");
    const auto dark = window.property("darkMode");
    QPointer<QQuickItem> previousFocus = window.activeFocusItem();
    QPointer<QQuickItem> field = item("comparison.field.filled");
    const auto fieldText = field ? field->property("text") : QVariant();
    if (field) field->setProperty("text", QStringLiteral("Caller text survives palette changes"));
    auto *style = window.property("materialStyle").value<QObject *>();
    const auto primary = [&] {
        auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
        return tokens ? tokens->property("primary").value<QColor>() : QColor();
    };
    const auto before = primary();
    click(open);
    expect(QTest::qWaitFor([&] {
        panel = window.findChild<QObject *>(QStringLiteral("comparison.appearance"));
        return panel && panel->property("opened").toBool();
    }), "native drawer opens from the header");
    if (panel) {
        auto *rainbow = item("comparison.appearance.scheme.rainbow");
        auto *red = item("comparison.appearance.seed.red");
        expect(rainbow && red, "drawer exposes QCM palette and seed choices");
        click(rainbow);
        if (red) {
            red->forceActiveFocus(Qt::TabFocusReason);
            QTest::keyClick(&window, Qt::Key_Space);
        }
        expect(QTest::qWaitFor([&] {
            return rainbow && red && rainbow->property("checked").toBool()
                && red->property("checked").toBool()
                && window.property("seedColor").value<QColor>() == QColor(QStringLiteral("#f44336"))
                && window.property("colorScheme") == rainbow->property("schemeValue")
                && primary().isValid() && primary() != before;
        }), "keyboard seed and palette selection update the live Theme");

        auto *brightness = item("comparison.appearance.brightness");
        click(brightness);
        expect(QTest::qWaitFor([&] { return window.property("darkMode").toBool() != dark.toBool(); }),
               "drawer brightness changes the active Theme");
        expect(field && field == item("comparison.field.filled")
                   && field->property("text").toString() == QStringLiteral("Caller text survives palette changes"),
               "Theme changes preserve native controls and caller content");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(QTest::qWaitFor([&] { return !panel || !panel->property("visible").toBool(); }),
               "Escape dismisses the drawer");

        click(open);
        expect(QTest::qWaitFor([&] {
            auto *selected = item("comparison.appearance.seed.red");
            return panel && panel->property("opened").toBool()
                && selected && selected->property("checked").toBool();
        }), "reopening retains the application-owned seed");
        QTest::keyClick(&window, Qt::Key_Escape);
        QTest::qWaitFor([&] {
            auto *current = window.findChild<QObject *>(QStringLiteral("comparison.appearance"));
            return !current || !current->property("visible").toBool();
        });
    }
    window.setProperty("seedColor", seed);
    window.setProperty("colorScheme", scheme);
    window.setProperty("darkMode", dark);
    if (field) field->setProperty("text", fieldText);
    if (previousFocus) previousFocus->forceActiveFocus(Qt::OtherFocusReason);
    return failures;
}
