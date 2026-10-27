#include <QGuiApplication>
#include <QAccessible>
#include <QImage>
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
        ancestor->setProperty("contentY", qBound<qreal>(0, position.y() - 16, maxY));
    }
}

QImage captionBand(QQuickWindow &window, QQuickItem *field)
{
    const auto image = window.grabWindow();
    if (image.isNull())
        return {};
    const auto position = field->mapToScene(QPointF(field->property("leftPadding").toReal(), -7));
    const qreal dpr = image.devicePixelRatio();
    return image.copy(QRect(qRound(position.x() * dpr), qRound(position.y() * dpr),
                           qRound(70 * dpr), qRound(5 * dpr)));
}

void checkInputSizes(QQuickWindow &window)
{
    struct Expected { const char *name; int height; int pixels; qreal tracking; };
    const Expected sizes[] = {
        {"XS", 40, 12, 0.4}, {"S", 48, 14, 0.25}, {"M", 56, 16, 0.5},
        {"L", 64, 16, 0.5}, {"XL", 72, 16, 0.5}
    };
    for (const auto &size : sizes) {
        auto *item = control(window, QStringLiteral("comparison.field.size.") + QLatin1String(size.name));
        if (!item)
            continue;
        const auto font = item->property("font").value<QFont>();
        expect(qAbs(item->height() - size.height) <= 0.5 && font.pixelSize() == size.pixels
                   && qAbs(font.letterSpacing() - size.tracking) < 0.01,
               qPrintable(QStringLiteral("TextField %1 matches QCM height and typography").arg(size.name)));
    }
    auto *item = control(window, QStringLiteral("comparison.field.size.XS"));
    if (item) {
        auto font = item->property("font").value<QFont>();
        font.setPixelSize(18);
        item->setProperty("font", font);
        expect(item->property("font").value<QFont>().pixelSize() == 18,
               "an explicit caller font keeps ownership over a size recipe");
    }
}

void checkTextField(QQuickWindow &window)
{
    auto *field = control(window, "comparison.field.outlined");
    if (!field)
        return;
    reveal(field);
    field->setFocus(false, Qt::OtherFocusReason);
    const auto resting = captionBand(window, field);
    field->forceActiveFocus(Qt::TabFocusReason);
    const auto focused = captionBand(window, field);
    expect(!resting.isNull() && !focused.isNull() && resting != focused,
           "focusing an outlined TextField raises the visible caption above its outline");
    QTest::keyClick(&window, Qt::Key_Q);
    field->setFocus(false, Qt::OtherFocusReason);
    expect(field->property("text").toString() == QStringLiteral("q")
               && captionBand(window, field) != resting,
           "native text editing retains the floating caption after focus leaves");
    field->setProperty("text", QString());
    expect(captionBand(window, field) == resting,
           "clearing an unfocused field restores its resting caption");
    auto *filled = control(window, "comparison.field.filled");
    auto *readOnly = control(window, "comparison.field.readOnly");
    auto *invalid = control(window, "comparison.field.invalid");
    if (!filled || !readOnly || !invalid)
        return;
    reveal(filled);
    filled->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Q);
    expect(filled->property("text").toString() == QStringLiteral("q"),
           "the filled variation preserves native text editing");
    filled->setProperty("text", QString());
    reveal(readOnly);
    readOnly->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Q);
    expect(readOnly->property("text").toString() == QStringLiteral("Qavsi"),
           "a styled read-only field cannot be edited");
    expect(!invalid->property("acceptableInput").toBool(),
           "TextField retains its native validator result");
    invalid->setProperty("text", QStringLiteral("42"));
    expect(invalid->property("acceptableInput").toBool(),
           "native validation updates when valid input replaces an error");
    invalid->setProperty("text", QStringLiteral("A long username"));
}

