#include <QGuiApplication>
#include <QAccessible>
#include <QImage>
#include <QMetaObject>
#include <QMetaEnum>
#include <QMetaProperty>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QPointer>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>

int checkPickersCarousel(QQuickWindow &window);

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
    // Settle pending layout before measuring the Flickable scroll offset.
    if (auto *window = item->window())
        window->grabWindow();
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

void checkComboBox(QQuickWindow &window)
{
    auto *basic = control(window, "comparison.combo.basic");
    auto *roles = control(window, "comparison.combo.roles");
    auto *custom = control(window, "comparison.combo.custom");
    if (!basic || !roles || !custom)
        return;
    reveal(basic);
    auto *indicator = basic->property("indicator").value<QQuickItem *>();
    expect(indicator && indicator->isVisible() && indicator->width() > 0 && indicator->height() > 0,
           "the native ComboBox reserves a visible down indicator");
    const auto capture = indicator ? indicator->grabToImage() : nullptr;
    bool arrowPainted = false;
    if (capture && QTest::qWaitFor([&] { return !capture->image().isNull(); })) {
        const QImage image = capture->image();
        for (int y = 0; y < image.height() && !arrowPainted; ++y)
            for (int x = 0; x < image.width() && !arrowPainted; ++x)
                arrowPainted = qAlpha(image.pixel(x, y)) > 0;
    }
    expect(arrowPainted, "the native ComboBox paints its down indicator");
    basic->setProperty("currentIndex", -1);
    basic->setFocus(false, Qt::OtherFocusReason);
    const auto rest = captionBand(window, basic);
    basic->forceActiveFocus(Qt::TabFocusReason);
    expect(captionBand(window, basic) != rest, "ComboBox floats its label on native focus");
    basic->setProperty("currentIndex", 0);
    basic->setFocus(false, Qt::OtherFocusReason);
    expect(QTest::qWaitFor([&] { return captionBand(window, basic) != rest; }, 200),
           "a selected ComboBox keeps its label floated after blur");
    basic->setProperty("selectedChoice", 2);
    expect(basic->property("currentIndex").toInt() == 2 && basic->property("currentText").toString() == QStringLiteral("Third"),
           "the caller's currentIndex binding survives style factory installation");
    auto *model = roles->property("model").value<QObject *>();
    if (model)
        QMetaObject::invokeMethod(model, "move", Q_ARG(int, 0), Q_ARG(int, 1), Q_ARG(int, 1));
    expect(model && roles->property("currentIndex").toInt() == 1 && roles->property("currentValue").toInt() == 10,
           "a currentValue-bound ComboBox keeps its value while model rows move");
    if (model)
        QMetaObject::invokeMethod(model, "move", Q_ARG(int, 1), Q_ARG(int, 0), Q_ARG(int, 1));
    auto *customPopup = custom->property("popup").value<QObject *>();
    auto *customDelegate = custom->property("delegate").value<QObject *>();
    expect(customPopup && customPopup->objectName() == QStringLiteral("comparison.combo.custom.popup")
               && customDelegate && customDelegate == custom->property("callerDelegate").value<QObject *>(),
           "caller-provided ComboBox popup and delegate remain installed");
    reveal(roles);
    roles->forceActiveFocus(Qt::TabFocusReason);
    QSignalSpy activated(roles, SIGNAL(activated(int)));
    QTest::keyClick(&window, Qt::Key_Space);
    auto *popup = roles->property("popup").value<QObject *>();
    expect(popup && popup->property("opened").toBool(), "native ComboBox opens its Material3 popup");
    if (!popup)
        return;
    expect(popup->property("width").toReal() <= 280, "ComboBox popup obeys the QCM maximum width");
    auto *view = popup->property("contentItem").value<QQuickItem *>();
    QQuickItem *firstRow = nullptr;
    QQuickItem *lastRow = nullptr;
    const bool rowsReady = QTest::qWaitFor([&] {
        if (!view)
            return false;
        QMetaObject::invokeMethod(view, "itemAtIndex", Q_RETURN_ARG(QQuickItem *, firstRow), Q_ARG(int, 0));
        QMetaObject::invokeMethod(view, "itemAtIndex", Q_RETURN_ARG(QQuickItem *, lastRow), Q_ARG(int, 2));
        return firstRow && lastRow;
    }, 200);
    expect(rowsReady && firstRow->property("text").toString() == QStringLiteral("Personal workspace"),
           "popup delegates display the model's textRole");
    if (model)
        QMetaObject::invokeMethod(model, "setProperty", Q_ARG(int, 0), Q_ARG(QString, QStringLiteral("title")), Q_ARG(QVariant, QVariant(QStringLiteral("Renamed workspace"))));
    expect(rowsReady && firstRow->property("text").toString() == QStringLiteral("Renamed workspace"),
           "an open ComboBox row follows model role updates");
    roles->setProperty("textRole", QStringLiteral("key"));
    expect(rowsReady && firstRow->property("text").toString() == QStringLiteral("10"),
           "an open ComboBox row follows textRole changes");
    roles->setProperty("textRole", QStringLiteral("title"));
    expect(rowsReady && firstRow->width() == view->width() && lastRow->width() == view->width()
               && firstRow->y() >= 0 && lastRow->y() + lastRow->height() <= view->height() + 0.5,
           "first and last ComboBox rows fit the popup content width and height");
    QTest::keyClick(&window, Qt::Key_Down);
    expect(rowsReady && firstRow->property("checked").toBool(),
           "the selected row stays marked while keyboard highlight moves elsewhere");
    expect(roles->property("currentIndex").toInt() == 0 && roles->property("highlightedIndex").toInt() == 1,
           "keyboard highlighting does not change the committed selection");
    QTest::keyClick(&window, Qt::Key_Return);
    expect(roles->property("currentIndex").toInt() == 1 && roles->property("currentValue").toInt() == 20
               && activated.size() == 1 && !popup->property("visible").toBool(),
           "Enter commits one native selection with its valueRole and closes the popup");
    QTest::keyClick(&window, Qt::Key_Space);
    QTest::keyClick(&window, Qt::Key_End);
    QTest::keyClick(&window, Qt::Key_Escape);
    expect(roles->property("currentIndex").toInt() == 1 && activated.size() == 1,
           "Escape discards the last-row highlight without another activation");
    QTest::keyClick(&window, Qt::Key_Space);
    QMetaObject::invokeMethod(view, "itemAtIndex", Q_RETURN_ARG(QQuickItem *, firstRow), Q_ARG(int, 0));
    if (firstRow) {
        const auto point = firstRow->mapToScene(QPointF(firstRow->width() / 2, firstRow->height() / 2)).toPoint();
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, point);
    }
    expect(roles->property("currentIndex").toInt() == 0 && activated.size() == 2
               && !popup->property("visible").toBool(),
           "pointer selection commits one native activation and dismisses the popup");
    roles->setProperty("selectedWorkspace", 30);
    expect(roles->property("currentIndex").toInt() == 2 && roles->property("currentValue").toInt() == 30
               && activated.size() == 2, "the caller's currentValue binding remains live without synthetic activation");
    const int oldWindowWidth = window.width();
    const qreal oldBasicWidth = basic->width();
    const qreal oldBasicX = basic->x();
    window.setWidth(180);
    window.grabWindow();
    basic->setWidth(64);
    basic->setX(qMax<qreal>(0, basic->parentItem()->width() - basic->width()));
    reveal(basic);
    basic->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    auto *edgePopup = basic->property("popup").value<QObject *>();
    auto *edgeContent = edgePopup ? edgePopup->property("contentItem").value<QQuickItem *>() : nullptr;
    window.grabWindow();
    const auto popupBounds = edgeContent ? edgeContent->mapRectToScene(QRectF(0, 0, edgeContent->width(), edgeContent->height())) : QRectF();
    expect(edgePopup && edgePopup->property("width").toReal() <= window.width()
               && popupBounds.left() >= 0 && popupBounds.right() <= window.width() + 0.5,
           "a compact ComboBox keeps its popup within a narrow window's horizontal bounds");
    QTest::keyClick(&window, Qt::Key_Escape);
    window.setWidth(oldWindowWidth);
    basic->setX(oldBasicX);
    basic->setWidth(oldBasicWidth);
    auto *lifecycleLoader = control(window, "comparison.combo.popupLifecycleLoader");
    if (lifecycleLoader) {
        lifecycleLoader->setProperty("active", true);
        auto *lifecycle = control(window, "comparison.combo.popupLifecycle");
        auto *stockPopup = lifecycle ? lifecycle->property("stockPopup").value<QObject *>() : nullptr;
        const bool installed = lifecycle && stockPopup && QTest::qWaitFor([&] {
            return lifecycle->property("popup").value<QObject *>() != stockPopup;
        });
        if (installed) {
            lifecycle->setProperty("useReplacementPopup", true);
            lifecycle->setProperty("popup", QVariant::fromValue(stockPopup));
        }
        auto *stockView = stockPopup ? stockPopup->property("contentItem").value<QObject *>() : nullptr;
        expect(installed && stockPopup->property("parent").value<QObject *>() == lifecycle
                   && stockView && !stockView->property("model").isNull(),
               "returning from a caller popup to the saved stock popup restores its parent and model");
        lifecycleLoader->setProperty("active", false);
    }
    auto *editable = control(window, "comparison.combo.editable");
    if (editable) {
        expect(editable->property("editText") == editable->property("pendingDraft"),
               "style delegate installation preserves a caller's uncommitted draft");
        editable->setProperty("pendingDraft", QStringLiteral("Updated draft"));
        expect(editable->property("editText").toString() == QStringLiteral("Updated draft"),
               "the caller's draft binding remains live after delegate installation");
        reveal(editable);
        editable->forceActiveFocus(Qt::TabFocusReason);
        editable->setProperty("editText", QStringLiteral("Medium"));
        QSignalSpy accepted(editable, SIGNAL(accepted()));
        QTest::keyClick(&window, Qt::Key_Return);
        expect(editable->property("currentIndex").toInt() == 1 && accepted.size() == 1,
               "editable ComboBox keeps native text acceptance and matching selection");
    }
}

