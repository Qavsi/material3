#include <QAccessible>
#include <QColor>
#include <QDateTime>
#include <QMetaObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>

#include <memory>

int checkPickersCarousel(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&failures](bool condition, const char *message) {
        if (!condition) { ++failures; qCritical() << "FAIL:" << message; }
    };
    auto *gallery = window.findChild<QObject *>(QStringLiteral("comparison.pickers.gallery"));
    expect(gallery, "picker gallery exists");
    if (!gallery) return failures;
    auto *date = window.findChild<QObject *>(QStringLiteral("comparison.pickers.date"));
    expect(date, "date picker is available through the public consumer");
    if (!date) return failures;
    const auto value = [](int day) { return QDateTime(QDate(2026, 2, day), QTime(0, 0)); };
    const auto originalDate = gallery->property("selectedDate");
    const auto originalMinimum = date->property("minimumDate");
    const auto originalMaximum = date->property("maximumDate");
    gallery->setProperty("selectedDate", value(15));
    date->setProperty("minimumDate", value(10));
    date->setProperty("maximumDate", value(20));
    QSignalSpy acceptedDate(date, SIGNAL(acceptedDate(QDateTime)));
    QMetaObject::invokeMethod(date, "open");
    QMetaObject::invokeMethod(date, "selectDate", Q_ARG(QDateTime, value(9)));
    expect(date->property("currentDate").toDateTime().date() == QDate(2026, 2, 15),
           "date selection rejects a date below the public minimum");
    QMetaObject::invokeMethod(date, "selectDate", Q_ARG(QDateTime, value(18)));
    QMetaObject::invokeMethod(date, "reject");
    expect(date->property("selectedDate").toDateTime().date() == QDate(2026, 2, 15) && acceptedDate.isEmpty(),
           "date cancellation preserves the caller's selected date");
    QMetaObject::invokeMethod(date, "open");
    expect(date->property("currentDate").toDateTime().date() == QDate(2026, 2, 15),
           "reopening restores the committed date");
    QMetaObject::invokeMethod(date, "selectDate", Q_ARG(QDateTime, value(18)));
    QMetaObject::invokeMethod(date, "accept");
    expect(date->property("selectedDate").toDateTime().date() == QDate(2026, 2, 18) && acceptedDate.size() == 1,
           "date acceptance emits one valid date and keeps the caller binding live");
    auto *inlineTime = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.time.inline"));
    expect(inlineTime, "a time picker can be embedded without opening a dialog");
    if (inlineTime) {
        QSignalSpy requested(inlineTime, SIGNAL(selectedTimeChangeRequested(int,int)));
        QMetaObject::invokeMethod(inlineTime, "selectTime", Q_ARG(int, 10), Q_ARG(int, 45));
        expect(requested.size() == 1 && gallery->property("selectedHour").toInt() == 10
                   && gallery->property("selectedMinute").toInt() == 45,
               "embedded time selection requests one canonical caller update");
        gallery->setProperty("selectedHour", 9);
        gallery->setProperty("selectedMinute", 30);
        expect(inlineTime->property("selectedHour").toInt() == 9
                   && inlineTime->property("selectedMinute").toInt() == 30,
               "embedded time selection preserves live caller bindings");
        inlineTime->setProperty("displayMode", 1);
        auto *hour = qobject_cast<QQuickItem *>(inlineTime->property("hourField").value<QObject *>());
        auto *minute = qobject_cast<QQuickItem *>(inlineTime->property("minuteField").value<QObject *>());
        const bool editorsReady = hour && minute && QTest::qWaitFor([&] { return window.activeFocusItem() == hour; });
        expect(editorsReady, "public time focus reaches the native hour editor");
        if (editorsReady) {
            QMetaObject::invokeMethod(hour, "selectAll");
            QTest::keyClick(&window, Qt::Key_0);
            QCoreApplication::processEvents();
            expect(hour->property("text").toString() == QStringLiteral("0")
                       && hour->property("selectionStart") == hour->property("selectionEnd"),
                   "a raw hour digit stays unselected while caller acknowledgement keeps its binding");
            QTest::keyClick(&window, Qt::Key_8);
            expect(QTest::qWaitFor([&] { return window.activeFocusItem() == minute; })
                       && gallery->property("selectedHour").toInt() == 8,
                   "two valid hour digits advance keyboard focus to minutes");
            QMetaObject::invokeMethod(minute, "selectAll");
            QTest::keyClick(&window, Qt::Key_Backspace);
            inlineTime->setProperty("displayMode", 0);
            expect(!inlineTime->property("selectionValid").toBool()
                       && inlineTime->property("displayMode").toInt() == 1
                       && gallery->property("selectedMinute").toInt() == 30,
                   "invalid text preserves the canonical time and blocks Clock mode");
            QTest::keyClick(&window, Qt::Key_4);
            QTest::keyClick(&window, Qt::Key_5);
            expect(inlineTime->property("selectionValid").toBool()
                       && gallery->property("selectedMinute").toInt() == 45,
                   "native minute input restores a valid controlled time");
            inlineTime->setProperty("displayMode", 0);
            inlineTime->setProperty("selection", 0);
            QMetaObject::invokeMethod(inlineTime, "focusSelection");
            expect(QTest::qWaitFor([&] { return window.activeFocusItem()
                       && inlineTime->isAncestorOf(window.activeFocusItem())
                       && window.activeFocusItem() != hour && window.activeFocusItem() != minute; }),
                   "Clock mode moves focus from editors to the dial");
            QTest::keyClick(&window, Qt::Key_Right);
            expect(gallery->property("selectedHour").toInt() == 9
                       && gallery->property("selectedMinute").toInt() == 45,
                   "the focused native dial steps hours without changing minutes");
        }
        inlineTime->setProperty("displayMode", 0);
        gallery->setProperty("selectedHour", 9);
        gallery->setProperty("selectedMinute", 30);
    }
    QQmlComponent timeConsumer(qmlEngine(&window));
    timeConsumer.setData(R"qml(
        import Qavsi.Material3.Style
        Material3TimePickerDialog {
            id: consumer
            property int callerHour: 9
            property int callerMinute: 30
            use24Hour: true
            selectedHour: consumer.callerHour
            selectedMinute: consumer.callerMinute
            onAcceptedTime: (hour, minute) => {
                consumer.callerHour = hour
                consumer.callerMinute = minute
            }
        }
    )qml", QUrl());
    const std::unique_ptr<QObject> timeFixture(timeConsumer.createWithInitialProperties({
        {QStringLiteral("parent"), QVariant::fromValue(window.contentItem())}
    }));
    auto *time = timeFixture.get();
    expect(time, "public time dialog can be consumed without a gallery launch button");
    if (!time) { qCritical().noquote() << timeConsumer.errorString(); return failures; }
    QSignalSpy acceptedTime(time, SIGNAL(acceptedTime(int,int)));
    QSignalSpy rejectedTime(time, SIGNAL(rejected()));
    QMetaObject::invokeMethod(time, "open");
    auto *dialogPicker = qobject_cast<QQuickItem *>(time->property("picker").value<QObject *>());
    const bool dialReady = dialogPicker && QTest::qWaitFor([&] {
        return window.activeFocusItem() && dialogPicker->isAncestorOf(window.activeFocusItem());
    });
    expect(dialReady, "opening the time dialog focuses its native clock");
    if (dialReady) {
        auto *dial = window.activeFocusItem();
        auto *accessible = QAccessible::queryAccessibleInterface(dial);
        auto *actions = accessible ? accessible->actionInterface() : nullptr;
        const bool canAdjust = actions
            && actions->actionNames().contains(QAccessibleActionInterface::increaseAction())
            && actions->actionNames().contains(QAccessibleActionInterface::decreaseAction());
        expect(canAdjust && !accessible->text(QAccessible::Description).isEmpty(),
               "the clock exposes a localized time and accessible adjustment actions");
        if (canAdjust) {
            actions->doAction(QAccessibleActionInterface::increaseAction());
            expect(time->property("currentHour").toInt() == 10,
                   "accessible increase updates the canonical dialog draft");
            dialogPicker->setEnabled(false);
            actions->doAction(QAccessibleActionInterface::increaseAction());
            expect(time->property("currentHour").toInt() == 10,
                   "disabled picker rejects accessible adjustment");
            dialogPicker->setEnabled(true);
            actions->doAction(QAccessibleActionInterface::decreaseAction());
        }
        const auto east = dial->mapToScene(QPointF(dial->width() * 0.9, dial->height() / 2)).toPoint();
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, east);
        expect(time->property("currentHour").toInt() == 3
                   && gallery->property("selectedHour").toInt() == 9,
               "a native clock tap changes only the dialog draft before acceptance");
    }
    QTest::keyClick(&window, Qt::Key_Escape);
    expect(QTest::qWaitFor([&] { return !time->property("visible").toBool(); })
               && rejectedTime.size() == 1 && time->property("selectedHour").toInt() == 9
               && acceptedTime.isEmpty(),
           "Escape from Clock mode rejects the dialog and preserves the committed time");
    QMetaObject::invokeMethod(time, "open");
    expect(time->property("currentHour").toInt() == 9 && time->property("currentMinute").toInt() == 30,
           "reopening restores the committed time");
    QMetaObject::invokeMethod(time, "selectTime", Q_ARG(int, 24), Q_ARG(int, 60));
    expect(time->property("currentHour").toInt() == 9 && time->property("currentMinute").toInt() == 30,
           "time selection rejects invalid hour and minute");
    time->setProperty("displayMode", 1);
    auto *dialogHour = qobject_cast<QQuickItem *>(dialogPicker->property("hourField").value<QObject *>());
    const bool inputFocused = dialogHour && QTest::qWaitFor([&] { return window.activeFocusItem() == dialogHour; });
    expect(inputFocused, "Input mode focuses the dialog's native hour editor");
    if (inputFocused) {
        QMetaObject::invokeMethod(dialogHour, "selectAll");
        QTest::keyClick(&window, Qt::Key_Backspace);
        expect(!time->property("selectionValid").toBool(), "empty dialog hour remains invalid until corrected");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(QTest::qWaitFor([&] { return !time->property("visible").toBool(); })
                   && rejectedTime.size() == 2 && acceptedTime.isEmpty(),
               "Escape from invalid Input mode reaches the native dialog rejection");
    }
    time->setProperty("displayMode", 0);
    QMetaObject::invokeMethod(time, "open");
    time->setProperty("use24Hour", false);
    QMetaObject::invokeMethod(time, "selectTime", Q_ARG(int, 23), Q_ARG(int, 59));
    QMetaObject::invokeMethod(time, "accept");
    expect(time->property("selectedHour").toInt() == 23 && time->property("selectedMinute").toInt() == 59
               && acceptedTime.size() == 1,
           "12-hour presentation accepts one canonical 24-hour time");
    auto *color = window.findChild<QObject *>(QStringLiteral("comparison.pickers.color"));
    expect(color, "color picker is available through the public consumer");
    if (!color) return failures;
    const QColor original = color->property("selectedColor").value<QColor>();
    auto *colorButton = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.color.button"));
    expect(colorButton, "QCM color swatch button is available through the consumer");
    if (!colorButton) return failures;
    QSignalSpy acceptedColor(color, SIGNAL(acceptedColor(QColor)));
    QSignalSpy buttonAccepted(colorButton, SIGNAL(accepted(QColor)));
    colorButton->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(color->property("visible").toBool(), "native swatch-button keyboard activation opens the color dialog");
    QMetaObject::invokeMethod(color, "selectColor", Q_ARG(QColor, QColor("#8044aa22")));
    QMetaObject::invokeMethod(color, "reject");
    expect(color->property("selectedColor").value<QColor>() == original && acceptedColor.isEmpty() && buttonAccepted.isEmpty(),
           "color cancellation preserves the caller's color");
    QMetaObject::invokeMethod(color, "open");
    expect(color->property("currentColor").value<QColor>() == original, "color reopen restores committed value");
    QMetaObject::invokeMethod(color, "selectColor", Q_ARG(QColor, QColor("#8044aa22")));
    QMetaObject::invokeMethod(color, "accept");
    expect(color->property("selectedColor").value<QColor>() == QColor("#8044aa22") && acceptedColor.size() == 1 && buttonAccepted.size() == 1,
           "color acceptance preserves alpha and the caller binding");
    auto *carousel = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.carousel"));
    expect(carousel, "carousel is available through the public consumer");
    if (!carousel) return failures;
    expect(carousel->property("count").toInt() == 10, "QCM carousel exposes all ten reference photo cards");
    QMetaObject::invokeMethod(carousel, "next");
    expect(carousel->property("currentIndex").toInt() == 1, "carousel next selects the second item");
    carousel->forceActiveFocus();
    QTest::keyClick(&window, Qt::Key_Right);
    expect(carousel->property("currentIndex").toInt() == 2, "native carousel keyboard selects the third item");
    QMetaObject::invokeMethod(carousel, "previous");
    expect(carousel->property("currentIndex").toInt() == 1, "carousel previous selects the second item");
    carousel->setProperty("currentIndex", carousel->property("count").toInt() - 1);
    QMetaObject::invokeMethod(carousel, "next");
    expect(carousel->property("currentIndex").toInt() == 9, "carousel navigation stops at the final item");
    carousel->setProperty("currentIndex", 0);
    gallery->setProperty("use24Hour", true);
    gallery->setProperty("selectedDate", originalDate);
    date->setProperty("minimumDate", originalMinimum);
    date->setProperty("maximumDate", originalMaximum);
    gallery->setProperty("selectedHour", 9);
    gallery->setProperty("selectedMinute", 30);
    gallery->setProperty("selectedColor", original);
    window.contentItem()->forceActiveFocus();
    return failures;
}