void checkFieldAccessories(QQuickWindow &window)
{
    auto *plain = control(window, "comparison.field.outlined");
    auto *amount = control(window, "comparison.field.amount");
    auto *email = control(window, "comparison.field.filled");
    if (!plain || !amount || !email)
        return;
    plain->setProperty("showSupportingText", true);
    reveal(plain);
    window.grabWindow();
    const QRectF outlinedCaret = plain->property("cursorRectangle").toRectF();
    expect(qAbs(outlinedCaret.center().y() - (plain->height() - plain->property("bottomInset").toReal()) / 2) <= 1,
           "supporting text keeps an outlined field's editing line centered in its container");
    plain->setProperty("showSupportingText", false);
    email->setProperty("showSupportingText", true);
    expect(amount->height() > plain->height()
               && amount->property("leftPadding").toReal() > plain->property("leftPadding").toReal()
               && amount->property("rightPadding").toReal() > plain->property("rightPadding").toReal(),
           "prefix, suffix and supporting text reserve space around the native input");
    expect(qAbs(email->property("leftPadding").toReal() - plain->property("leftPadding").toReal() - 36) <= 0.5,
           "the filled field reserves QCM's 24-pixel leading icon and 12-pixel gap on first load");
    expect(email->property("leftPadding").toReal() > plain->property("leftPadding").toReal()
               && email->property("rightPadding").toReal() > plain->property("rightPadding").toReal(),
           "leading and trailing icons reserve native editing space");
    reveal(email);
    email->forceActiveFocus(Qt::TabFocusReason);
    const QRectF caret = email->property("cursorRectangle").toRectF();
    expect(qAbs(caret.bottom() - (email->height() - email->property("bottomInset").toReal() - 8)) <= 1,
           "the filled field caret stays above the container bottom by QCM's eight-pixel input padding");
    const auto image = window.grabWindow();
    const qreal dpr = image.devicePixelRatio();
    const auto iconOrigin = email->mapToScene(QPointF(plain->property("leftPadding").toReal(), 16));
    const auto icon = image.copy(QRect(qRound(iconOrigin.x() * dpr), qRound(iconOrigin.y() * dpr),
                                       qRound(24 * dpr), qRound(24 * dpr)));
    bool visibleIcon = false;
    for (int y = 0; y < icon.height() && !visibleIcon; ++y)
        for (int x = 0; x < icon.width(); ++x)
            if (icon.pixel(x, y) != icon.pixel(0, 0)) {
                visibleIcon = true;
                break;
            }
    expect(visibleIcon, "the leading icon is visibly rendered above the filled container");
    auto *accessible = QAccessible::queryAccessibleInterface(email);
    expect(accessible && accessible->text(QAccessible::Description) == QStringLiteral("Only used for notifications."),
           "supporting text is exposed as the native field's accessible description");
    expect(accessible && accessible->text(QAccessible::Name) == email->property("placeholderText").toString(),
           "adding a supporting description preserves the field's accessible label");
    email->setProperty("serverError", true);
    const auto error = QStringLiteral("Please use a different email address. The server could not accept this address.");
    expect(accessible && accessible->text(QAccessible::Description) == error,
           "an application error replaces supporting text in the accessible description");
    const auto errorHeight = email->height();
    const auto oldWidth = window.width();
    const auto oldFieldWidth = email->width();
    window.setWidth(280);
    expect(QTest::qWaitFor([&] { return email->height() > errorHeight; }, 200),
           "wrapped supporting/error text increases the native field height");
    window.setWidth(oldWidth);
    (void)QTest::qWaitFor([&] { return email->width() == oldFieldWidth; }, 200);
    email->setProperty("serverError", false);
    amount->setProperty("showAffixes", false);
    expect(amount->property("leftPadding") == plain->property("leftPadding")
               && amount->property("rightPadding") == plain->property("rightPadding"),
           "hiding affixes restores the caller's native padding bindings");
    amount->setProperty("extraInputPadding", 96.0);
    amount->setProperty("showAffixes", true);
    expect(amount->property("rightPadding").toReal() == plain->property("rightPadding").toReal() + 96,
           "a caller's nondefault native padding keeps ownership when affixes return");
    amount->setProperty("extraInputPadding", 100.0);
    expect(amount->property("rightPadding").toReal() == plain->property("rightPadding").toReal() + 100,
           "the caller's native padding binding remains live");
    email->setProperty("showSupportingText", false);
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
    checkTextField(window);
    checkFieldAccessories(window);
    checkInputSizes(window);
    checkSelection(window);
    checkFab(window);
    checkMenu(window);
    expect(!window.grabWindow().isNull(), "the comparison consumer renders with its imported kit and icons");
    expect(warnings.isEmpty(), "gallery interactions produce no QML warnings");
    qInfo() << "Qt" << qVersion() << "comparison assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
