#include <QAccessibilityHints>
#include <QFont>
#include <QGuiApplication>
#include <QImage>
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

QPoint center(QQuickItem *button)
{
    return button->mapToScene(QPointF(button->width() / 2, button->height() / 2)).toPoint();
}

QImage renderedButton(QQuickWindow &window, QQuickItem *button)
{
    const auto image = window.grabWindow();
    if (image.isNull())
        return {};
    const auto origin = button->mapToScene(QPointF()) * image.devicePixelRatio();
    return image.copy(QRect(qRound(origin.x()), qRound(origin.y()),
        qRound(button->width() * image.devicePixelRatio()),
        qRound(button->height() * image.devicePixelRatio())));
}

bool paintsPrimary(QQuickWindow &window, QQuickItem *button, const QColor &expected)
{
    const auto image = window.grabWindow();
    if (image.isNull())
        return false;
    const auto point = button->mapToScene(QPointF(12, button->height() / 2)) * image.devicePixelRatio();
    const auto actual = image.pixelColor(qRound(point.x()), qRound(point.y()));
    return qAbs(actual.red() - expected.red()) <= 2
        && qAbs(actual.green() - expected.green()) <= 2
        && qAbs(actual.blue() - expected.blue()) <= 2;
}

void checkTheme(QQuickWindow &window, QQuickItem *button, QQuickItem *themeButton)
{
    // Observe the rendered public control, never its background/delegate tree.
    expect(paintsPrimary(window, button, QColor("#6750a4")), "light button paints the Material3 primary color");
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center(themeButton));
    expect(window.property("darkMode").toBool()
               && paintsPrimary(window, button, QColor("#d0bcff")),
           "theme selection changes the existing button to the dark primary color");
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center(themeButton));
    expect(!window.property("darkMode").toBool()
               && paintsPrimary(window, button, QColor("#6750a4")),
           "returning to light restores the button surface");
}

void checkActivation(QQuickWindow &window, QQuickItem *button, QQuickItem *disabled,
                     QQuickItem *themeButton)
{
    QSignalSpy clicked(button, SIGNAL(clicked()));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center(button));
    expect(clicked.size() == 1, "one pointer click activates the button once");

    themeButton->forceActiveFocus(Qt::OtherFocusReason);
    QTest::keyClick(&window, Qt::Key_Tab, Qt::ShiftModifier);
    expect(button->hasActiveFocus() && button->property("visualFocus").toBool(),
           "Backtab reaches the button with keyboard focus");
    QTest::keyClick(&window, Qt::Key_Space);
    expect(clicked.size() == 2, "Space activates the focused button once");

    QSignalSpy disabledClicked(disabled, SIGNAL(clicked()));
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center(disabled));
    expect(disabledClicked.isEmpty(), "a disabled button cannot be activated");

    const QPoint outside(window.width() - 2, window.height() - 2);
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, center(button));
    QTest::mouseMove(&window, outside);
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, outside);
    expect(clicked.size() == 2 && !button->property("pressed").toBool(),
           "releasing outside cancels activation without leaving a stuck press");
}

void checkReducedMotion(QQuickWindow &window, QQuickItem *button, QQuickItem *motionButton)
{
    auto *style = window.property("materialStyle").value<QObject *>();
    expect(style, "the public Material3 style is available");
    if (!style)
        return;
    window.setProperty("reducedMotion", false);
    const bool systemReduced = QGuiApplication::styleHints()->accessibility()->motionPreference()
        == Qt::MotionPreference::ReducedMotion;
    expect(style->property("effectiveReducedMotion").toBool() == systemReduced,
           "the default motion policy respects the OS accessibility preference");
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center(motionButton));
    expect(style->property("effectiveReducedMotion").toBool(), "the caller can request reduced motion");
    QTest::mouseMove(&window, center(button));
    const auto idle = renderedButton(window, button);
    QSignalSpy clicked(button, SIGNAL(clicked()));
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, center(button));
    const auto pressed = renderedButton(window, button);
    // One temporal observation verifies static feedback; no ripple phase/timing contract.
    QTest::qWait(60);
    const auto held = renderedButton(window, button);
    expect(!idle.isNull() && !pressed.isNull() && idle != pressed,
           "reduced motion still provides visible pressed feedback");
    expect(pressed == held && button->property("pressed").toBool(),
           "held reduced-motion feedback remains visually static");
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, center(button));
    expect(clicked.size() == 1 && !button->property("pressed").toBool(),
           "reduced motion preserves one native activation on release");
}

void checkCallerBindings(QQuickWindow &window, QQuickItem *button)
{
    window.setProperty("darkMode", true);
    button->setProperty("requestedFontSize", 23);
    button->setProperty("requestedWidth", 210);
    button->setProperty("requestedPadding", 3);
    expect(button->property("font").value<QFont>().pixelSize() == 23,
           "theme changes preserve the caller's live font binding");
    expect(button->width() == 210 && button->property("leftPadding").toReal() == 3,
           "caller geometry and padding bindings remain live");
}
} // namespace

int checkSmallButton(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    expect(QTest::qWaitForWindowExposed(&window), "the consumer window exposes");
    window.requestActivate();
    auto *button = window.findChild<QQuickItem *>("smallButton");
    auto *disabled = window.findChild<QQuickItem *>("disabledButton");
    auto *themeButton = window.findChild<QQuickItem *>("themeButton");
    auto *motionButton = window.findChild<QQuickItem *>("motionButton");
    auto *overrides = window.findChild<QQuickItem *>("callerOverrides");
    expect(button && disabled && themeButton && motionButton && overrides,
           "the real consumer exposes its control test selectors");
    if (!button || !disabled || !themeButton || !motionButton || !overrides)
        return 1;
    const auto api = window.rendererInterface()->graphicsApi();
    if (qEnvironmentVariable("QT_QUICK_BACKEND") == "software")
        expect(api == QSGRendererInterface::Software, "software fallback uses the actual software renderer");
    window.setProperty("reducedMotion", true);
    checkTheme(window, button, themeButton);
    checkActivation(window, button, disabled, themeButton);
    checkReducedMotion(window, button, motionButton);
    checkCallerBindings(window, overrides);
    expect(warnings.isEmpty(), "public control interactions produce no QML warnings");
    qInfo() << "Qt" << qVersion() << "Small Button assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
