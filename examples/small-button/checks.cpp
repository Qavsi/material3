#include <QAccessibilityHints>
#include <QFont>
#include <QGuiApplication>
#include <QImage>
#include <QLineF>
#include <QQmlApplicationEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSignalSpy>
#include <QStyleHints>
#include <QTest>

namespace {
int assertions = 0;
int failures = 0;
void expect(bool condition, const char *description)
{
    ++assertions;
    if (!condition) {
        ++failures;
        qCritical() << "FAIL:" << description;
    }
}
QColor background(QQuickItem *button)
{
    auto *item = button->property("background").value<QObject *>();
    auto *style = item ? item->property("backgroundStyle").value<QObject *>() : nullptr;
    return style ? style->property("color").value<QColor>() : QColor();
}

QColor pixel(const QImage &image, QQuickItem *button, const QPointF &position)
{
    if (image.isNull())
        return {};
    const auto point = button->mapToScene(position) * image.devicePixelRatio();
    return image.pixelColor(qRound(point.x()), qRound(point.y()));
}

void checkFeedback(QQuickWindow &window, QQuickItem *button, QQuickItem *themeButton)
{
    auto *delegate = button->findChild<QQuickItem *>("material3.small.background");
    expect(delegate != nullptr, "Small uses the Material3 feedback delegate");
    if (!delegate)
        return;
    expect(QTest::qWaitFor([delegate] {
        return delegate->findChild<QQuickItem *>("material3.small.feedback") != nullptr;
    }, 1500), "backend feedback loader finishes");
    auto *feedback = delegate->findChild<QQuickItem *>("material3.small.feedback");
    expect(feedback != nullptr, "feedback render item exists");
    if (!feedback)
        return;
    const auto actualApi = window.rendererInterface()->graphicsApi();
    const bool metal = actualApi == QSGRendererInterface::Metal;
    expect(delegate->property("feedbackRenderer").toString() == (metal ? "shader" : "painter"),
           "actual Metal selects shader and other backends retain painter");
    if (metal) {
        expect(QTest::qWaitFor([feedback] {
            return feedback->property("status").toInt() == 0;
        }, 1500), "Metal ripple shader is compiled");
        expect(feedback->property("log").toString().isEmpty(), "Metal ripple shader has no compilation log");
    }

    const auto settled = [delegate] {
        return !delegate->property("rippleRunning").toBool()
            && !delegate->property("rippleVisible").toBool();
    };
    const auto settle = [&] {
        expect(QTest::qWaitFor(settled, 1500), "released feedback eventually settles");
    };
    const auto scenePoint = [button](const QPointF &local) {
        return button->mapToScene(local).toPoint();
    };
    const auto center = scenePoint(QPointF(button->width() / 2, button->height() / 2));
    const auto outside = QPoint(window.width() - 5, window.height() - 5);
    QSignalSpy clicked(button, SIGNAL(clicked()));
    window.setProperty("darkMode", false);
    window.setProperty("reducedMotion", false);
    expect(delegate->property("reduceMotion").toBool()
               == (QGuiApplication::styleHints()->accessibility()->motionPreference()
                   == Qt::MotionPreference::ReducedMotion),
           "default motion policy follows the public OS preference");
    QTest::mouseMove(&window, outside);
    button->setProperty("focus", false);
    settle();
    QTest::qWait(30);
    const auto idleImage = window.grabWindow();
    QTest::mouseMove(&window, center);
    QTest::qWait(30);
    const auto hoverImage = window.grabWindow();
    if (!idleImage.isNull() && !hoverImage.isNull())
        expect(pixel(idleImage, button, QPointF(8, button->height() / 2))
                   != pixel(hoverImage, button, QPointF(8, button->height() / 2)),
               "hover paints the state layer inside the button");
    QTest::mouseMove(&window, outside);

    themeButton->forceActiveFocus(Qt::OtherFocusReason);
    QTest::keyClick(&window, Qt::Key_Tab, Qt::ShiftModifier);
    expect(button->hasActiveFocus(), "Backtab reaches Small through the real focus chain");
    expect(button->property("visualFocus").toBool() && delegate->property("focusVisible").toBool(),
           "keyboard navigation shows the focus indicator");
    QTest::qWait(30);
    const auto keyboardFocusImage = window.grabWindow();
    const QPointF ringPoint(button->width() / 2, -3);
    if (!idleImage.isNull() && !keyboardFocusImage.isNull())
        expect(pixel(idleImage, button, ringPoint) != pixel(keyboardFocusImage, button, ringPoint),
               "keyboard focus paints the visible outer indicator");
    QTest::keyClick(&window, Qt::Key_Tab);
    expect(themeButton->hasActiveFocus() && !delegate->property("focusVisible").toBool(),
           "Tab moves focus and clears the previous indicator");
    QTest::keyClick(&window, Qt::Key_Tab, Qt::ShiftModifier);
    expect(button->hasActiveFocus() && delegate->property("focusVisible").toBool(),
           "Backtab restores the keyboard indicator");

    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(clicked.count() == 1, "pointer activation after keyboard navigation clicks once");
    expect(button->hasActiveFocus() && !delegate->property("focusVisible").toBool(),
           "mouse focus keeps the keyboard-only indicator hidden");
    settle();
    QTest::qWait(30);
    const auto beforePress = window.grabWindow();
    if (!idleImage.isNull() && !beforePress.isNull())
        expect(pixel(idleImage, button, ringPoint) == pixel(beforePress, button, ringPoint),
               "mouse focus removes the rendered outer indicator");
    const QPointF pressLocal(12, button->height() / 2);
    const auto pressPoint = scenePoint(pressLocal);
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    expect(button->property("pressed").toBool(), "feedback preserves native pointer press");
    const auto origin = delegate->property("rippleOrigin").toPointF();
    expect(QLineF(origin, pressLocal).length() <= 1, "pointer ripple starts at the actual press position");
    if (delegate->property("reduceMotion").toBool()) {
        expect(!delegate->property("rippleRunning").toBool(), "platform reduced motion suppresses animation");
    } else {
        expect(QTest::qWaitFor([delegate] {
            return delegate->property("rippleRunning").toBool()
                && delegate->property("rippleVisible").toBool();
        }, 300), "pointer press starts visible ripple feedback");
    }
    QTest::qWait(90);
    const auto duringPress = window.grabWindow();
    expect(!beforePress.isNull() && !duringPress.isNull(), "feedback renders before and during press");
    if (!beforePress.isNull() && !duringPress.isNull()) {
        expect(pixel(beforePress, button, QPointF(1, 1)) == pixel(duringPress, button, QPointF(1, 1)),
               "feedback stays clipped outside the rounded corner");
        expect(pixel(beforePress, button, QPointF(8, button->height() / 2))
                   != pixel(duringPress, button, QPointF(8, button->height() / 2)),
               "pressed feedback changes a rendered pixel inside the capsule");
        if (!delegate->property("reduceMotion").toBool())
            expect(pixel(duringPress, button, QPointF(8, button->height() / 2))
                       != pixel(duringPress, button, QPointF(button->width() - 8, button->height() / 2)),
                   "rendered ripple expands locally instead of tinting the whole surface at once");
    }
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    expect(clicked.count() == 2 && !button->property("pressed").toBool(),
           "ripple release activates exactly once and clears pressed");
    settle();
    QTest::qWait(30);
    const auto afterRelease = window.grabWindow();
    if (!beforePress.isNull() && !afterRelease.isNull())
        expect(pixel(beforePress, button, QPointF(8, button->height() / 2))
                   == pixel(afterRelease, button, QPointF(8, button->height() / 2)),
               "settled feedback restores the original rendered surface");

    QTest::mouseMove(&window, outside);
    themeButton->forceActiveFocus(Qt::OtherFocusReason);
    QTest::keyClick(&window, Qt::Key_Tab, Qt::ShiftModifier);
    QTest::keyPress(&window, Qt::Key_Space);
    expect(button->property("pressed").toBool() && clicked.count() == 2,
           "Space press preserves native pressed state without an early click");
    expect(QLineF(delegate->property("rippleOrigin").toPointF(),
                  QPointF(button->width() / 2, button->height() / 2)).length() <= 1,
           "keyboard ripple starts at the button center");
    QTest::keyRelease(&window, Qt::Key_Space);
    expect(clicked.count() == 3 && !button->property("pressed").toBool(),
           "Space release activates exactly once");
    settle();

    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    QTest::mouseMove(&window, outside);
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, outside);
    expect(clicked.count() == 3 && !button->property("pressed").toBool(),
           "release outside cancels activation without a stuck press");
    settle();
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(clicked.count() == 4, "a fresh click works after cancellation without an input grab");
    settle();