void checkInputSizes(QQuickWindow &window)
{
    struct Expected { const char *name; int fieldHeight; int comboHeight; int pixels; qreal tracking; };
    const Expected sizes[] = {
        {"XS", 40, 32, 12, 0.4}, {"S", 48, 40, 14, 0.25}, {"M", 56, 48, 16, 0.5},
        {"L", 64, 56, 16, 0.5}, {"XL", 72, 72, 16, 0.5}
    };
    for (const auto &size : sizes) {
        for (const bool field : {true, false}) {
            auto *item = control(window, QString::fromLatin1(field ? "comparison.field.size." : "comparison.combo.size.") + QLatin1String(size.name));
            if (!item)
                continue;
            const auto font = item->property("font").value<QFont>();
            expect(qAbs(item->height() - (field ? size.fieldHeight : size.comboHeight)) <= 0.5
                       && font.pixelSize() == size.pixels && qAbs(font.letterSpacing() - size.tracking) < 0.01,
                   qPrintable(QStringLiteral("%1 %2 matches QCM height and typography").arg(field ? "TextField" : "ComboBox").arg(size.name)));
        }
    }
    for (const char *name : {"comparison.field.size.XS", "comparison.combo.size.XS"}) {
        auto *item = control(window, QString::fromLatin1(name));
        if (!item)
            continue;
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
    const auto callerDescription = QStringLiteral("Application-managed email description");
    const bool assigned = QQmlProperty::write(email, QStringLiteral("Accessible.description"), callerDescription,
                                              QQmlEngine::contextForObject(email));
    email->setProperty("serverError", true);
    expect(assigned && accessible && accessible->text(QAccessible::Description) == callerDescription,
           "an explicit caller description survives supporting/error updates");
    email->setProperty("serverError", false);
    email->setProperty("showSupportingText", false);
}

void checkNavigation(QQuickWindow &window)
{
    auto *bar = control(window, "comparison.navigation.bar");
    auto *pets = control(window, "comparison.navigation.pets");
    auto *tabs = control(window, "comparison.tabs.bar");
    auto *photos = control(window, "comparison.tabs.photos");
    if (!bar || !pets || !tabs || !photos)
        return;
    reveal(pets);
    pets->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(bar->property("currentIndex").toInt() == 1 && pets->property("checked").toBool()
               && bar->property("currentItem").value<QObject *>() == pets,
           "navigation items retain native exclusive TabBar selection");
    reveal(photos);
    photos->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(tabs->property("currentIndex").toInt() == 1 && photos->property("checked").toBool(),
           "Space selects a primary tab through its native currentIndex API");
}

void checkSliders(QQuickWindow &window)
{
    auto *volume = control(window, "comparison.slider.volume");
    auto *readOnly = control(window, "comparison.slider.readOnly");
    auto *range = control(window, "comparison.range.continuous");
    if (!volume || !readOnly || !range)
        return;
    reveal(volume);
    const auto paintedTrack = volume->grabToImage();
    const bool trackReady = paintedTrack && QTest::qWaitFor([&] { return !paintedTrack->image().isNull(); });
    const auto trackImage = trackReady ? paintedTrack->image() : QImage();
    expect(trackReady && qAlpha(trackImage.pixel(trackImage.width() / 4, trackImage.height() / 2)) > 0
               && qAlpha(trackImage.pixel(trackImage.width() * 3 / 4, trackImage.height() / 2)) > 0,
           "the M3 Slider renders both track segments around its native handle");
    volume->forceActiveFocus(Qt::TabFocusReason);
    const auto original = volume->property("value").toReal();
    QTest::keyClick(&window, Qt::Key_Right);
    expect(qAbs(volume->property("value").toReal() - original - 1) < 0.01,
           "the M3 Slider keeps native step-size keyboard behavior");
    readOnly->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    const auto locked = volume->property("value").toReal();
    volume->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Right);
    const auto point = volume->mapToScene(QPointF(volume->width() / 4, volume->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
    expect(readOnly->property("checked").toBool() && volume->property("enabled").toBool()
               && qAbs(volume->property("value").toReal() - locked) < 0.01,
           "read-only Slider blocks pointer and keyboard input without disabling the control");
    volume->setProperty("value", 54.0);
    expect(qAbs(volume->property("value").toReal() - 54) < 0.01,
           "a read-only Slider still accepts application value updates");
    readOnly->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    auto *first = range->property("first").value<QObject *>();
    auto *second = range->property("second").value<QObject *>();
    auto *handle = first ? first->property("handle").value<QQuickItem *>() : nullptr;
    if (first && second && handle) {
        reveal(handle);
        handle->forceActiveFocus(Qt::TabFocusReason);
        const auto before = first->property("value").toReal();
        QTest::keyClick(&window, Qt::Key_Right);
        expect(first->property("value").toReal() > before
                   && first->property("value").toReal() <= second->property("value").toReal(),
               "RangeSlider handles retain native keyboard stepping and ordered values");
    } else {
        expect(false, "RangeSlider exposes both native value nodes and its first handle");
    }
}

void checkSliderDestruction(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QQmlComponent component(&engine);
    component.setData(R"(
        import QtQuick
        import Qt.labs.StyleKit as SK
        import Qavsi.Material3.Style
        SK.Slider {
            width: 200; height: 48
            property bool lockInput: false
            SliderSupport.readOnly: lockInput
        }
    )", QUrl());
    const QPointer<QQuickItem> slider(qobject_cast<QQuickItem *>(component.create()));
    expect(slider, "the read-only cancellation consumer creates a native Slider");
    if (!slider)
        return;
    slider->setParent(window.contentItem());
    slider->setParentItem(window.contentItem());
    slider->setPosition(QPointF(16, window.height() - slider->height() - 16));
    const auto point = slider->mapToScene(QPointF(slider->width() / 2, slider->height() / 2));
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
    const bool pressed = slider->property("pressed").toBool();
    const auto signal = slider->metaObject()->property(slider->metaObject()->indexOfProperty("pressed")).notifySignal();
    const auto connection = QMetaObject::connect(slider, signal, &window, [slider] {
        if (slider && !slider->property("pressed").toBool())
            delete slider.data();
    }, Qt::DirectConnection);
    slider->setProperty("lockInput", true);
    expect(pressed && slider.isNull(), "read-only cancellation safely allows a native press callback to destroy its Slider");
    QObject::disconnect(connection);
    delete slider.data();
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
}

void checkListCards(QQuickWindow &window)
{
    auto *row = control(window, "comparison.list.selectable");
    auto *disabled = control(window, "comparison.list.disabled");
    auto *card = control(window, "comparison.card.interactive");
    auto *surface = control(window, "comparison.card.passive");
    if (!row || !disabled || !card || !surface)
        return;
    reveal(row);
    const bool originalChecked = row->property("checked").toBool();
    QSignalSpy selected(row, SIGNAL(clicked()));
    row->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(selected.size() == 1 && row->property("checked").toBool() != originalChecked,
           "ListItem selection is native and keyboard accessible");
    const bool disabledChecked = disabled->property("checked").toBool();
    reveal(disabled);
    const auto point = disabled->mapToScene(QPointF(disabled->width() / 2, disabled->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
    expect(disabled->property("checked").toBool() == disabledChecked,
           "disabled ListItem rejects native pointer selection");
    reveal(card);
    QSignalSpy activated(card, SIGNAL(clicked()));
    card->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(activated.size() == 1, "interactive Card keeps native keyboard activation");
    expect(surface->width() > 0 && surface->height() >= 64 && !surface->activeFocusOnTab(),
           "passive Card remains a usable noninteractive native surface");
    reveal(surface);
    const auto capture = surface->grabToImage();
    const bool captured = capture && QTest::qWaitFor([&] { return !capture->image().isNull(); });
    auto *style = window.property("materialStyle").value<QObject *>();
    auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
    const auto expectedFill = tokens ? tokens->property("surfaceContainerHighest").value<QColor>() : QColor();
    const auto image = captured ? capture->image() : QImage();
    expect(captured && expectedFill.isValid()
               && image.pixelColor(image.width() / 2, image.height() - 4) == expectedFill,
           "filled passive Card paints the active Theme surface role");
    card->setFocus(false, Qt::OtherFocusReason);
    QTest::mouseMove(&window, QPoint(0, 0));
    const auto cardCapture = card->grabToImage();
    const bool cardCaptured = cardCapture && QTest::qWaitFor([&] { return !cardCapture->image().isNull(); });
    const auto cardImage = cardCaptured ? cardCapture->image() : QImage();
    expect(cardCaptured && tokens
               && cardImage.pixelColor(cardImage.width() / 2, cardImage.height() - 4)
                   == tokens->property("surfaceContainerLow").value<QColor>(),
           "interactive elevated Card paints its Theme surface instead of the normal button fill");
    row->setProperty("checked", originalChecked);
    QTest::mouseMove(&window, QPoint(0, 0));
}

void checkChips(QQuickWindow &window)
{
    auto *assist = control(window, "comparison.chip.assist");
    auto *filter = control(window, "comparison.chip.filter");
    auto *input = control(window, "comparison.chip.input");
    auto *suggestion = control(window, "comparison.chip.suggestion");
    auto *disabled = control(window, "comparison.chip.disabled");
    auto *disabledInput = control(window, "comparison.chip.input.disabled");
    auto *longChip = control(window, "comparison.chip.long");
    if (!assist || !filter || !input || !suggestion || !disabled || !disabledInput || !longChip)
        return;
    reveal(assist);
    QSignalSpy commanded(assist, SIGNAL(clicked()));
    assist->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(commanded.size() == 1 && qAbs(assist->height() - 32) < 0.5,
           "Assist chip keeps native activation and QCM's 32-pixel geometry");
    filter->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(filter->property("checked").toBool() && disabled->property("checked").toBool(),
           "Filter selection uses native checked and its disabled example reflects the same selection");
    input->forceActiveFocus(Qt::TabFocusReason);
    QSignalSpy bodyClicked(input, SIGNAL(clicked()));
    QTest::keyClick(&window, Qt::Key_Space);
    auto *removeAction = window.findChild<QObject *>("comparison.chip.input.action");
    expect(removeAction && input->property("checked").toBool() && disabledInput->property("checked").toBool()
               && bodyClicked.size() == 1,
           "Input selects through its native body and its disabled example reflects the same selection");
    if (removeAction) {
        QSignalSpy removed(removeAction, SIGNAL(triggered(QObject*)));
        QTest::keyClick(&window, Qt::Key_Tab);
        auto *trailing = window.activeFocusItem();
        const bool nativeAction = trailing && trailing->property("action").value<QObject *>() == removeAction;
        expect(nativeAction, "Tab reaches the separate native trailing Action button");
        if (nativeAction)
            QTest::keyClick(&window, Qt::Key_Space);
        expect(removed.size() == 1 && bodyClicked.size() == 1 && !input->property("checked").toBool()
                   && !disabledInput->property("checked").toBool(),
               "the trailing Action runs once without activating the Input chip body");
    }
    QSignalSpy disabledClicked(disabled, SIGNAL(clicked()));
    const auto checkedBefore = disabled->property("checked").toBool();
    const auto point = disabled->mapToScene(QPointF(disabled->width() / 2, disabled->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
    expect(disabledClicked.isEmpty() && disabled->property("checked").toBool() == checkedBefore,
           "disabled chips retain native input gating");
    expect(qAbs(longChip->width() - 180) < 0.5
               && longChip->property("text").toString() == QStringLiteral("A long chip label constrained by its parent"),
           "a constrained chip preserves the source label for native accessibility");
}

void checkProgress(QQuickWindow &window)
{
    const bool previousReducedMotion = window.property("reducedMotion").toBool();
    auto *linear = control(window, "comparison.progress.linear");
    auto *unknown = control(window, "comparison.progress.indeterminate");
    auto *circular = control(window, "comparison.progress.circular");
    auto *busy = control(window, "comparison.progress.busy");
    if (!linear || !unknown || !circular || !busy)
        return;
    reveal(linear);
    expect(qAbs(linear->height() - 4) < 0.5 && qAbs(circular->width() - 40) < 0.5
               && qAbs(circular->height() - 40) < 0.5 && qAbs(busy->width() - 40) < 0.5,
           "native progress controls use QCM linear and circular geometry");
    const auto capture = [](QQuickItem *item) -> QImage {
        const auto grab = item->grabToImage();
        return grab && QTest::qWaitFor([&] { return !grab->image().isNull(); }) ? grab->image() : QImage();
    };
    const auto first = capture(linear);
    linear->setProperty("completed", 70);
    expect(qAbs(linear->property("position").toReal() - 0.7) < 0.001 && first != capture(linear),
           "application progress binding updates native position and rendered fill");
    linear->setProperty("total", 200);
    expect(qAbs(linear->property("position").toReal() - 0.35) < 0.001,
           "application range bindings remain live after style installation");
    linear->setProperty("unknown", true);
    const auto indeterminate = capture(linear);
    QTest::qWait(100);
    expect(linear->property("indeterminate").toBool() && !indeterminate.isNull()
               && indeterminate == capture(linear),
           "reduced-motion indeterminate progress keeps visible static feedback");
    linear->setProperty("unknown", false);
    expect(!linear->property("indeterminate").toBool()
               && qAbs(linear->property("value").toReal() - 70) < 0.001,
           "switching progress modes retains the caller's value binding");
    reveal(busy);
    const auto spinning = capture(busy);
    bool painted = false;
    for (int y = 0; y < spinning.height() && !painted; ++y)
        for (int x = 0; x < spinning.width() && !painted; ++x)
            painted = qAlpha(spinning.pixel(x, y)) > 0;
    busy->setProperty("working", false);
    const auto stopped = capture(busy);
    expect(painted && !busy->property("running").toBool() && spinning != stopped,
           "native BusyIndicator renders static reduced-motion feedback and honors running");
    busy->setProperty("working", true);
    auto *accessible = QAccessible::queryAccessibleInterface(linear);
    expect(accessible && accessible->role() == QAccessible::ProgressBar
               && accessible->text(QAccessible::Name) == QStringLiteral("Download progress")
               && accessible->valueInterface() && accessible->valueInterface()->currentValue().toReal() == 70,
           "native progress retains its accessible name, role and numeric value");
    window.setProperty("reducedMotion", false);
    const auto animated = capture(busy);
    QTest::qWait(180);
    expect(animated != capture(busy), "native BusyIndicator animates when full motion is enabled");
    window.setProperty("reducedMotion", previousReducedMotion);
}

void checkBadges(QQuickWindow &window)
{
    auto *badge = control(window, "comparison.badge.count");
    if (!badge)
        return;
    reveal(badge);
    const auto capsuleCoversLabel = [&](QQuickItem *label) {
        window.grabWindow();
        const auto grab = label->grabToImage();
        if (!grab || !QTest::qWaitFor([&] { return !grab->image().isNull(); }))
            return false;
        const QImage image = grab->image();
        const int inset = qMax(2, qRound(2 * image.width() / label->width()));
        return image.pixelColor(image.width() - inset, image.height() / 2)
            == QColor(window.property("darkMode").toBool() ? QStringLiteral("#ffb4ab") : QStringLiteral("#ba1a1a"));
    };
    expect(badge->property("text").toString() == QStringLiteral("8"),
           "the native badge label displays its live count");
    expect(badge->height() == 16, "the badge uses QCM's 16px label recipe");
    badge->setProperty("count", 120);
    expect(badge->property("text").toString() == QStringLiteral("99+"),
           "the badge caps the visual count");
    auto *accessible = QAccessible::queryAccessibleInterface(badge);
    expect(accessible && accessible->text(QAccessible::Name) == QStringLiteral("120"),
           "the capped badge keeps its full count accessible");
    expect(capsuleCoversLabel(badge), "the badge surface covers the right edge of a capped count");
    badge->setProperty("count", 0);
    expect(!badge->isVisible(), "zero counts are hidden by default");
    badge->setProperty("showZero", true);
    expect(badge->isVisible() && badge->property("text").toString() == QStringLiteral("0"),
           "showZero displays a meaningful zero label");
    badge->setProperty("dot", true);
    badge->setProperty("showZero", false);
    expect(!badge->isVisible(), "a zero count never becomes a decorative dot");
    badge->setProperty("count", 8);
    badge->setProperty("dot", false);
    badge->setProperty("showZero", false);
    const bool originalDark = window.property("darkMode").toBool();
    window.setProperty("darkMode", true);
    expect(badge->property("color").value<QColor>() == QColor(QStringLiteral("#690005")),
           "the selected dark Theme supplies QCM's on_error label color");
    const auto capture = badge->grabToImage();
    expect(capture && QTest::qWaitFor([&] { return !capture->image().isNull(); })
               && capture->image().pixelColor(2, capture->image().height() / 2) == QColor(QStringLiteral("#ffb4ab")),
           "the native badge paints the dark error surface on software");
    window.setProperty("darkMode", originalDark);
    const bool named = QQmlProperty::write(badge, QStringLiteral("Accessible.name"), QStringLiteral("Unread messages"), QQmlEngine::contextForObject(badge));
    badge->setProperty("count", 9);
    expect(named && accessible && accessible->text(QAccessible::Name) == QStringLiteral("Unread messages"),
           "later caller accessible names retain ownership after count changes");
    badge->setProperty("count", 8);
    auto *dot = control(window, "comparison.badge.dot");
    expect(dot && dot->width() == 6 && dot->height() == 6,
           "a decorative dot uses QCM's 6px recipe");
    auto *text = control(window, "comparison.badge.text");
    if (text) {
        text->setProperty("count", 120);
        text->setProperty("callerText", QStringLiteral("new messages"));
        expect(text->property("text").toString() == QStringLiteral("new messages"),
               "live caller text keeps ownership over automatic count formatting");
        expect(capsuleCoversLabel(text), "the badge surface covers the right edge of a long text label");
        text->setProperty("count", -1);
        text->setProperty("callerText", QStringLiteral("alarm"));
    }
}

void checkCheckBoxes(QQuickWindow &window)
{
    auto *binary = control(window, "comparison.checkbox.unchecked");
    auto *tri = control(window, "comparison.checkbox.indeterminate");
    auto *disabled = control(window, "comparison.checkbox.disabled");
    if (!binary || !tri || !disabled)
        return;
    reveal(binary);
    auto *indicator = tri->property("indicator").value<QQuickItem *>();
    expect(indicator && qAbs(indicator->width() - 18) < 0.5 && qAbs(indicator->height() - 18) < 0.5,
           "CheckBox uses QCM's 18 by 18 native indicator geometry");
    binary->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(binary->property("checkState").toInt() == Qt::Checked,
           "Space toggles a binary native CheckBox");
    const auto capture = [&]() -> QImage {
        const auto grab = indicator ? indicator->grabToImage() : nullptr;
        return grab && QTest::qWaitFor([&] { return !grab->image().isNull(); }) ? grab->image() : QImage();
    };
    tri->forceActiveFocus(Qt::OtherFocusReason);
    const auto partial = capture();
    QTest::keyClick(&window, Qt::Key_Space);
    const bool checked = tri->property("checkState").toInt() == Qt::Checked;
    const auto checkedImage = capture();
    QTest::keyClick(&window, Qt::Key_Space);
    const bool unchecked = tri->property("checkState").toInt() == Qt::Unchecked;
    const auto uncheckedImage = capture();
    QTest::keyClick(&window, Qt::Key_Space);
    expect(checked && unchecked && tri->property("checkState").toInt() == Qt::PartiallyChecked,
           "native tristate keyboard activation cycles checked, unchecked and indeterminate");
    expect(!partial.isNull() && !checkedImage.isNull() && !uncheckedImage.isNull()
               && partial != checkedImage && partial != uncheckedImage && checkedImage != uncheckedImage,
           "CheckBox renders distinct empty, tick and indeterminate indicators");
    auto *accessible = QAccessible::queryAccessibleInterface(tri);
    expect(accessible && accessible->state().checkStateMixed,
           "the indeterminate native CheckBox exposes its mixed accessible state");
    reveal(disabled);
    const auto center = disabled->mapToScene(QPointF(disabled->width() / 2, disabled->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center.toPoint());
    expect(!disabled->property("enabled").toBool() && disabled->property("checkState").toInt() == Qt::Checked,
           "a disabled CheckBox rejects pointer activation");
    QTest::mouseMove(&window, QPoint(0, 0));
}

void checkRadioButtons(QQuickWindow &window)
{
    auto *first = control(window, "comparison.radio.option1");
    auto *second = control(window, "comparison.radio.option2");
    auto *third = control(window, "comparison.radio.option3");
    auto *readOnly = control(window, "comparison.radio.readOnly");
    if (!first || !second || !third || !readOnly)
        return;
    reveal(second);
    auto *indicator = second->property("indicator").value<QQuickItem *>();
    expect(indicator && qAbs(indicator->width() - 20) < 0.5 && qAbs(indicator->height() - 20) < 0.5,
           "RadioButton uses QCM's 20 by 20 native indicator geometry");
    const auto unselectedCapture = indicator ? indicator->grabToImage() : nullptr;
    const bool unselectedReady = unselectedCapture && QTest::qWaitFor([&] { return !unselectedCapture->image().isNull(); });
    const auto unselected = unselectedReady ? unselectedCapture->image() : QImage();
    second->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(second->property("checked").toBool() && !first->property("checked").toBool(),
           "Space selects one native RadioButton and clears its sibling");
    const auto selectedCapture = indicator ? indicator->grabToImage() : nullptr;
    const bool selectedReady = selectedCapture && QTest::qWaitFor([&] { return !selectedCapture->image().isNull(); });
    const auto selected = selectedReady ? selectedCapture->image() : QImage();
    expect(unselectedReady && selectedReady
               && qAlpha(unselected.pixel(unselected.width() / 2, unselected.height() / 2)) == 0
               && qAlpha(selected.pixel(selected.width() / 2, selected.height() / 2)) > 0,
           "the radio center paints a dot only for the selected native option");
    readOnly->setProperty("checked", true);
    first->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    const auto point = first->mapToScene(QPointF(first->width() / 2, first->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, point.toPoint());
    expect(second->property("checked").toBool() && !first->property("checked").toBool()
               && first->property("enabled").toBool(),
           "read-only RadioButtons reject keyboard and pointer selection without disabling them");
    auto *accessible = QAccessible::queryAccessibleInterface(first);
    auto *actions = accessible ? accessible->actionInterface() : nullptr;
    if (actions) {
        actions->doAction(QAccessibleActionInterface::toggleAction());
        expect(second->property("checked").toBool() && !first->property("checked").toBool(),
               "read-only RadioButtons reject native accessibility activation");
    } else {
        expect(false, "RadioButton exposes native accessibility actions");
    }
    third->setProperty("checked", true);
    expect(third->property("checked").toBool() && !second->property("checked").toBool(),
           "a read-only radio group still accepts application selection updates");
    readOnly->setProperty("checked", false);
    first->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyPress(&window, Qt::Key_Space);
    readOnly->setProperty("checked", true);
    QTest::keyRelease(&window, Qt::Key_Space);
    expect(third->property("checked").toBool() && !first->property("checked").toBool()
               && !first->property("pressed").toBool(),
           "entering read-only during a key press cancels pending radio activation");
    readOnly->setProperty("checked", false);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(first->property("checked").toBool() && !third->property("checked").toBool(),
           "unlocking read-only restores native radio selection");
    if (actions) {
        third->setProperty("checked", true);
        actions->doAction(QAccessibleActionInterface::pressAction());
        expect(first->property("checked").toBool() && !third->property("checked").toBool()
                   && !accessible->state().readOnly,
               "unlocking read-only restores accessible native radio activation and state");
    }
}

void checkSwitch(QQuickWindow &window)
{
    auto *toggle = control(window, "comparison.switch.unchecked");
    auto *disabled = control(window, "comparison.switch.disabled");
    if (!toggle || !disabled)
        return;
    reveal(toggle);
    auto *indicator = toggle->property("indicator").value<QQuickItem *>();
    expect(indicator && qAbs(indicator->width() - 52) < 0.5 && qAbs(indicator->height() - 32) < 0.5,
           qPrintable(QStringLiteral("Switch uses QCM's 52 by 32 native indicator geometry (actual %1 by %2)")
               .arg(indicator ? indicator->width() : 0).arg(indicator ? indicator->height() : 0)));
    QSignalSpy toggled(toggle, SIGNAL(toggled()));
    toggle->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(toggle->property("checked").toBool() && toggled.size() == 1,
           "Space toggles a styled Switch through its native checked API");
    const auto center = disabled->mapToScene(QPointF(disabled->width() / 2, disabled->height() / 2));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center.toPoint());
    expect(!disabled->property("enabled").toBool() && !disabled->property("checked").toBool(),
           "a disabled Switch rejects pointer activation");
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

void checkTextButtonPointerFocus(QQuickWindow &window)
{
    auto *style = window.property("materialStyle").value<QObject *>();
    auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
    const int hoverAlpha = tokens ? qRound(tokens->property("hoverOpacity").toReal() * 255) : 0;
    for (const auto &name : {QStringLiteral("comparison.menu.open"), QStringLiteral("comparison.menu.action.open")}) {
        auto *button = control(window, name);
        if (!button)
            continue;
        reveal(button);
        button->forceActiveFocus(Qt::MouseFocusReason);
        const auto center = button->mapToScene(QPointF(button->width() / 2, button->height() / 2));
        QTest::mouseMove(&window, QPoint(1, 1));
        QTest::mouseMove(&window, center.toPoint());
        const bool hoverObserved = QGuiApplication::platformName() == QStringLiteral("offscreen")
            || QTest::qWaitFor([&] { return button->property("hovered").toBool(); });
        const auto image = button->grabToImage();
        const bool ready = image && QTest::qWaitFor([&] { return !image->image().isNull(); });
        const auto painted = ready ? image->image() : QImage();
        expect(ready && hoverObserved && !button->property("visualFocus").toBool()
                   && painted.pixelColor(0, 0).alpha() == 0
                   && painted.pixelColor(0, painted.height() / 2).alpha() <= hoverAlpha + 1,
               qPrintable(name + " keeps rounded borderless feedback on hover and pointer focus"));
    }
}

void checkActionMenu(QQuickWindow &window)
{
    auto *trigger = control(window, "comparison.menu.action.open");
    if (!trigger)
        return;
    const auto originalDark = window.property("darkMode");
    window.setProperty("darkMode", true);
    reveal(trigger);
    trigger->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    auto *menu = window.findChild<QObject *>("comparison.menu.actions");
    expect(menu && menu->property("opened").toBool(), "the native Action menu opens");
    if (!menu)
        return;
    QQuickItem *first = nullptr;
    QMetaObject::invokeMethod(menu, "itemAt", Q_RETURN_ARG(QQuickItem *, first), Q_ARG(int, 0));
    auto *action = first ? first->property("action").value<QObject *>() : nullptr;
    expect(menu->property("count").toInt() == 3 && action
               && action == window.findChild<QObject *>("comparison.menu.action.first"),
           "QCM's three commands use shared native MenuItem.action objects");
    if (!action) {
        QMetaObject::invokeMethod(menu, "close");
        return;
    }
    auto *style = window.property("materialStyle").value<QObject *>();
    auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
    const auto foreground = tokens ? tokens->property("surfaceForeground").value<QColor>() : QColor();
    const auto rendered = first->grabToImage();
    const bool ready = rendered && QTest::qWaitFor([&] { return !rendered->image().isNull(); });
    bool textPainted = false;
    if (ready && foreground.isValid()) {
        const auto image = rendered->image();
        const auto dpr = image.devicePixelRatio();
        const auto start = qRound((first->property("leftPadding").toReal()
            + QQmlProperty::read(first, QStringLiteral("icon.width"), QQmlEngine::contextForObject(first)).toReal()
            + first->property("spacing").toReal()) * dpr);
        for (int y = 0; y < image.height() && !textPainted; ++y)
            for (int x = start; x < image.width() && !textPainted; ++x) {
                const auto pixel = image.pixelColor(x, y);
                textPainted = pixel.alpha() > 240 && qAbs(pixel.red() - foreground.red()) < 3
                    && qAbs(pixel.green() - foreground.green()) < 3 && qAbs(pixel.blue() - foreground.blue()) < 3;
            }
    }
    expect(textPainted && QQmlProperty::read(first, QStringLiteral("icon.color"), QQmlEngine::contextForObject(first)).value<QColor>() == foreground,
           "dark Action-menu text and native icon color follow Theme.surfaceForeground");
    const auto originalText = action->property("text");
    action->setProperty("text", QStringLiteral("Renamed action"));
    action->setProperty("enabled", false);
    action->setProperty("checkable", true);
    action->setProperty("checked", true);
    expect(first->property("text").toString() == QStringLiteral("Renamed action")
               && !first->property("enabled").toBool() && first->property("checkable").toBool()
               && first->property("checked").toBool()
               && QQmlProperty::read(first, QStringLiteral("icon.name"), QQmlEngine::contextForObject(first)).toString() == QStringLiteral("material:add"),
           "native Action text/icon/enabled/checkable/checked stay connected to the menu item");
    action->setProperty("enabled", true);
    action->setProperty("checked", false);
    action->setProperty("text", originalText);
    QSignalSpy triggered(action, SIGNAL(triggered(QObject*)));
    QSignalSpy selected(first, SIGNAL(triggered()));
    QTest::keyClick(&window, Qt::Key_Down);
    QTest::keyClick(&window, Qt::Key_Return);
    expect(triggered.size() == 1 && selected.size() == 1 && action->property("checked").toBool()
               && !menu->property("visible").toBool(),
           "menu selection triggers the shared Action once and closes the native menu");
    action->setProperty("checked", false);
    action->setProperty("checkable", false);
    const auto customInk = tokens->property("primary").value<QColor>();
    const bool assigned = QQmlProperty::write(first, QStringLiteral("icon.color"), customInk, QQmlEngine::contextForObject(first));
    action->setProperty("enabled", false);
    expect(assigned && QQmlProperty::read(first, QStringLiteral("icon.color"), QQmlEngine::contextForObject(first)).value<QColor>() == customInk,
           "an explicit caller icon-color override keeps ownership after Action updates");
    action->setProperty("enabled", true);
    window.setProperty("darkMode", originalDark);
}

void checkAppNavigation(QQuickWindow &window)
{
    auto *shell = control(window, "comparison.appNavigation.shell");
    if (!shell)
        return;
    reveal(shell);
    const auto originalWidth = shell->width();
    const auto originalWindowSize = window.size();
    const auto originalTheme = window.property("darkMode");
    const auto originalMotion = window.property("reducedMotion");
    shell->setProperty("width", 1300);
    auto *gallery = control(window, "comparison.appNavigation");
    const auto originalSelection = gallery->property("selection");
    const auto originalSearchText = shell->property("searchText");
    gallery->setProperty("selection", 1);
    QCoreApplication::processEvents();
    expect(shell->property("navigationMode").toString() == QStringLiteral("expanded"),
           "wide application navigation presents an expanded rail");
    shell->setProperty("width", 800);
    QCoreApplication::processEvents();
    expect(shell->property("navigationMode").toString() == QStringLiteral("collapsed")
               && shell->property("currentIndex").toInt() == 1,
           "narrow rail keeps the consumer selection across responsive modes");
    shell->setProperty("width", 440);
    QCoreApplication::processEvents();
    auto *field = shell->property("searchField").value<QQuickItem *>();
    auto *drawer = shell->property("navigationDrawer").value<QObject *>();
    expect(field && drawer && shell->property("currentIndex").toInt() == 1,
           "compact application navigation preserves selection and native public controls");
    if (field && drawer) {
        auto *navigationTokens = shell->property("tokens").value<QObject *>();
        expect(navigationTokens && field->property("placeholderTextColor").value<QColor>()
                   == navigationTokens->property("surfaceVariantForeground").value<QColor>(),
               "native search placeholder uses readable Theme ink");
        field->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_B);
        expect(shell->property("searchText").toString() == QStringLiteral("b"),
               "native search editing updates the consumer search text live");
        QMetaObject::invokeMethod(shell, "openNavigation");
        expect(drawer->property("visible").toBool(), "compact navigation opens its native modal drawer");
        QTest::keyClick(&window, Qt::Key_Tab);
        auto *destination = window.activeFocusItem();
        expect(destination && destination->property("text").toString() == QStringLiteral("Explore"),
               "native Tab navigation focuses the first drawer destination");
        if (destination) {
            const auto unselectedGrab = destination->grabToImage();
            const bool unselectedReady = unselectedGrab && QTest::qWaitFor([&] { return !unselectedGrab->image().isNull(); });
            gallery->setProperty("selection", 0);
            const auto selectedGrab = destination->grabToImage();
            const bool selectedReady = selectedGrab && QTest::qWaitFor([&] { return !selectedGrab->image().isNull(); });
            const auto unselectedImage = unselectedReady ? unselectedGrab->image() : QImage();
            const auto selectedImage = selectedReady ? selectedGrab->image() : QImage();
            const auto selectedFill = selectedReady ? selectedImage.pixelColor(selectedImage.width() - 30, selectedImage.height() / 2) : QColor();
            const auto expectedFill = navigationTokens->property("secondaryContainer").value<QColor>();
            expect(unselectedReady && selectedReady
                       && unselectedImage.pixelColor(unselectedImage.width() - 30, unselectedImage.height() / 2).alpha() < 100
                       && selectedFill.alpha() > 240
                       && qAbs(selectedFill.red() - expectedFill.red()) < 30
                       && qAbs(selectedFill.green() - expectedFill.green()) < 30
                       && qAbs(selectedFill.blue() - expectedFill.blue()) < 30,
                   "newly opened native drawer paints its initial unselected row transparently and selection tonally");
            gallery->setProperty("selection", 1);
        }
        window.setProperty("darkMode", !originalTheme.toBool());
        QCoreApplication::processEvents();
        expect(drawer->property("visible").toBool() && shell->property("currentIndex").toInt() == 1,
               "an open native drawer survives a live Theme change without losing selection");
        auto *changedTokens = shell->property("tokens").value<QObject *>();
        expect(changedTokens && field->property("placeholderTextColor").value<QColor>()
                   == changedTokens->property("surfaceVariantForeground").value<QColor>(),
               "native search placeholder follows readable ink during a live Theme change");
        window.setProperty("darkMode", originalTheme);
        QCoreApplication::processEvents();
        const auto originalPlaceholder = field->property("placeholderTextColor");
        const auto customPlaceholder = QColor("#13579b");
        field->setProperty("placeholderTextColor", customPlaceholder);
        field->setProperty("enabled", false);
        QCoreApplication::processEvents();
        expect(field->property("placeholderTextColor").value<QColor>() == customPlaceholder,
               "explicit search placeholder ink stays caller-owned after state changes");
        field->setProperty("enabled", true);
        field->setProperty("placeholderTextColor", originalPlaceholder);

        // The activation scenario starts after independent Theme/enabled ownership checks.
        if (destination)
            destination->forceActiveFocus(Qt::TabFocusReason);
        const bool destinationFocused = destination && QTest::qWaitFor([&] { return destination->hasActiveFocus(); });
        QSignalSpy activated(shell, SIGNAL(activated(int)));
        QTest::keyClick(&window, Qt::Key_Space);
        expect(destinationFocused && activated.size() == 1 && gallery->property("selection").toInt() == 0
                   && shell->property("currentIndex").toInt() == 0
                   && destination->property("checked").toBool() && !destination->property("checkable").toBool(),
               "native destination checked styling follows the live caller selection without native toggles");
        gallery->setProperty("selection", 1);
        QMetaObject::invokeMethod(shell, "openNavigation");
        QTest::keyClick(&window, Qt::Key_Tab);
        destination = window.activeFocusItem();
        const auto focusedText = destination ? destination->property("text").toString() : QString();
        shell->setProperty("width", 800);
        expect(QTest::qWaitFor([&] { return window.activeFocusItem()
                   && window.activeFocusItem()->property("text").toString() == focusedText; }),
               "rail focus follows the same destination when the responsive presentation changes");
        field->forceActiveFocus(Qt::TabFocusReason);
        shell->setProperty("width", 1300);
        QCoreApplication::processEvents();
        expect(window.activeFocusItem() == field,
               "responsive navigation never steals focus from native search");
        shell->setProperty("width", 440);
        QMetaObject::invokeMethod(shell, "openNavigation");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(!drawer->property("visible").toBool() && shell->property("currentIndex").toInt() == 1,
               "Escape dismisses navigation without changing the consumer selection");
        auto *sheet = shell->property("sideSheet").value<QObject *>();
        QMetaObject::invokeMethod(shell, "openSideSheet");
        expect(sheet && sheet->property("visible").toBool() && !sheet->property("modal").toBool()
                   && !sheet->property("dim").toBool(),
               "details opens a native nonmodal side sheet without dimming the page");
        if (sheet) {
            field->forceActiveFocus(Qt::TabFocusReason);
            QTest::keyClick(&window, Qt::Key_C);
            expect(shell->property("searchText").toString() == QStringLiteral("bc"),
                   "native search remains editable beside the nonmodal side sheet");
            QMetaObject::invokeMethod(sheet, "forceActiveFocus");
            QTest::keyClick(&window, Qt::Key_Escape);
            expect(!sheet->property("visible").toBool(), "Escape dismisses the focused nonmodal side sheet");
        }
    }
    gallery->setProperty("selection", originalSelection);
    shell->setProperty("searchText", originalSearchText);
    shell->setProperty("width", originalWidth);
    window.resize(originalWindowSize);
    window.setProperty("darkMode", originalTheme);
    window.setProperty("reducedMotion", originalMotion);
    QTest::mouseMove(&window, QPoint(0, 0));
}

void checkDialogFeedback(QQuickWindow &window)
{
    auto *trigger = control(window, "comparison.dialog.open");
    auto *dialog = window.findChild<QObject *>("comparison.dialog");
    expect(dialog, "the consumer exposes a native dialog");
    if (!trigger || !dialog)
        return;
    const auto originalDark = window.property("darkMode");
    reveal(trigger);
    trigger->forceActiveFocus(Qt::TabFocusReason);
    QSignalSpy accepted(dialog, SIGNAL(accepted()));
    QSignalSpy rejected(dialog, SIGNAL(rejected()));
    QTest::keyClick(&window, Qt::Key_Space);
    expect(dialog->property("opened").toBool(), "native dialog opens immediately with reduced motion");
    auto *style = window.property("materialStyle").value<QObject *>();
    for (bool dark : {false, true}) {
        window.setProperty("darkMode", dark);
        window.grabWindow();
        auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
        auto *background = dialog->property("background").value<QQuickItem *>();
        const auto capture = background ? background->grabToImage() : nullptr;
        const bool ready = capture && QTest::qWaitFor([&] { return !capture->image().isNull(); });
        const auto image = ready ? capture->image() : QImage();
        expect(ready && tokens && image.pixelColor(image.width() / 2, image.height() / 2)
                   == tokens->property("surfaceContainerHigh").value<QColor>(),
               "native dialog paints an opaque Theme surface in light and dark themes");
    }
    QTest::keyClick(&window, Qt::Key_Escape);
    expect(!dialog->property("visible").toBool() && rejected.size() == 1 && trigger->hasActiveFocus(),
           "Escape rejects the native dialog once and restores trigger focus");
    QTest::keyClick(&window, Qt::Key_Space);
    QMetaObject::invokeMethod(dialog, "accept");
    expect(accepted.size() == 1 && !dialog->property("visible").toBool(),
           "native dialog acceptance closes once");
    window.setProperty("darkMode", originalDark);
    auto *tipTrigger = control(window, "comparison.tooltip.open");
    auto *tip = window.findChild<QObject *>("comparison.tooltip");
    expect(tipTrigger && tip, "rich tooltip exposes a native popup consumer");
    if (tipTrigger && tip) {
        reveal(tipTrigger);
        tipTrigger->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(tip->property("opened").toBool() && tip->property("activeFocus").toBool(),
               "rich tooltip opens with keyboard focus for its action");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(!tip->property("visible").toBool() && tipTrigger->hasActiveFocus(),
               "Escape closes rich tooltip and restores anchor focus");
    }
    auto *snackbar = window.findChild<QObject *>("comparison.snackbar");
    auto *action = window.findChild<QObject *>("comparison.snackbar.action");
    auto *actionButton = snackbar ? snackbar->property("actionControl").value<QQuickItem *>() : nullptr;
    expect(snackbar && action && actionButton, "feedback exposes native popup and Action");
    if (snackbar && action && actionButton) {
        QSignalSpy triggered(action, SIGNAL(triggered(QObject*)));
        snackbar->setProperty("timeout", 0);
        QMetaObject::invokeMethod(snackbar, "open");
        window.grabWindow();
        actionButton->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(triggered.size() == 1 && !snackbar->property("visible").toBool(),
               "snackbar keyboard action triggers once and closes");
        snackbar->setProperty("timeout", 30);
        QMetaObject::invokeMethod(snackbar, "open");
        expect(QTest::qWaitFor([&] { return !snackbar->property("visible").toBool(); }, 1000),
               "visible snackbar closes after its timeout");
        snackbar->setProperty("timeout", 0);
        QMetaObject::invokeMethod(snackbar, "open");
        QTest::qWait(50);
        expect(snackbar->property("visible").toBool(), "zero timeout keeps snackbar visible");
        QMetaObject::invokeMethod(snackbar, "close");
        snackbar->setProperty("timeout", 5000);
    }
    QTest::mouseMove(&window, QPoint(0, 0));
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
    expect(QTest::qWaitForWindowActive(&window), "the comparison consumer gains native keyboard focus");
    window.setProperty("reducedMotion", true);
    checkAppNavigation(window);
    checkDialogFeedback(window);
    checkComboBox(window);
    checkTextField(window);
    checkFieldAccessories(window);
    checkInputSizes(window);
    checkListCards(window);
    checkChips(window);
    checkBadges(window);
    checkCheckBoxes(window);
    checkProgress(window);
    checkRadioButtons(window);
    checkSwitch(window);
    checkNavigation(window);
    checkSliders(window);
    checkSliderDestruction(engine, window);
    checkSelection(window);
    checkFab(window);
    checkTextButtonPointerFocus(window);
    checkActionMenu(window);
    checkMenu(window);
    expect(checkPickersCarousel(window) == 0, "picker and carousel public behavior");
    expect(!window.grabWindow().isNull(), "the comparison consumer renders with its imported kit and icons");
    expect(warnings.isEmpty(), "gallery interactions produce no QML warnings");
    qInfo() << "Qt" << qVersion() << "comparison assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
