#include <QAccessibilityHints>
#include <QFont>
#include <QElapsedTimer>
#include <QScreen>
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

void logFeedbackState(QQuickItem *button, QQuickItem *delegate, const char *stage)
{
    qInfo() << stage << "pressed" << button->property("pressed")
            << "reduceMotion" << delegate->property("reduceMotion")
            << "running" << delegate->property("rippleRunning")
            << "visible" << delegate->property("rippleVisible")
            << "progress" << delegate->property("rippleProgress")
            << "opacity" << delegate->property("rippleOpacity")
            << "base" << delegate->property("stateLayerOpacity")
            << "phase" << delegate->property("ripplePhase");
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
    if (!delegate->property("reduceMotion").toBool())
        expect(QTest::qWaitFor([delegate] {
            return delegate->property("rippleProgress").toReal() >= 0.13;
        }, 1000), "animated press reaches the visible QCM wave before sampling");
    const auto duringPress = window.grabWindow();
    expect(!beforePress.isNull() && !duringPress.isNull(), "feedback renders before and during press");
    if (!beforePress.isNull() && !duringPress.isNull()) {
        expect(pixel(beforePress, button, QPointF(1, 1)) == pixel(duringPress, button, QPointF(1, 1)),
               "feedback stays clipped outside the rounded corner");
        expect(pixel(beforePress, button, QPointF(8, button->height() / 2))
                   != pixel(duringPress, button, QPointF(8, button->height() / 2)),
               "pressed feedback changes a rendered pixel inside the capsule");
        if (!delegate->property("reduceMotion").toBool()) {
            int minimum = 1000;
            int maximum = -1000;
            for (int x = 8; x <= button->width() - 8; ++x) {
                const QPointF sample(x, button->height() / 5);
                const int delta = pixel(duringPress, button, sample).red()
                    - pixel(beforePress, button, sample).red();
                minimum = qMin(minimum, delta);
                maximum = qMax(maximum, delta);
            }
            if (maximum - minimum < 2)
                qWarning() << "QCM wave sample" << delegate->property("rippleProgress")
                           << delegate->property("rippleOpacity") << delegate->property("ripplePhase")
                           << "range" << minimum << maximum << "active" << window.isActive()
                           << "exposed" << window.isExposed();
            expect(maximum - minimum >= 2,
                   "QCM wave adds local variation above the uniform pressed state layer");
        }
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
        expect(qAbs(delegate->property("stateLayerOpacity").toReal() - 0.12) < 0.0001,
               "theme changes retain the QCM held base layer");
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

    auto *tokens = delegate->property("tokens").value<QObject *>();
    expect(tokens && tokens->property("rippleExpansionDuration").toInt() == 450
               && tokens->property("rippleReleaseDuration").toInt() == 350
               && tokens->property("rippleFadeDuration").toInt() == 150,
           "QCM press/release/two-stage fade durations are 450/350/150 ms");
    expect(tokens && qAbs(tokens->property("rippleHoldProgress").toReal() - 0.4) < 0.0001
               && qAbs(tokens->property("rippleOpacity").toReal() - 0.12) < 0.0001
               && tokens->property("rippleNoiseDuration").toInt() == 7000,
           "QCM hold, opacity and noise constants are preserved");
    const auto progress = [&] { return delegate->property("rippleProgress").toReal(); };
    const auto opacity = [&] { return delegate->property("rippleOpacity").toReal(); };
    const auto phase = [&] { return delegate->property("ripplePhase").toReal(); };
    const auto base = [&] { return delegate->property("stateLayerOpacity").toReal(); };
    const auto continuousProgress = [&](qreal before, qreal elapsedMs, bool repress) {
        const qreal frameMs = 1000 / qMax<qreal>(1, window.screen()->refreshRate());
        // QTest processes events during input dispatch; allow one display frame plus measured call time.
        const qreal rate = qMax(3 * 0.4 / 450, 3 * (1 - before) / 350);
        const qreal allowedChange = rate * (elapsedMs + frameMs + 1);
        const bool continuous = progress() > 0 && progress() < 1
            && (repress ? progress() >= 0.4 : progress() >= before - 0.0001)
            && qAbs(progress() - before) <= allowedChange;
        if (!continuous)
            qInfo() << "Continuity failure: before" << before << "after" << progress()
                    << "event ms" << elapsedMs << "one-frame bound" << allowedChange;
        return continuous;
    };
    const auto hold = [&] {
        expect(QTest::qWaitFor([&] { return qAbs(progress() - 0.4) < 0.0001; }, 1000),
               "a held QCM wave reaches progress 0.4");
    };

    if (!delegate->property("reduceMotion").toBool()) {
        auto count = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(button->property("pressed").toBool() && clicked.count() == count
                   && qAbs(opacity() - 0.12) < 0.0001 && qAbs(base() - 0.12) < 0.0001,
               "QCM press starts base and wave at 0.12 without an early native click");
        hold();
        const auto heldPhase = phase();
        QTest::qWait(70);
        expect(qAbs(progress() - 0.4) < 0.0001 && qAbs(opacity() - 0.12) < 0.0001
                   && button->property("pressed").toBool(),
               "long press holds the wave at 0.4 until release");
        expect(metal ? phase() != heldPhase && delegate->property("rippleRunning").toBool()
                     : phase() == heldPhase && !delegate->property("rippleRunning").toBool(),
               "Metal animates sparkle phase during hold; software does not spend CPU on omitted noise");
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(clicked.count() == count + 1 && !button->property("pressed").toBool()
                   && progress() >= 0.4 && delegate->property("rippleVisible").toBool(),
               "held release continues from 0.4 with one native activation");
        expect(QTest::qWaitFor([&] { return base() < 0.119 && opacity() > 0.119; }, 250),
               "release first fades the state layer while preserving wave opacity");
        expect(QTest::qWaitFor([&] { return opacity() > 0 && opacity() < 0.119; }, 400),
               "the second fade stage removes wave opacity");
        settle();
        const auto stoppedPhase = phase();
        QTest::qWait(60);
        expect(phase() == stoppedPhase && opacity() == 0,
               "released feedback stops noise animation and leaves no wave");

        count = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        QTest::qWait(50);
        const auto earlyProgress = progress();
        expect(earlyProgress > 0 && earlyProgress < 0.4,
               "short press is still inside the QCM expansion");
        QElapsedTimer releaseEvent;
        releaseEvent.start();
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(continuousProgress(earlyProgress, releaseEvent.nsecsElapsed() / 1e6, false)
                   && clicked.count() == count + 1,
               "early release keeps current progress instead of restarting the wave");
        settle();

        count = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        hold();
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(QTest::qWaitFor([&] { return progress() > 0.6 && opacity() > 0; }, 200),
               "release tail advances beyond the held progress");
        const auto tailProgress = progress();
        QElapsedTimer repressEvent;
        repressEvent.start();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(continuousProgress(tailProgress, repressEvent.nsecsElapsed() / 1e6, true)
                   && clicked.count() == count + 1,
               "repress preserves QCM tail progress and emits no extra activation");
        hold();
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        expect(clicked.count() == count + 2, "repress and release still activate once per completed click");
        settle();
    }

    for (const auto *property : {"enabled", "visible"}) {
        const auto count = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        QTest::qWait(40);
        expect(button->property("pressed").toBool(), "hide/disable scenario begins with a real native press");
        button->setProperty(property, false);
        expect(settled(), "hide and disable clear active wave synchronously");
        const auto clearedPhase = phase();
        QTest::qWait(60);
        expect(phase() == clearedPhase, "hide and disable stop sparkle phase updates");
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        button->setProperty(property, true);
        expect(clicked.count() == count, "cancelled hidden or disabled presses do not activate");
        // Visibility restoration changes the enclosing layout before the next input event.
        QTest::qWait(30);
    }

    const auto reducedPressPoint = scenePoint(pressLocal);
    QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, reducedPressPoint);
    expect(button->property("pressed").toBool(), "reduced-motion scenario starts with a real native press");
    QTest::qWait(40);
    window.setProperty("reducedMotion", true);
    const auto reducedPressIsStatic = [&] {
        return delegate->property("reduceMotion").toBool() && button->property("pressed").toBool()
            && !delegate->property("rippleRunning").toBool()
            && opacity() == 0 && qAbs(base() - 0.12) < 0.0001;
    };
    if (!reducedPressIsStatic())
        logFeedbackState(button, delegate, "Before reduced-motion binding propagation:");
    const bool reducedPressSettled = QTest::qWaitFor(reducedPressIsStatic, 300);
    if (!reducedPressSettled)
        logFeedbackState(button, delegate, "Reduced-motion propagation failed:");
    expect(reducedPressSettled,
           "mid-press reduced motion retains only the static 0.12 layer and native press");
    const auto reducedPhase = phase();
    QTest::qWait(60);
    expect(phase() == reducedPhase, "reduced motion does not animate sparkle phase");
    window.setProperty("reducedMotion", false);
    QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, reducedPressPoint);
    settle();
    expect(base() <= 0.1001, "leaving reduced motion during press cannot leave the pressed layer stuck after release");

    if (!delegate->property("reduceMotion").toBool()) {
        const auto count = clicked.count();
        QTest::mousePress(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        QTest::qWait(40);
        QTest::mouseRelease(&window, Qt::LeftButton, Qt::NoModifier, pressPoint);
        window.setProperty("reducedMotion", true);
        expect(settled() && opacity() == 0 && clicked.count() == count + 1,
               "mid-release reduced motion clears the tail without duplicating the native click");
        const auto phaseAfterPreference = phase();
        QTest::qWait(60);
        expect(phase() == phaseAfterPreference, "mid-release preference change stops noise");
        window.setProperty("reducedMotion", false);
    }

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
    expect(button->property("leftPadding").toReal() == 24
               && button->property("rightPadding").toReal() == 24,
           "Small uses the reference 24 px leading and trailing padding");
    expect(button->property("spacing").toReal() == 8, "Small uses the reference 8 px content gap");
    const auto expectedWidth = qMax<qreal>(64, button->property("implicitContentWidth").toReal() + 48);
    expect(qAbs(button->implicitWidth() - expectedWidth) < 0.01 && button->width() + 0.01 >= expectedWidth,
           "Small intrinsic width reserves both reference text insets without a fixed label width");
    auto font = button->property("font").value<QFont>();
    qInfo() << "Resolved label font:" << font << "tracking:" << font.letterSpacing();
    expect(font.pixelSize() == 14 && font.weight() == QFont::Medium, "Label Large size and weight");
    expect(font.family() == QGuiApplication::font().family(), "empty theme font input inherits the application family");
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
    if (auto *delegate = button->findChild<QQuickItem *>("material3.small.background")) {
        const bool feedbackSettled = QTest::qWaitFor([delegate] {
            return !delegate->property("rippleRunning").toBool()
                && !delegate->property("rippleVisible").toBool();
        }, 1500);
        if (!feedbackSettled)
            logFeedbackState(button, delegate, "Theme measurement transient did not settle:");
        expect(feedbackSettled, "theme color measurement waits for transient feedback to settle");
    }
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
