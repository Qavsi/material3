#include <QDateTime>
#include <QColor>
#include <QQuickItem>
#include <QMetaObject>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>

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
    auto *time = window.findChild<QObject *>(QStringLiteral("comparison.pickers.time"));
    expect(time, "time picker is available through the public consumer");
    if (!time) return failures;
    QSignalSpy acceptedTime(time, SIGNAL(acceptedTime(int,int)));
    QMetaObject::invokeMethod(time, "open");
    QMetaObject::invokeMethod(time, "selectTime", Q_ARG(int, 23), Q_ARG(int, 59));
    QMetaObject::invokeMethod(time, "reject");
    expect(time->property("selectedHour").toInt() == 9 && acceptedTime.isEmpty(),
           "time cancellation preserves the committed hour");
    QMetaObject::invokeMethod(time, "open");
    expect(time->property("currentHour").toInt() == 9 && time->property("currentMinute").toInt() == 30,
           "reopening restores the committed time");
    QMetaObject::invokeMethod(time, "selectTime", Q_ARG(int, 24), Q_ARG(int, 60));
    expect(time->property("currentHour").toInt() == 9 && time->property("currentMinute").toInt() == 30,
           "time selection rejects invalid hour and minute");
    gallery->setProperty("use24Hour", false);
    QMetaObject::invokeMethod(time, "selectTime", Q_ARG(int, 23), Q_ARG(int, 59));
    QMetaObject::invokeMethod(time, "accept");
    expect(time->property("selectedHour").toInt() == 23 && time->property("selectedMinute").toInt() == 59
               && acceptedTime.size() == 1,
           "12-hour presentation accepts one canonical 24-hour time");
    auto *color = window.findChild<QObject *>(QStringLiteral("comparison.pickers.color"));
    expect(color, "color picker is available through the public consumer");
    if (!color) return failures;
    const QColor original = color->property("selectedColor").value<QColor>();
    QSignalSpy acceptedColor(color, SIGNAL(acceptedColor(QColor)));
    QMetaObject::invokeMethod(color, "open");
    QMetaObject::invokeMethod(color, "selectColor", Q_ARG(QColor, QColor("#8044aa22")));
    QMetaObject::invokeMethod(color, "reject");
    expect(color->property("selectedColor").value<QColor>() == original && acceptedColor.isEmpty(),
           "color cancellation preserves the caller's color");
    QMetaObject::invokeMethod(color, "open");
    expect(color->property("currentColor").value<QColor>() == original, "color reopen restores committed value");
    QMetaObject::invokeMethod(color, "selectColor", Q_ARG(QColor, QColor("#8044aa22")));
    QMetaObject::invokeMethod(color, "accept");
    expect(color->property("selectedColor").value<QColor>() == QColor("#8044aa22") && acceptedColor.size() == 1,
           "color acceptance preserves alpha and the caller binding");
    auto *carousel = window.findChild<QQuickItem *>(QStringLiteral("comparison.pickers.carousel"));
    expect(carousel, "carousel is available through the public consumer");
    if (!carousel) return failures;
    QMetaObject::invokeMethod(carousel, "next");
    expect(carousel->property("currentIndex").toInt() == 1, "carousel next selects the second item");
    carousel->forceActiveFocus();
    QTest::keyClick(&window, Qt::Key_Right);
    expect(carousel->property("currentIndex").toInt() == 2, "native carousel keyboard selects the third item");
    QMetaObject::invokeMethod(carousel, "previous");
    expect(carousel->property("currentIndex").toInt() == 1, "carousel previous selects the second item");
    QMetaObject::invokeMethod(carousel, "next");
    QMetaObject::invokeMethod(carousel, "next");
    QMetaObject::invokeMethod(carousel, "next");
    expect(carousel->property("currentIndex").toInt() == 3, "carousel navigation stops at the final item");
    carousel->setProperty("currentIndex", 0);
    gallery->setProperty("use24Hour", true);
    gallery->setProperty("selectedDate", value(15));
    gallery->setProperty("selectedHour", 9);
    gallery->setProperty("selectedMinute", 30);
    gallery->setProperty("selectedColor", original);
    window.contentItem()->forceActiveFocus();
    return failures;
}
