#include <QDateTime>
#include <QQuickItem>
#include <QQuickWindow>
#include <QMetaObject>
#include <QQmlProperty>
#include <QQmlEngine>
#include <QSignalSpy>
#include <QTest>

int checkInlineDatePicker(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&failures](bool condition, const char *message) {
        if (!condition) { ++failures; qCritical() << "FAIL:" << message; }
    };
    auto *picker = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.date.inline"));
    expect(picker, "inline date picker is available through the public consumer");
    if (!picker) return failures;
    const auto date = [](int day) { return QDateTime(QDate(2026, 2, day), QTime(0, 0)); };
    auto *gallery = window.findChild<QObject *>(QStringLiteral("comparison.pickers.date.gallery"));
    expect(gallery, "date gallery owns the public fixture bindings");
    if (!gallery) return failures;
    const auto initial = gallery->property("selectedDate");
    const auto minimum = gallery->property("minimumDate");
    const auto maximum = gallery->property("maximumDate");
    const auto start = gallery->property("rangeStart");
    const auto end = gallery->property("rangeEnd");
    auto *singleField = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.date.field"));
    expect(singleField, "single-date field is available in the reference gallery");
    if (!singleField) return failures;
    const auto displayMode = picker->property("displayMode");
    const auto mode = picker->property("selectionMode");
    const auto navigation = picker->property("navigation");
    gallery->setProperty("minimumDate", date(10));
    gallery->setProperty("maximumDate", date(20));
    gallery->setProperty("selectedDate", date(15));
    gallery->setProperty("rangeStart", QDateTime());
    gallery->setProperty("rangeEnd", QDateTime());
    picker->setProperty("selectionMode", 0);
    QSignalSpy selection(picker, SIGNAL(selectedDateChangeRequested(QDateTime)));
    QMetaObject::invokeMethod(picker, "selectDate", Q_ARG(QDateTime, date(9)));
    expect(selection.isEmpty(), "inline date rejects dates outside public bounds");
    QMetaObject::invokeMethod(picker, "selectDate", Q_ARG(QDateTime, date(18)));
    expect(selection.size() == 1 && picker->property("selectedDate").toDateTime().date() == QDate(2026, 2, 18),
           "inline request updates consumer state through its live binding");

    QMetaObject::invokeMethod(picker, "toggleNavigation");
    expect(picker->property("navigation").toInt() == 1, "month header opens the year view");
    QMetaObject::invokeMethod(picker, "selectYear", Q_ARG(int, 2026));
    expect(picker->property("navigation").toInt() == 2, "choosing a year opens the month view");
    QMetaObject::invokeMethod(picker, "selectMonth", Q_ARG(int, 0));
    expect(picker->property("navigation").toInt() == 2 && picker->property("month").toInt() == 1,
           "month selection rejects a month wholly outside the date bounds");
    QMetaObject::invokeMethod(picker, "selectMonth", Q_ARG(int, 1));
    expect(picker->property("navigation").toInt() == 0 && selection.size() == 1
               && picker->property("selectedDate").toDateTime().date() == QDate(2026, 2, 18),
           "choosing a partially enabled month returns to days without changing selection");
    QMetaObject::invokeMethod(picker, "focusDate", Q_ARG(QDateTime, date(15)));
    const bool focused = QTest::qWaitFor([&] {
        return window.activeFocusItem() && picker->isAncestorOf(window.activeFocusItem());
    });
    expect(focused, "public calendar focus reaches its native day button");
    const auto *previousFocus = window.activeFocusItem();
    QTest::keyClick(&window, Qt::Key_Right);
    expect(QTest::qWaitFor([&] {
        return window.activeFocusItem() && window.activeFocusItem() != previousFocus
            && picker->isAncestorOf(window.activeFocusItem());
    }), "calendar focus settles before the next activation");
    expect(picker->property("focusedDate").toDateTime().date() == QDate(2026, 2, 16)
               && selection.size() == 1, "calendar arrows move focus without selecting a date");
    QTest::keyClick(&window, Qt::Key_Space);
    expect(selection.size() == 2 && picker->property("selectedDate").toDateTime().date() == QDate(2026, 2, 16),
           "native Space activation commits the focused day through the caller binding");
    gallery->setProperty("minimumDate", date(17));
    picker->forceActiveFocus(Qt::TabFocusReason);
    bool reachedSelectableDay = false;
    for (int step = 0; step < 12 && !reachedSelectableDay; ++step) {
        QTest::keyClick(&window, Qt::Key_Tab);
        auto *focusedItem = window.activeFocusItem();
        reachedSelectableDay = focusedItem && picker->isAncestorOf(focusedItem)
            && focusedItem->isEnabled() && focusedItem->property("text").toString() == QStringLiteral("17");
    }
    expect(reachedSelectableDay, "Tab recovers to a selectable day after bounds exclude the selected date");
    gallery->setProperty("minimumDate", date(10));
    picker->setProperty("selectionMode", 1);
    expect(!singleField->isVisible(), "Range hides the single-date launcher as in QCM");
    QSignalSpy range(picker, SIGNAL(rangeChangeRequested(QDateTime,QDateTime)));
    QMetaObject::invokeMethod(picker, "selectDate", Q_ARG(QDateTime, date(19)));
    QMetaObject::invokeMethod(picker, "selectDate", Q_ARG(QDateTime, date(12)));
    expect(range.size() == 2 && picker->property("rangeStart").toDateTime().date() == QDate(2026, 2, 12)
           && picker->property("rangeEnd").toDateTime().date() == QDate(2026, 2, 19),
           "range requests order reversed calendar selection");
    picker->setProperty("displayMode", 1);
    const bool startFocused = QTest::qWaitFor([&] {
        auto *editor = window.activeFocusItem();
        return editor && picker->isAncestorOf(editor)
            && editor->property("placeholderText").toString() == QStringLiteral("Start date");
    });
    expect(startFocused, "input mode focuses the Start date floating-label editor");
    if (startFocused) {
        expect(QQmlProperty::read(window.activeFocusItem(), QStringLiteral("TextFieldSupport.supportingText"),
                                 QQmlEngine::contextForObject(window.activeFocusItem()))
                   == picker->property("inputDateFormat"), "start editor shows the locale format as supporting text");
        QTest::keyClick(&window, Qt::Key_Tab);
        expect(QTest::qWaitFor([&] {
            auto *editor = window.activeFocusItem();
            return editor && picker->isAncestorOf(editor)
                && editor->property("placeholderText").toString() == QStringLiteral("End date");
        }), "Tab reaches the End date floating-label editor");
    }
    picker->setProperty("selectionMode", 0);
    expect(singleField->isVisible(), "Single restores the single-date launcher");
    picker->setProperty("displayMode", displayMode);
    auto *dateDialog = singleField->property("dialog").value<QObject *>();
    expect(dateDialog, "the public date-field dialog is available");
    if (dateDialog) {
        const auto originalReadOnly = singleField->property("readOnly");
        const auto committedBeforeLock = gallery->property("selectedDate");
        QSignalSpy fieldRequests(singleField, SIGNAL(selectedDateChangeRequested(QDateTime)));
        QMetaObject::invokeMethod(dateDialog, "open");
        singleField->setProperty("readOnly", true);
        expect(QTest::qWaitFor([&] { return !dateDialog->property("visible").toBool(); }),
               "locking the date field dismisses its open calendar");
        QMetaObject::invokeMethod(dateDialog, "selectDate", Q_ARG(QDateTime, date(18)));
        QMetaObject::invokeMethod(dateDialog, "accept");
        expect(fieldRequests.isEmpty() && gallery->property("selectedDate") == committedBeforeLock,
               "a locked date field rejects late calendar acceptance without changing caller state");
        singleField->setProperty("readOnly", false);
        QMetaObject::invokeMethod(dateDialog, "open");
        QMetaObject::invokeMethod(dateDialog, "selectDate", Q_ARG(QDateTime, date(18)));
        QMetaObject::invokeMethod(dateDialog, "accept");
        expect(fieldRequests.size() == 1 && gallery->property("selectedDate").toDateTime().date() == QDate(2026, 2, 18),
               "unlocking the date field restores calendar editing through the existing caller binding");
        singleField->setProperty("readOnly", originalReadOnly);
    }
    gallery->setProperty("minimumDate", minimum);
    gallery->setProperty("maximumDate", maximum);
    gallery->setProperty("selectedDate", initial);
    gallery->setProperty("rangeStart", start);
    gallery->setProperty("rangeEnd", end);
    picker->setProperty("selectionMode", mode);
    picker->setProperty("navigation", navigation);
    return failures;
}
