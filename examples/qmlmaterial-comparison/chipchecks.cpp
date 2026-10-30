// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include <QCoreApplication>
#include <QInputMethodEvent>
#include <QQmlEngine>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>

int checkAdvancedChips(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool ok, const char *message) {
        if (!ok) { ++failures; qCritical() << "FAIL:" << message; }
    };
    const auto item = [&](const char *name) {
        return window.findChild<QQuickItem *>(QString::fromLatin1(name));
    };
    auto *chip = item("comparison.chip.avatar");
    auto *edit = item("comparison.chip.edit");
    auto *drag = item("comparison.chip.drag");
    expect(chip && edit && drag, "the consumer exposes editable and draggable native chips");
    if (!chip || !edit || !drag) return failures;
    const auto reveal = [&](QQuickItem *target) {
        window.grabWindow();
        for (auto *ancestor = target->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
            auto *content = ancestor->property("contentItem").value<QQuickItem *>();
            if (!content || !ancestor->property("contentY").isValid()) continue;
            const qreal maximum = qMax<qreal>(0, ancestor->property("contentHeight").toReal() - ancestor->height());
            ancestor->setProperty("contentY", qBound<qreal>(0, target->mapToItem(content, QPointF()).y() - 16, maximum));
        }
    };
    const auto previousLabel = chip->property("label");
    const auto previousChecked = chip->property("checked");
    reveal(edit);
    edit->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(QTest::qWaitFor([&] {
        auto *editor = item("comparison.chip.editor");
        return editor && editor->hasActiveFocus();
    }), "the opt-in edit delegate receives native keyboard focus");
    if (auto *editor = item("comparison.chip.editor")) {
        QMetaObject::invokeMethod(editor, "selectAll");
        QInputMethodEvent commit;
        commit.setCommitString(QStringLiteral("Reviewed"));
        QCoreApplication::sendEvent(editor, &commit);
        QTest::keyClick(&window, Qt::Key_Return);
        expect(QTest::qWaitFor([&] {
            return !chip->property("editing").toBool()
                && !item("comparison.chip.editor")
                && chip->property("text").toString() == QStringLiteral("Reviewed")
                && chip->property("checked") == previousChecked;
        }), "the application commits editing without changing native chip selection");
        chip->setProperty("label", previousLabel);
        expect(chip->property("text") == previousLabel,
               "editing preserves the caller-owned native chip text binding");
    }
    const auto dragX = drag->x();
    reveal(drag);
    const auto start = drag->mapToScene(QPointF(drag->width() / 2, drag->height() / 2)).toPoint();
    QSignalSpy clicked(drag, SIGNAL(clicked()));
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, start);
    QTest::mouseMove(&window, start + QPoint(32, 0), 20);
    QTest::mouseMove(&window, start + QPoint(64, 0), 20);
    const auto active = [&] {
        return QQmlProperty::read(drag, QStringLiteral("Drag.active"), QQmlEngine::contextForObject(drag)).toBool();
    };
    expect(QTest::qWaitFor(active) && drag->x() > dragX,
           "the application's native DragHandler activates Qt Drag without a model mutation");
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, start + QPoint(64, 0));
    expect(!active() && clicked.isEmpty() && !drag->property("checked").toBool(),
           "a completed drag does not activate or select the native chip");
    drag->setX(dragX);
    return failures;
}