    for (bool dark : {true, false}) {
        const auto clickCount = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        window.setProperty("darkMode", dark);
        QTest::qWait(40);
        const bool sameFeedback = button->findChild<QQuickItem *>("material3.small.background") == delegate
            && delegate->findChild<QQuickItem *>("material3.small.feedback") == feedback;
        expect(sameFeedback, "theme changes preserve the live feedback instance");
        if (!sameFeedback)
            return;
        expect(button->property("pressed").toBool() && background(button).isValid(),
               "theme changes preserve an active native press and valid styling");
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(clicked.count() == clickCount + 1, "theme switch during press does not duplicate activation");
        settle();
    }

    for (const auto *property : {"enabled", "visible"}) {
        const auto clickCount = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        QTest::qWait(40);
        button->setProperty(property, false);
        expect(QTest::qWaitFor(settled, 300), "disable or hide clears active ripple immediately");
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        button->setProperty(property, true);
        expect(!button->property("pressed").toBool() && clicked.count() == clickCount,
               "disable or hide cancels the native press without activation");
        expect(!delegate->property("focusVisible").toBool(), "cancelled mouse press leaves no focus indicator");
    }

    QTest::mouseMove(&window, outside);
    button->setProperty("focus", false);
    window.setProperty("reducedMotion", true);
    QTest::qWait(30);
    expect(delegate->property("reduceMotion").toBool(), "caller reduced motion reaches the background");
    QTest::mouseMove(&window, pressPoint);
    QTest::qWait(30);
    const auto reducedBefore = window.grabWindow();
    const auto reducedClickCount = clicked.count();
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    QTest::qWait(60);
    const auto reducedDuring = window.grabWindow();
    expect(!delegate->property("rippleRunning").toBool(), "reduced motion has no press animation");
    if (!reducedBefore.isNull() && !reducedDuring.isNull())
        expect(pixel(reducedBefore, button, QPointF(8, button->height() / 2))
                   != pixel(reducedDuring, button, QPointF(8, button->height() / 2)),
               "reduced motion retains static rendered press feedback");
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    expect(settled() && clicked.count() == reducedClickCount + 1,
           "reduced motion releases immediately and activates once");

