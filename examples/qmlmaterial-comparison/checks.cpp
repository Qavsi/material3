#include <QGuiApplication>
#include <QMetaObject>
#include <QMetaEnum>
#include <QMetaProperty>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>

namespace {
int assertions = 0;
int failures = 0;
void expect(bool condition, const char *message)
{
    ++assertions;
    if (!condition) {
        ++failures;
        qCritical() << "FAIL:" << message;
    }
}

QQuickItem *findItem(QQuickItem *parent, const QString &name)
{
    if (parent->objectName() == name)
        return parent;
    for (auto *child : parent->childItems()) {
        if (auto *result = findItem(child, name))
            return result;
    }
    return nullptr;
}

QQuickItem *control(QQuickWindow &window, const QString &name)
{
    auto *result = findItem(window.contentItem(), name);
    expect(result, qPrintable(name + " is available in the consumer"));
    return result;
}

void reveal(QQuickItem *item)
{
    for (auto *ancestor = item->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
        auto *content = ancestor->property("contentItem").value<QQuickItem *>();
        if (!content || !ancestor->property("contentY").isValid())
            continue;
        const auto position = item->mapToItem(content, QPointF());
        const qreal maxY = qMax<qreal>(0, ancestor->property("contentHeight").toReal() - ancestor->height());
        ancestor->setProperty("contentY", qBound<qreal>(0, position.y(), maxY));
    }
}

void checkSelection(QQuickWindow &window)
{
    auto *icon = control(window, "comparison.iconButton.0.enabled");
    auto *first = control(window, "comparison.connected.files.0");
    auto *second = control(window, "comparison.connected.files.1");
    if (!icon || !first || !second)
        return;
    reveal(icon);
    QSignalSpy toggled(icon, SIGNAL(toggled()));
    icon->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(icon->property("checked").toBool() && toggled.size() == 1,
           "Space toggles an icon button through its native checked API");
    reveal(second);
    second->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(second->property("checked").toBool() && !first->property("checked").toBool(),
           "selecting a connected action preserves exclusive selection");
}

void checkFab(QQuickWindow &window)
{
    auto *fab = control(window, "comparison.fab.extended");
    if (!fab)
        return;
    reveal(fab);
    const auto label = fab->property("text").toString();
    const auto expandedWidth = fab->width();
    fab->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    const auto display = fab->metaObject()->property(fab->metaObject()->indexOfProperty("display")).enumerator();
    const int iconOnly = display.keyToValue("IconOnly");
    expect(fab->property("display").toInt() == iconOnly && fab->width() < expandedWidth
               && fab->property("text").toString() == label,
           "Create collapses to an icon while preserving its source label");
    QTest::keyClick(&window, Qt::Key_Space);
    expect(fab->property("display").toInt() != iconOnly && fab->width() == expandedWidth,
           "a second Create activation restores the expanded control");
}

void checkMenu(QQuickWindow &window)
{
    auto *trigger = control(window, "comparison.split.filled.menuButton");
    auto *menu = trigger ? trigger->findChild<QObject *>("comparison.split.filled.menu") : nullptr;
    expect(menu, "the consumer exposes its native menu selector");
    if (!trigger || !menu)
        return;
    reveal(trigger);
    trigger->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(menu->property("opened").toBool(), "reduced motion opens the native menu immediately");
    QQuickItem *row = nullptr;
    QMetaObject::invokeMethod(menu, "itemAt", Q_RETURN_ARG(QQuickItem *, row), Q_ARG(int, 0));
    expect(row, "native Menu.itemAt exposes its action");
    if (!row) {
        QMetaObject::invokeMethod(menu, "close");
        return;
    }
    QSignalSpy triggered(row, SIGNAL(triggered()));
    QTest::keyClick(&window, Qt::Key_Down);
    QTest::keyClick(&window, Qt::Key_Return);
    expect(triggered.size() == 1 && !menu->property("visible").toBool(),
           "keyboard selection triggers one menu action and closes the popup");
    trigger->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    QTest::keyClick(&window, Qt::Key_Escape);
    expect(!menu->property("visible").toBool(), "Escape dismisses an open menu");
}
} // namespace

int checkComparison(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    expect(QTest::qWaitForWindowExposed(&window), "the comparison consumer exposes");
    window.requestActivate();
    window.setProperty("reducedMotion", true);
    checkSelection(window);
    checkFab(window);
    checkMenu(window);
    expect(!window.grabWindow().isNull(), "the comparison consumer renders with its imported kit and icons");
    expect(warnings.isEmpty(), "gallery interactions produce no QML warnings");
    qInfo() << "Qt" << qVersion() << "comparison assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