    window.setProperty("reducedMotion", false);
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    QTest::qWait(40);
    window.setProperty("reducedMotion", true);
    expect(QTest::qWaitFor([delegate] {
        return delegate->property("reduceMotion").toBool()
            && !delegate->property("rippleRunning").toBool();
    }, 300), "enabling reduced motion stops an in-flight animation");
    expect(button->property("pressed").toBool(), "motion preference change preserves the held native press");
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
    expect(settled(), "motion preference change leaves no release animation");
    window.setProperty("reducedMotion", false);

    const auto descendantCount = button->findChildren<QObject *>().size();
    const auto burstClickCount = clicked.count();
    for (int i = 0; i < 8; ++i) {
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center);
        QTest::qWait(20);
    }
    settle();
    expect(clicked.count() == burstClickCount + 8, "repeated feedback preserves one activation per click");
    expect(button->findChildren<QObject *>().size() == descendantCount,
           "completed clicks do not accumulate per-click objects");
}
}

int checkSmallButton(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    if (QGuiApplication::platformName() != "offscreen") {
        window.raise();
        window.requestActivate();
        expect(QTest::qWaitForWindowExposed(&window, 1500), "native test window is exposed for animation frames");
        expect(QTest::qWaitForWindowActive(&window, 1500), "native test window is active for keyboard navigation");
    }
    QTest::qWait(150);
    const auto api = window.rendererInterface()->graphicsApi();
    if (qEnvironmentVariable("QT_QUICK_BACKEND") == "software")
        expect(api == QSGRendererInterface::Software, "actual renderer is software");
    if (qEnvironmentVariable("QSG_RHI_BACKEND") == "metal")
        expect(api == QSGRendererInterface::Metal, "actual renderer is Metal");
    auto *button = window.findChild<QQuickItem *>("smallButton");
    auto *disabled = window.findChild<QQuickItem *>("disabledButton");
    auto *overrides = window.findChild<QQuickItem *>("callerOverrides");
    auto *themeButton = window.findChild<QQuickItem *>("themeButton");
    if (!button || !disabled || !overrides || !themeButton)
        return 3;
    QSignalSpy clicked(button, SIGNAL(clicked()));
    expect(window.isVisible(), "window is visible");
    expect(button->height() == 40, "Small painted height is 40 logical pixels");
    expect(button->property("leftPadding").toReal() == 16, "Small horizontal padding is 16");
    auto font = button->property("font").value<QFont>();
    qInfo() << "Resolved label font:" << font << "tracking:" << font.letterSpacing();
    expect(font.pixelSize() == 14 && font.weight() == QFont::Medium, "Label Large size and weight");
    expect(qAbs(font.letterSpacing() - 0.1) < 1.0 / 64.0, "Label Large tracking within QFont fixed-point precision");
    expect(background(button) == QColor("#6750a4"), "light primary role");
    auto center = button->mapToScene(QPointF(button->width() / 2, button->height() / 2)).toPoint();
    QTest::mouseMove(&window, center);
    QTest::qWait(30);
    expect(button->property("hovered").toBool(), "native hover entry");
    expect(background(button) == QColor("#6750a4"), "hover preserves the primary token below the painted state layer");
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(button->property("pressed").toBool(), "native pressed state");
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(clicked.count() == 1, "mouse click activates exactly once");
    QTest::mouseMove(&window, QPoint(window.width() - 5, window.height() - 5));
    button->setProperty("focus", false);
    QTest::qWait(30);
    expect(!button->property("hovered").toBool(), "hover clears on leave");
    button->forceActiveFocus(Qt::TabFocusReason);
    expect(button->hasActiveFocus(), "native keyboard focus");
    QTest::keyClick(&window, Qt::Key_Space);
    expect(clicked.count() == 2, "keyboard Space activates once");
    const auto disabledCenter = disabled->mapToScene(QPointF(disabled->width() / 2, disabled->height() / 2)).toPoint();
    QSignalSpy disabledClicked(disabled, SIGNAL(clicked()));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, disabledCenter);
    expect(disabledClicked.isEmpty(), "disabled button does not activate");

    for (bool dark : {true, false, true, false}) {
        window.setProperty("darkMode", dark);
        QTest::qWait(40);
        expect(window.findChild<QQuickItem *>("smallButton") == button, "theme keeps the same button instance");
        expect(button->property("text").toString() == QString::fromUtf8("Kaydet"), "theme preserves text");
        expect(button->hasActiveFocus(), "theme preserves focus");
        expect(button->height() == 40, "theme preserves Small geometry");
        expect(background(button) != QColor(), "resolved style remains valid");
        const auto callerFont = overrides->property("font").value<QFont>();
        expect(callerFont.pixelSize() == overrides->property("requestedFontSize").toInt(), "caller font binding preserved");
        expect(callerFont.letterSpacing() == 0, "explicit zero tracking preserved");
        expect(overrides->property("leftPadding").toReal() == 0 && overrides->property("spacing").toReal() == 0,
               "explicit zero padding and spacing preserved");
        expect(overrides->width() == 180 && overrides->height() == 52, "caller geometry preserved");
    }
    overrides->setProperty("requestedFontSize", 23);
    overrides->setProperty("requestedWidth", 210);
    overrides->setProperty("requestedPadding", 3);
    QTest::qWait(30);
    expect(overrides->property("font").value<QFont>().pixelSize() == 23, "font binding is still live");
    expect(overrides->width() == 210 && overrides->property("leftPadding").toReal() == 3, "geometry and padding bindings remain live");
    button->setProperty("focus", false);
    QTest::qWait(30);
    expect(background(button) == QColor("#6750a4"), "light normal restored");
    window.setProperty("darkMode", true);
    button->setProperty("hoverEnabled", false);
    if (auto *delegate = button->findChild<QQuickItem *>("material3.small.background"))
        expect(QTest::qWaitFor([delegate] {
            return !delegate->property("rippleRunning").toBool()
                && !delegate->property("rippleVisible").toBool();
        }, 1500), "theme color measurement waits for transient feedback to settle");
    QTest::qWait(50);
    expect(background(button) == QColor("#d0bcff"), "dark primary role");
    const auto image = window.grabWindow();
    expect(!image.isNull(), "renderer produces an image");
    if (!image.isNull()) {
        const auto scale = image.devicePixelRatio();
        const auto point = button->mapToScene(QPointF(12, button->height() / 2));
        const auto pixel = image.pixelColor(qRound(point.x() * scale), qRound(point.y() * scale));
        expect(qAbs(pixel.red() - 208) < 3 && qAbs(pixel.green() - 188) < 3 && qAbs(pixel.blue() - 255) < 3,
               "rendered dark button uses Material3 primary");
    }
    button->setProperty("hoverEnabled", true);
    window.setProperty("darkMode", false);
    const auto themeCenter = themeButton->mapToScene(QPointF(themeButton->width() / 2, themeButton->height() / 2)).toPoint();
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, themeCenter);
    expect(window.property("darkMode").toBool(), "visible theme button changes theme");
    checkFeedback(window, button, themeButton);
    expect(warnings.isEmpty(), "no runtime QML warning during transitions");
    qInfo() << "Qt" << qVersion() << "backend" << qEnvironmentVariable("QT_QUICK_BACKEND")
            << "graphicsApi" << api << "assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
