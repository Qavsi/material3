#include "menu-motion-checks.h"

#include <QGuiApplication>
#include <QFont>
#include <QFontInfo>
#include <QtMath>
#include <QImage>
#include <QQmlApplicationEngine>
#include <QQmlProperty>
#include <QQmlComponent>
#include <QQmlContext>
#include <memory>
#include <vector>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSignalSpy>
#include <QStringList>
#include <QSGRendererInterface>
#include <QSurfaceFormat>
#include <QTest>
#include <QTimer>
#include <QVector4D>

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
    for (auto *child : parent->childItems())
        if (auto *found = findItem(child, name))
            return found;
    return nullptr;
}
int countNamedItems(QQuickItem *parent, const QString &prefix)
{
    int count = 0;
    for (auto *child : parent->childItems()) {
        count += child->objectName().startsWith(prefix) ? 1 : 0;
        count += countNamedItems(child, prefix);
    }
    return count;
}
QQuickItem *item(QQuickWindow &window, const QString &name)
{
    auto *result = findItem(window.contentItem(), name);
    expect(result != nullptr, qPrintable(name + " exists"));
    return result;
}
QObject *backgroundStyle(QQuickItem *control)
{
    auto *background = control->property("background").value<QObject *>();
    return background ? background->property("backgroundStyle").value<QObject *>() : nullptr;
}
QColor container(QQuickItem *control)
{
    auto *style = backgroundStyle(control);
    return style ? style->property("color").value<QColor>() : QColor();
}
QColor contentInk(QQuickItem *control)
{
    auto *content = control->property("contentItem").value<QQuickItem *>();
    return content ? content->property("color").value<QColor>() : QColor();
}
// Golden geometry from pinned QmlMaterial 229bc3e; do not derive expectations from kit tokens.
struct CommonGeometry {
    const char *name;
    int height;
    int padding;
    int spacing;
    int iconSize;
    int pressedRadius;
};
constexpr CommonGeometry commonGeometries[] = {
    {"XS", 32, 16, 8, 18, 8}, {"S", 40, 24, 8, 18, 8},
    {"M", 48, 24, 8, 24, 12}, {"L", 56, 32, 12, 24, 16}, {"XL", 72, 32, 12, 32, 16}
};
struct IconGeometry {
    int opticalSize;
    int nativeSize;
    int inset;
    int iconSize;
    int checkedRadius;
    int pressedRadius;
};
constexpr IconGeometry iconGeometries[] = {
    {30, 40, 5, 22, 12, 8}, {40, 48, 4, 24, 12, 8}, {56, 64, 4, 24, 16, 12},
    {96, 104, 4, 32, 28, 16}, {136, 144, 4, 40, 28, 16}
};
struct FabGeometry {
    const char *name;
    int height;
    int radius;
    int iconSize;
    int leadingPadding;
};
constexpr FabGeometry fabGeometries[] = {
    {"small", 40, 4, 24, 0}, {"normal", 56, 16, 24, 0}, {"large", 96, 28, 36, 0},
    {"extended", 56, 16, 24, 16}, {"text", 56, 16, 24, 20}
};
bool paintedCornersMatch(QQuickItem *plate, qreal radius)
{
    if (!plate)
        return false;
    for (const auto *corner : {"radius", "topLeftRadius", "topRightRadius", "bottomLeftRadius", "bottomRightRadius"})
        if (qAbs(plate->property(corner).toReal() - radius) > 0.01)
            return false;
    return true;
}
QQuickItem *textLabel(QQuickItem *content)
{
    if (content) {
        if (auto *label = findItem(content, QStringLiteral("material3.button.label")))
            return label;
    }
    if (!content)
        return nullptr;
    if (content->property("text").isValid() && content->property("truncated").isValid())
        return content;
    for (auto *child : content->childItems())
        if (auto *label = textLabel(child))
            return label;
    return nullptr;
}
template <typename Predicate>
bool waitForProbe(QQuickItem *control, Predicate predicate, const char *phase)
{
    const bool ready = QTest::qWaitFor(predicate, 2000);
    if (!ready) {
        auto *plate = control->findChild<QQuickItem *>("material3.small.background");
        auto *label = textLabel(control->property("contentItem").value<QQuickItem *>());
        qWarning() << "PROBE STATE" << phase << control->objectName()
                   << "native" << QSizeF(control->width(), control->height())
                   << "implicit" << QSizeF(control->implicitWidth(), control->implicitHeight())
                   << "plate" << (plate ? QSizeF(plate->width(), plate->height()) : QSizeF())
                   << "corners" << (plate ? plate->property("topLeftRadius") : QVariant())
                   << (plate ? plate->property("topRightRadius") : QVariant())
                   << (plate ? plate->property("bottomLeftRadius") : QVariant())
                   << (plate ? plate->property("bottomRightRadius") : QVariant())
                   << "label" << (label ? QSizeF(label->width(), label->height()) : QSizeF())
                   << "natural label" << (label ? label->implicitWidth() : 0)
                   << "truncated" << (label ? label->property("truncated") : QVariant());
    }
    return ready;
}
void expectIntrinsicWidth(QQuickItem *button, qreal horizontalPadding)
{
    const qreal expected = qMax<qreal>(64, button->property("implicitContentWidth").toReal() + horizontalPadding);
    expect(qAbs(button->implicitWidth() - expected) < 0.01 && button->width() + 0.01 >= expected,
           qPrintable(button->objectName() + " intrinsic width includes both reference content insets"));
}
void reveal(QQuickItem *control)
{
    for (auto *ancestor = control->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
        auto *content = ancestor->property("contentItem").value<QQuickItem *>();
        if (!content || !ancestor->property("contentY").isValid())
            continue;
        const auto point = control->mapToItem(content, QPointF());
        const qreal maxY = qMax<qreal>(0, ancestor->property("contentHeight").toReal() - ancestor->height());
        ancestor->setProperty("contentY", qBound<qreal>(0, point.y() - 10, maxY));
        const qreal maxX = qMax<qreal>(0, ancestor->property("contentWidth").toReal() - ancestor->width());
        ancestor->setProperty("contentX", qBound<qreal>(0, point.x() - 10, maxX));
    }
    QTest::qWait(25);
}

QQuickItem *elevationItem(QQuickItem *control)
{
    return findItem(control, QStringLiteral("material3.elevation"));
}


void checkGalleryFabShadows(QQuickWindow &window, bool hardware)
{
    auto *small = findItem(window.contentItem(), QStringLiteral("comparison.fab.small"));
    expect(small, "the real gallery Small FAB exists before any Theme replacement");
    if (!small)
        return;
    const QVariant originalDark = window.property("darkMode");
    const QVariant originalMotion = window.property("reducedMotion");
    struct ScrollPosition { QQuickItem *item; QPointF position; };
    std::vector<ScrollPosition> scrollPositions;
    for (auto *ancestor = small->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
        if (ancestor->property("contentY").isValid())
            scrollPositions.push_back({ancestor, QPointF(ancestor->property("contentX").toReal(),
                ancestor->property("contentY").toReal())});
    }
    const auto inspect = [&](QQuickItem *button, const QString &name, bool checkPixels) {
        if (!button)
            return;
        // Offscreen defaults to no hover. Opt these existing native controls in for
        // the pointer probe, then RESET restores their inherited platform policy.
        QQmlProperty hoverProperty(button, QStringLiteral("hoverEnabled"));
        const bool originalHover = hoverProperty.read().toBool();
        if (!originalHover)
            expect(hoverProperty.write(true), qPrintable(name + " test enables native hover delivery"));
        reveal(button);
        QTest::mouseMove(&window, QPoint(2, 2));
        const auto settle = [&](qreal level, const char *state) {
            const bool ready = QTest::qWaitFor([&] {
                window.update();
                auto *shadow = elevationItem(button);
                if (!hardware)
                    return !findItem(button, "material3.shadow") && !findItem(button, "material3.shadow.blur")
                        && (!shadow || (shadow->property("rendererName").toString() == "none"
                            && qAbs(shadow->property("targetElevation").toReal() - level) < 0.01));
                return shadow && shadow->property("rendererName").toString() == "analytic"
                    && qAbs(shadow->property("targetElevation").toReal() - level) < 0.01
                    && qAbs(shadow->property("elevation").toReal() - level) < 0.01
                    && !shadow->property("animationRunning").toBool()
                    && findItem(shadow, "material3.shadow");
            }, 5000);
            if (!ready) {
                auto *shadow = elevationItem(button);
                auto *owner = shadow ? shadow->property("control").value<QObject *>() : nullptr;
                qInfo() << "GALLERY ELEVATION FAILURE" << name << state
                        << "hovered" << button->property("hovered") << "down" << button->property("down")
                        << "owner" << (owner ? owner->objectName() : QString())
                        << "target" << (shadow ? shadow->property("targetElevation") : QVariant())
                        << "elevation" << (shadow ? shadow->property("elevation") : QVariant())
                        << "animation" << (shadow ? shadow->property("animationRunning") : QVariant())
                        << "renderer" << (shadow ? shadow->property("rendererName") : QVariant());
            }
            expect(ready, qPrintable(name + " real gallery " + QLatin1String(state)
                + (hardware ? QStringLiteral(" reaches the QCM elevation")
                            : QStringLiteral(" keeps the software no-shadow path"))));
            return ready;
        };
        const bool idleReady = settle(6, "idle");
        auto *shadow = elevationItem(button);
        auto *resolved = backgroundStyle(button);
        auto *shadowStyle = resolved ? resolved->property("shadow").value<QObject *>() : nullptr;
        auto *parameters = shadow ? shadow->property("parameters").value<QObject *>()
            : resolved ? resolved->property("data").value<QObject *>() : nullptr;
        auto *plate = findItem(button, QStringLiteral("material3.small.background"));
        expect(parameters && parameters->property("contentRole").toString() == "fab",
               qPrintable(name + " preserves FAB metadata in the real precreated reader"));
        expect(shadowStyle && shadowStyle->property("visible").toBool(),
               qPrintable(name + " resolved native shadow slot is enabled"));
        if (shadow && plate && hardware) {
            const auto body = plate->mapRectToScene(plate->boundingRect());
            const auto haloCaster = shadow->mapRectToScene(shadow->boundingRect());
            expect(qAbs(body.x() - haloCaster.x()) < 0.01 && qAbs(body.y() - haloCaster.y()) < 0.01
                       && qAbs(body.width() - haloCaster.width()) < 0.01
                       && qAbs(body.height() - haloCaster.height()) < 0.01,
                   qPrintable(name + " real shadow and painted caster share geometry"));
        }
        qreal inheritedOpacity = 1;
        QStringList clips;
        QColor surface;
        for (auto *ancestor = button; ancestor; ancestor = ancestor->parentItem()) {
            inheritedOpacity *= ancestor->opacity();
            if (ancestor->clip())
                clips.append(QString::fromLatin1(ancestor->metaObject()->className()));
            if (ancestor != button && !surface.isValid()) {
                const auto candidate = ancestor->property("color");
                if (candidate.isValid() && candidate.canConvert<QColor>())
                    surface = candidate.value<QColor>();
            }
        }
        qInfo() << "GALLERY FAB SHADOW" << name << "hardware" << hardware << "idleReady" << idleReady
                << "role" << (parameters ? parameters->property("contentRole") : QVariant())
                << "floatingSurface" << (shadow ? shadow->property("floatingSurface") : QVariant())
                << "target" << (shadow ? shadow->property("targetElevation") : QVariant())
                << "elevation" << (shadow ? shadow->property("elevation") : QVariant())
                << "renderer" << (shadow ? shadow->property("rendererName") : QVariant())
                << "feedback" << (shadow ? shadow->property("feedbackEnabled") : QVariant())
                << "shadowColor" << (shadowStyle ? shadowStyle->property("color") : QVariant())
                << "shadowOpacity" << (shadowStyle ? shadowStyle->property("opacity") : QVariant())
                << "delegateOpacity" << (resolved ? resolved->property("opacity") : QVariant())
                << "inheritedOpacity" << inheritedOpacity << "clipAncestors" << clips << "surface" << surface;

        // Small FAB and menu-trigger lower halos are clear of neighboring controls.
        // Inspect real frames without hiding controls or replacing their bindings.
        if (checkPixels && hardware && idleReady && plate && surface.isValid()) {
            const QImage image = window.grabWindow();
            int sampled = 0, darkened = 0, clipped = 0;
            int maximumDarkening = 0;
            if (!image.isNull()) {
                for (int y = 1; y <= 12; ++y) {
                    for (int x = 6; x < plate->width() - 6; ++x) {
                        const QPointF local(x, plate->height() + y);
                        bool insideClips = true;
                        for (auto *ancestor = plate->parentItem(); ancestor; ancestor = ancestor->parentItem()) {
                            if (ancestor->clip() && !ancestor->boundingRect().contains(plate->mapToItem(ancestor, local))) {
                                insideClips = false;
                                break;
                            }
                        }
                        if (!insideClips) {
                            ++clipped;
                            continue;
                        }
                        const QPoint pixel = (plate->mapToScene(local) * image.devicePixelRatio()).toPoint();
                        if (!image.rect().contains(pixel))
                            continue;
                        const QColor actual = image.pixelColor(pixel);
                        const int difference = surface.red() + surface.green() + surface.blue()
                            - actual.red() - actual.green() - actual.blue();
                        maximumDarkening = qMax(maximumDarkening, difference);
                        darkened += difference >= 3;
                        ++sampled;
                    }
                }
            }
            qInfo() << "GALLERY FAB HALO" << name << "samples" << sampled << "darkened" << darkened
                    << "maxRgbDarkening" << maximumDarkening << "clipped" << clipped << "surface" << surface;
            expect(!image.isNull() && sampled > 0 && clipped == 0,
                   qPrintable(name + " lower halo is on-screen and survives ancestor clipping"));
            expect(darkened > 0, qPrintable(name + " paints actual shadow pixels against its card surface"));
        }
        const QPoint center = button->mapToScene(QPointF(button->width() / 2, button->height() / 2)).toPoint();
        QTest::mouseMove(&window, center);
        const bool receivesHover = QTest::qWaitFor([&] { return button->property("hovered").toBool(); }, 1000);
        if (!receivesHover)
            qInfo() << "GALLERY FAB HOVER" << name << "hoverEnabled" << hoverProperty.read()
                    << "center" << center << "window" << window.size() << "control" << button->size()
                    << "visible" << button->isVisible() << "enabled" << button->isEnabled();
        expect(receivesHover, qPrintable(name + " real control receives hover"));
        settle(8, "hover");
        QTest::mouseMove(&window, QPoint(2, 2));
        expect(QTest::qWaitFor([&] { return !button->property("hovered").toBool(); }, 1000),
               "gallery FAB hover leaves after pointer exit");
        settle(6, "pointer exit");
        if (!originalHover)
            expect(hoverProperty.reset() && hoverProperty.read().toBool() == originalHover,
                   qPrintable(name + " test restores the inherited native hover policy"));
    };
    for (const auto &geometry : fabGeometries) {
        const QString name = QStringLiteral("comparison.fab.") + QLatin1String(geometry.name);
        auto *button = findItem(window.contentItem(), name);
        expect(button, qPrintable(name + " real gallery control exists"));
        inspect(button, name, button == small);
    }
    struct Trigger { QQuickItem *button; bool checked; QString name; };
    std::vector<Trigger> triggers;
    for (const auto *key : {"short", "long"}) {
        const auto name = QStringLiteral("comparison.fabmenu.") + QLatin1String(key) + QStringLiteral(".trigger");
        auto *button = findItem(window.contentItem(), name);
        expect(button, qPrintable(name + " real menu trigger exists"));
        if (button)
            triggers.push_back({button, button->property("checked").toBool(), name});
    }
    const auto setExpanded = [&](const Trigger &trigger, bool expanded) {
        if (trigger.button->property("checked").toBool() == expanded)
            return;
        reveal(trigger.button);
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
            trigger.button->mapToScene(QPointF(trigger.button->width() / 2, trigger.button->height() / 2)).toPoint());
        expect(QTest::qWaitFor([&] { return trigger.button->property("checked").toBool() == expanded; }, 1000),
               qPrintable(trigger.name + " native click changes its expanded state"));
    };
    for (bool dark : {false, true}) {
        window.setProperty("darkMode", dark);
        for (bool reduced : {false, true}) {
            window.setProperty("reducedMotion", reduced);
            for (const auto &trigger : triggers) {
                for (bool expanded : {false, true}) {
                    setExpanded(trigger, expanded);
                    const auto scenario = trigger.name + (dark ? " dark" : " light")
                        + (reduced ? " reduced" : " full") + (expanded ? " expanded" : " collapsed");
                    inspect(trigger.button, scenario, true);
                }
                setExpanded(trigger, trigger.checked);
            }
        }
    }
    window.setProperty("darkMode", originalDark);
    window.setProperty("reducedMotion", originalMotion);
    for (const auto &trigger : triggers)
        setExpanded(trigger, trigger.checked);
    for (const auto &scroll : scrollPositions) {
        scroll.item->setProperty("contentX", scroll.position.x());
        scroll.item->setProperty("contentY", scroll.position.y());
    }
    QTest::qWait(25);
}

void checkSplitMenus(QQuickWindow &window, bool hardware)
{
    auto *trigger = item(window, "comparison.split.filled.menuButton");
    auto *menu = trigger && qmlContext(trigger) ? qmlContext(trigger)->objectForName("menu") : nullptr;
    auto *style = window.property("materialStyle").value<QObject *>();
    expect(menu && trigger && style, "real split menu and native trigger exist");
    if (!menu || !trigger || !style)
        return;
    const bool oldDark = window.property("darkMode").toBool();
    const bool oldMotion = window.property("reducedMotion").toBool();
    for (bool dark : {false, true}) {
        window.setProperty("darkMode", dark);
        for (bool reduced : {true, false}) {
            window.setProperty("reducedMotion", reduced);
            reveal(trigger);
            QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
                             trigger->mapToScene(QPointF(trigger->width() / 2, trigger->height() / 2)).toPoint());
            expect(QTest::qWaitFor([&] { return menu->property("visible").toBool(); }, 1000),
                   "split arrow opens the native menu by pointer");
            auto *tokens = style->property("tokens").value<QObject *>();
            auto *background = menu->property("background").value<QQuickItem *>();
            auto *data = background ? background->property("backgroundStyle").value<QObject *>() : nullptr;
            expect(tokens && data && data->property("color").value<QColor>() == tokens->property("surfaceContainer").value<QColor>(),
                   "menu surface follows the selected QCM surfaceContainer role");
            expect(QTest::qWaitFor([&] { return data && data->property("radius").toReal() == 4
                   && menu->property("width").toReal() == 200
                   && menu->property("height").toReal() == 112
                   && menu->property("topPadding").toReal() == 8
                   && menu->property("bottomPadding").toReal() == 8; }, 1000),
                   "menu preserves independent QCM 200x112 geometry, 4px corners and 8px vertical padding");
            expect(menu->property("modal").toBool() && !menu->property("dim").toBool()
                   && menu->property("currentIndex").toInt() == -1,
                   "pointer-open menu blocks background input without dimming or selecting a row");
            QQuickItem *rows[2]{};
            for (int index = 0; index < 2; ++index) {
                expect(QMetaObject::invokeMethod(menu, "itemAt", Q_RETURN_ARG(QQuickItem *, rows[index]), Q_ARG(int, index)),
                       "native Menu.itemAt resolves each real entry");
                auto *row = rows[index];
                expect(QTest::qWaitFor([&] { return row && row->height() == 48 && row->width() == menu->property("availableWidth").toReal()
                       && row->property("leftPadding").toReal() == 16 && row->property("rightPadding").toReal() == 16; }, 1000),
                       "first and last row fill the popup width with QCM 48px height and 16px text insets");
                const auto font = row ? row->property("font").value<QFont>() : QFont();
                expect(row && font.pixelSize() == 14 && font.weight() == QFont::Medium
                       && qAbs(font.letterSpacing() - 0.1) < 0.02 && contentInk(row) == tokens->property("surfaceForeground").value<QColor>(),
                       "menu rows use LabelLarge typography and theme-correct onSurface ink");
            }
            if (background) {
                expect(QTest::qWaitFor([&] {
                    auto *shadow = elevationItem(background);
                    return shadow && shadow->property("targetElevation").toReal() == 3
                        && (!hardware || shadow->property("elevation").toReal() == 3);
                }, 1000), "menu shadow uses QCM elevation level2=3");
                auto *shadow = elevationItem(background);
                expect(shadow && (!reduced || !shadow->property("animationRunning").toBool())
                       && (hardware || (!findItem(background, "material3.shadow") && !findItem(background, "material3.shadow.blur"))),
                       "menu shadow respects reduced motion and software creates no GPU renderer");
            }
            QTest::keyClick(&window, Qt::Key_Down);
            expect(QTest::qWaitFor([&] { return menu->property("currentIndex").toInt() == 0; }, 1000),
                   "Down highlights the first menu row");
            if (rows[0]) {
                QSignalSpy triggered(rows[0], SIGNAL(triggered()));
                QTest::keyClick(&window, Qt::Key_Return);
                expect(QTest::qWaitFor([&] { return !menu->property("visible").toBool(); }, 1000)
                       && triggered.size() == 1, "Enter activates the highlighted action once and closes the menu");
            }
            QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
                             trigger->mapToScene(QPointF(trigger->width() / 2, trigger->height() / 2)).toPoint());
            expect(QTest::qWaitFor([&] { return menu->property("visible").toBool(); }, 1000), "menu reopens after activation");
            QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier,
                             trigger->mapToScene(QPointF(trigger->width() / 2, trigger->height() / 2)).toPoint());
            expect(QTest::qWaitFor([&] { return !menu->property("visible").toBool(); }, 1000), "clicking the split arrow again dismisses its menu");
            QMetaObject::invokeMethod(menu, "open");
            QTest::keyClick(&window, Qt::Key_Escape);
            expect(QTest::qWaitFor([&] { return !menu->property("visible").toBool(); }, 1000), "Escape dismisses the menu");
        }
    }
    window.setProperty("darkMode", oldDark);
    window.setProperty("reducedMotion", oldMotion);
}

void checkUnequalElevationContract(QQmlApplicationEngine &engine, QQuickWindow &window, QObject *style, bool capturePixels)
{
    const bool hardware = capturePixels;
    QQmlComponent hostComponent(&engine);
    hostComponent.setData("import QtQuick; Item { x: 16; y: 96; width: 320; height: 240; z: 10000; "
        "property color testSurface; Rectangle { anchors.fill: parent; color: parent.testSurface } "
        "Item { objectName: \"check.blur.opacityHost\"; x: 64; y: 48; width: 96; height: 64 } }", QUrl());
    auto *tokens = style->property("tokens").value<QObject *>();
    std::unique_ptr<QObject> host(hostComponent.createWithInitialProperties({
        {"parent", QVariant::fromValue(window.contentItem())},
        {"testSurface", tokens->property("surface")}
    }));
    auto *hostItem = qobject_cast<QQuickItem *>(host.get());
    auto *opacityHost = hostItem ? findItem(hostItem, "check.blur.opacityHost") : nullptr;
    expect(opacityHost, "isolated unequal-corner shadow host creates");
    if (!opacityHost)
        return;
    QQmlComponent component(&engine, QUrl("qrc:/qt/qml/Qavsi/Material3/Style/Material3Elevation.qml"));
    std::unique_ptr<QObject> elevation(component.createWithInitialProperties({
        {"parent", QVariant::fromValue(opacityHost)}, {"width", 96}, {"height", 64},
        {"tokens", QVariant::fromValue(tokens)}, {"reducedMotion", true},
        {"color", QColor(Qt::black)}, {"cornerRadii", QVariant::fromValue(QVector4D(16, 16, 16, 16))},
        {"targetElevation", 6}
    }));
    auto *adapter = qobject_cast<QQuickItem *>(elevation.get());
    expect(adapter, "private elevation adapter loads directly without a public API or native reader");
    if (!adapter) {
        qCritical() << component.errors();
        return;
    }
    expect(QTest::qWaitFor([&] {
        return adapter->property("rendererName").toString() == (hardware ? "analytic" : "none");
    }, 1000), "uniform corners select the analytic hardware path or the software no-shadow path");
    const QVector4D unequal(3, 9, 17, 27); // TL, TR, BL, BR; all distinct and below half-height.
    adapter->setProperty("cornerRadii", QVariant::fromValue(unequal));
    const auto blur = [&] { return findItem(adapter, "material3.shadow.blur"); };
    const auto ready = [&](const char *message) {
        expect(QTest::qWaitFor([&] {
            auto *renderer = blur();
            return hardware ? adapter->property("rendererName").toString() == "blur" && renderer
                    && renderer->property("cornerRadii").value<QVector4D>() == unequal
                : adapter->property("rendererName").toString() == "none" && !renderer
                    && !findItem(adapter, "material3.shadow");
        }, 1000), message);
    };
    ready("unequal corners select BlurMask with the exact TL/TR/BL/BR order, never a GPU item in software");
    if (hardware) {
        auto *renderer = blur();
        expect(renderer && qAbs(renderer->property("sigma").toReal() - 7.2) < 0.01
                   && qAbs(renderer->property("color").value<QColor>().alphaF() - 0.35) < 0.01,
               "unequal elevation 6 preserves the independent QCM sigma 7.2 and outer-mask alpha 0.35");
    }
    if (capturePixels) {
        adapter->setProperty("targetElevation", 0);
        expect(QTest::qWaitFor([&] { return !blur() && adapter->property("rendererName").toString() == "none"; }, 1000),
               "zero elevation releases the BlurMask renderer");
        const QImage clear = window.grabWindow();
        adapter->setProperty("targetElevation", 6);
        ready("positive elevation recreates the unequal-corner renderer");
        const QImage opaque = window.grabWindow();
        opacityHost->setOpacity(0.5);
        const QImage faded = window.grabWindow();
        expect(!clear.isNull() && clear.size() == opaque.size() && clear.size() == faded.size(),
               "BlurMask renders measurable GPU pixels");
        qint64 opaqueInk = 0;
        qint64 fadedInk = 0;
        if (!clear.isNull() && clear.size() == opaque.size() && clear.size() == faded.size()) {
            const auto center = adapter->mapToScene(QPointF(adapter->width() / 2, adapter->height() / 2))
                * clear.devicePixelRatio();
            expect(opaque.pixelColor(center.toPoint()) == clear.pixelColor(center.toPoint()),
                   "Outer BlurMask leaves the unoccluded caster interior completely clear");
            for (int y = 1; y <= 16; ++y) {
                for (int x = 12; x < adapter->width() - 12; ++x) {
                    const auto point = adapter->mapToScene(QPointF(x, adapter->height() + y)) * clear.devicePixelRatio();
                    const QPoint pixel(qRound(point.x()), qRound(point.y()));
                    const auto background = clear.pixelColor(pixel);
                    const auto full = opaque.pixelColor(pixel);
                    const auto half = faded.pixelColor(pixel);
                    const int difference = background.red() + background.green() + background.blue()
                        - full.red() - full.green() - full.blue();
                    if (difference >= 6) {
                        opaqueInk += difference;
                        fadedInk += background.red() + background.green() + background.blue()
                            - half.red() - half.green() - half.blue();
                    }
                }
            }
        }
        expect(opaqueInk > 0, "Outer BlurMask paints a visible shadow outside the caster");
        const double ratio = opaqueInk > 0 ? double(fadedInk) / opaqueInk : 0;
        expect(ratio > 0.35 && ratio < 0.65, "BlurMask preserves linear inherited opacity from its parent");
        opacityHost->setOpacity(1);
    }
    adapter->setWidth(112);
    adapter->setHeight(72);
    ready("resizing preserves the unequal-corner renderer and corner order");
    const QColor changedColor(64, 128, 192, 160);
    adapter->setProperty("color", changedColor);
    if (hardware) {
        expect(QTest::qWaitFor([&] {
            auto *renderer = blur();
            const auto color = renderer ? renderer->property("color").value<QColor>() : QColor();
            return renderer && renderer->size() == QSizeF(112, 72)
                && color.red() == changedColor.red() && color.green() == changedColor.green()
                && color.blue() == changedColor.blue()
                && qAbs(color.alphaF() - changedColor.alphaF() * 0.35) < 0.01;
        }, 1000), "BlurMask updates dimensions and caller color including alpha");
    }
    if (hardware)
        adapter->setProperty("reducedMotion", false);
    adapter->setProperty("targetElevation", 8);
    if (hardware) {
        expect(QTest::qWaitFor([&] { return adapter->property("animationRunning").toBool(); }, 200),
               "unequal-corner elevation starts a normal-motion transition");
    }
    adapter->setProperty("reducedMotion", true);
    expect(QTest::qWaitFor([&] {
        return adapter->property("elevation").toReal() == 8
            && !adapter->property("animationRunning").toBool();
    }, 1000), "reduced motion completes the active unequal-corner elevation transition");
    if (hardware) {
        expect(blur() && qAbs(blur()->property("sigma").toReal() - 9.6) < 0.01,
               "raised unequal elevation 8 updates the independent QCM sigma to 9.6");
    }
    adapter->setProperty("cornerRadii", QVariant::fromValue(QVector4D(16, 16, 16, 16)));
    expect(QTest::qWaitFor([&] {
        return !blur() && adapter->property("rendererName").toString() == (hardware ? "analytic" : "none");
    }, 1000), "returning to uniform corners releases BlurMask and restores the analytic path");
    adapter->setProperty("cornerRadii", QVariant::fromValue(unequal));
    ready("live uniform-to-unequal switching recreates the correct renderer");
    opacityHost->setVisible(false);
    expect(QTest::qWaitFor([&] {
        return adapter->property("rendererName").toString() == "none"
            && !blur() && !findItem(adapter, "material3.shadow");
    }, 1000), "hiding an ancestor releases both elevation renderers");
}

void checkElevationContract(QQmlApplicationEngine &engine, QQuickWindow &window, QObject *style, bool capturePixels)
{
    const bool hardware = capturePixels;
    const QVariant originalMotion = window.property("reducedMotion");
    const QVariant originalDark = window.property("darkMode");
    const char *roles[] = {"elevated", "fab"};
    std::vector<std::unique_ptr<QObject>> fixtures;
    std::vector<std::unique_ptr<QObject>> singleShadowReferences;
    QQmlComponent referenceComponent(&engine,
        QUrl("qrc:/qt/qml/Qavsi/Material3/Style/Material3Elevation.qml"));
    // Qt 6.12 lost late-created FAB metadata after Theme replacement in this fixture.
    // Initialize both native readers first to isolate the rendering contract.
    for (const auto *role : roles) {
        const bool fab = QByteArray(role) == "fab";
        QQmlComponent component(&engine);
        component.setData("import QtQuick; import Qt.labs.StyleKit as SK; "
            "Item { id: fixture; x: 16; y: 96; width: 320; height: 190; z: 10000; "
            "property real requestedWidth: " + QByteArray(fab ? "56" : "96") + "; "
            "property real requestedOpacity: 1; property bool requestedEnabled: true; "
            "property color testSurface; Rectangle { anchors.fill: parent; color: fixture.testSurface } "
            "SK.Button { objectName: \"check.elevation.probe\"; x: 48; y: 48; text: \"Shadow\"; "
            "width: fixture.requestedWidth; opacity: fixture.requestedOpacity; "
            "enabled: fixture.requestedEnabled; hoverEnabled: true; "
            "SK.StyleVariation.variations: [\"" + QByteArray(role) + "\"] } }", QUrl());
        auto *currentTokens = style->property("tokens").value<QObject *>();
        fixtures.emplace_back(component.createWithInitialProperties({
            {"parent", QVariant::fromValue(window.contentItem())},
            {"visible", false}, {"testSurface", currentTokens->property("surface")}
        }));
        auto *host = qobject_cast<QQuickItem *>(fixtures.back().get());
        auto *probe = host ? findItem(host, "check.elevation.probe") : nullptr;
        expect(probe, "isolated native shadow probe creates without a control wrapper");
        if (!probe) {
            qCritical() << component.errors();
            singleShadowReferences.emplace_back(nullptr);
            continue;
        }
        singleShadowReferences.emplace_back(referenceComponent.createWithInitialProperties({
            {"parent", QVariant::fromValue(host)}, {"visible", false}, {"width", 1}, {"height", 1},
            {"tokens", QVariant::fromValue(currentTokens)}, {"reducedMotion", true},
            {"color", QColor(Qt::black)}, {"cornerRadii", QVariant::fromValue(QVector4D())},
            {"targetElevation", 0}
        }));
        expect(qobject_cast<QQuickItem *>(singleShadowReferences.back().get()),
               "single-shadow reference creates independently of the native composition");
        if (!singleShadowReferences.back())
            qCritical() << referenceComponent.errors();
        // Test-only preparation for Qt 6.12's late-reader font initialization.
        host->setProperty("requestedEnabled", false);
        host->setProperty("requestedEnabled", true);
    }
    for (size_t index = 0; index < fixtures.size(); ++index) {
        auto *host = qobject_cast<QQuickItem *>(fixtures[index].get());
        auto *probe = host ? findItem(host, "check.elevation.probe") : nullptr;
        if (!probe)
            continue;
        const char *role = roles[index];
        const bool fab = QByteArray(role) == "fab";
        const qreal base = fab ? 6 : 1;
        const qreal hovered = fab ? 8 : 3;
        host->setVisible(true);
        auto *plate = findItem(probe, "material3.small.background");
        expect(plate, "native control retains its independent background delegate");
        if (!plate)
            continue;
        const auto settle = [&](qreal expected, const char *message) {
            const bool ready = QTest::qWaitFor([&] {
                auto *shadow = elevationItem(probe);
                const bool gpuChildrenAbsent = !findItem(probe, "material3.shadow")
                    && !findItem(probe, "material3.shadow.blur");
                if (!hardware)
                    return gpuChildrenAbsent && (!shadow || (!shadow->isVisible()
                        && qAbs(shadow->property("targetElevation").toReal() - expected) < 0.01));
                return shadow && shadow->isVisible()
                    && qAbs(shadow->property("targetElevation").toReal() - expected) < 0.01
                    && qAbs(shadow->property("elevation").toReal() - expected) < 0.01
                    && !shadow->property("animationRunning").toBool() && !gpuChildrenAbsent;
            }, 1500);
            if (!ready) {
                auto *shadow = elevationItem(probe);
                auto *delegate = shadow ? shadow->property("delegateStyle").value<QObject *>() : nullptr;
                auto *shadowStyle = delegate ? delegate->property("shadow").value<QObject *>() : nullptr;
                auto *parameters = shadow ? shadow->property("parameters").value<QObject *>() : nullptr;
                qInfo() << "ELEVATION PROBE" << role << message
                        << "expected" << expected << "target" << (shadow ? shadow->property("targetElevation") : QVariant())
                        << "feedback" << (shadow ? shadow->property("feedbackEnabled") : QVariant())
                        << "shadow.visible" << (shadowStyle ? shadowStyle->property("visible") : QVariant())
                        << "contentRole" << (parameters ? parameters->property("contentRole") : QVariant())
                        << "floating" << (shadow ? shadow->property("floatingSurface") : QVariant())
                        << "controlSize" << probe->size() << "plateSize" << plate->size()
                        << "enabled" << probe->isEnabled() << "visible" << probe->isVisible()
                        << "hovered" << probe->property("hovered") << "down" << probe->property("down")
                        << "window" << plate->window()
                        << "windowVisible" << (plate->window() && plate->window()->isVisible())
                        << "windowVisibility" << (plate->window() ? int(plate->window()->visibility()) : -1);
            }
            expect(ready, message);
        };
        QTest::mouseMove(&window, QPoint(2, 2));
        settle(base, "FAB/Elevated idle target follows the independent QCM elevation level");
        if (hardware) {
            auto *shadow = elevationItem(probe);
            expect(shadow && shadow->property("rendererName").toString() == "analytic"
                       && findItem(shadow, "material3.shadow"),
                   "uniform native controls instantiate the QCM-derived analytic renderer");
        } else {
            auto *shadow = elevationItem(probe);
            expect((!shadow || !shadow->isVisible()) && !findItem(probe, "material3.shadow")
                       && !findItem(probe, "material3.shadow.blur")
                       && plate->property("feedbackRenderer").toString() == "painter",
                   "software keeps painter feedback and no GPU shadow children even if the StyleKit wrapper remains");
        }

        if (capturePixels) {
            auto *reference = qobject_cast<QQuickItem *>(singleShadowReferences[index].get());
            auto *nativeShadow = elevationItem(probe);
            expect(reference && nativeShadow, "native composition and its single-shadow reference are available");
            if (reference && nativeShadow) {
                probe->setFocus(false, Qt::OtherFocusReason);
                const QRectF body = plate->mapRectToScene(plate->boundingRect());
                reference->setPosition(plate->mapToItem(host, QPointF()));
                reference->setSize(plate->size());
                reference->setProperty("targetElevation", base);
                reference->setProperty("color", nativeShadow->property("color"));
                reference->setProperty("cornerRadii", QVariant::fromValue(QVector4D(
                    plate->property("topLeftRadius").toReal(), plate->property("topRightRadius").toReal(),
                    plate->property("bottomLeftRadius").toReal(), plate->property("bottomRightRadius").toReal())));
                reference->setOpacity(nativeShadow->opacity());
                QQmlProperty::write(reference, "tokens", nativeShadow->property("tokens"));
                const QImage nativeImage = window.grabWindow();
                probe->setVisible(false);
                reference->setVisible(true);
                expect(QTest::qWaitFor([&] {
                    return reference->property("rendererName").toString() == "analytic"
                        && findItem(reference, "material3.shadow");
                }, 1000), "single-shadow reference renders without a native control or StyleKit container");
                const QImage referenceImage = window.grabWindow();
                int compared = 0;
                int maxChannelDifference = 255;
                if (!nativeImage.isNull() && nativeImage.size() == referenceImage.size()) {
                    maxChannelDifference = 0;
                    const qreal dpr = nativeImage.devicePixelRatio();
                    const QRect halo = QRectF(body.topLeft() * dpr, body.size() * dpr).toAlignedRect()
                        .adjusted(-qCeil(32 * dpr), -qCeil(32 * dpr), qCeil(32 * dpr), qCeil(32 * dpr))
                        .intersected(nativeImage.rect());
                    for (int y = halo.top(); y <= halo.bottom(); ++y) {
                        for (int x = halo.left(); x <= halo.right(); ++x) {
                            if (body.contains(QPointF((x + 0.5) / dpr, (y + 0.5) / dpr)))
                                continue;
                            const auto actual = nativeImage.pixelColor(x, y);
                            const auto single = referenceImage.pixelColor(x, y);
                            maxChannelDifference = qMax(maxChannelDifference, qMax(qAbs(actual.red() - single.red()),
                                qMax(qAbs(actual.green() - single.green()),
                                    qMax(qAbs(actual.blue() - single.blue()), qAbs(actual.alpha() - single.alpha())))));
                            ++compared;
                        }
                    }
                }
                qInfo() << "NATIVE SHADOW COMPOSITION" << role << "pixels" << compared
                        << "maxChannelDifference" << maxChannelDifference;
                expect(compared > 0 && maxChannelDifference <= 2,
                       "native SK.Button halo matches exactly one elevation helper, excluding a second StyleKit shadow");
                reference->setVisible(false);
                probe->setVisible(true);
                settle(base, "native shadow restores after the single-layer composition capture");
            }
        }

        host->setProperty("requestedEnabled", false);
        expect(QTest::qWaitFor([&] {
            auto *shadow = elevationItem(probe);
            return !probe->isEnabled() && !findItem(probe, "material3.shadow")
                && !findItem(probe, "material3.shadow.blur")
                && (!shadow || (!shadow->isVisible() && shadow->property("targetElevation").toReal() == 0
                    && !shadow->property("animationRunning").toBool()));
        }, 1000), "disabling the native control releases both GPU shadow children and stops its target");
        const QImage unshadowed = capturePixels ? window.grabWindow() : QImage();
        host->setProperty("requestedEnabled", true);
        settle(base, "native enabled binding restores the same shadow recipe");
        if (capturePixels) {
            const QImage opaque = window.grabWindow();
            host->setProperty("requestedOpacity", 0.5);
            QTest::qWait(30);
            const QImage half = window.grabWindow();
            expect(!opaque.isNull() && !half.isNull() && !unshadowed.isNull(),
                   "analytic shadow exposes actual GPU pixels");
            qint64 opaqueInk = 0;
            qint64 halfInk = 0;
            if (!opaque.isNull() && opaque.size() == half.size() && opaque.size() == unshadowed.size()) {
                for (int y = 1; y <= 16; ++y) {
                    for (int x = 4; x < probe->width() - 4; ++x) {
                        const auto point = probe->mapToScene(QPointF(x, probe->height() + y)) * opaque.devicePixelRatio();
                        const QPoint pixel(qRound(point.x()), qRound(point.y()));
                        const QColor clear = unshadowed.pixelColor(pixel);
                        const QColor full = opaque.pixelColor(pixel);
                        const QColor faded = half.pixelColor(pixel);
                        const int fullDifference = clear.red() + clear.green() + clear.blue()
                            - full.red() - full.green() - full.blue();
                        if (fullDifference >= 6) {
                            opaqueInk += fullDifference;
                            halfInk += clear.red() + clear.green() + clear.blue()
                                - faded.red() - faded.green() - faded.blue();
                        }
                    }
                }
            }
            expect(opaqueInk > 0, "enabled elevated controls paint a visible shadow outside their plate");
            const double ratio = opaqueInk > 0 ? double(halfInk) / opaqueInk : 0;
            expect(ratio > 0.35 && ratio < 0.65,
                   "caller opacity halves shadow coverage linearly instead of cubing it");
            host->setProperty("requestedOpacity", 1);
        }
        const auto center = probe->mapToScene(QPointF(probe->width() / 2, probe->height() / 2)).toPoint();
        QTest::mouseMove(&window, center);
        expect(probe->property("hovered").toBool(), "shadow probe receives native hover input");
        settle(hovered, "FAB/Elevated hover reaches its independent QCM elevation level");
        probe->forceActiveFocus(Qt::TabFocusReason);
        QSignalSpy clicked(probe, SIGNAL(clicked()));
        QTest::keyPress(&window, Qt::Key_Space);
        expect(probe->property("pressed").toBool() && plate->property("focusVisible").toBool(),
               "elevation keeps native keyboard press and visible focus handling");
        settle(base, "held press takes precedence over hover and restores base elevation");
        QTest::keyRelease(&window, Qt::Key_Space);
        expect(clicked.count() == 1, "shadow integration preserves one native activation per key release");
        settle(hovered, "release returns to hover elevation without changing variations");
        QTest::mouseMove(&window, QPoint(2, 2));
        settle(base, "pointer exit returns the native control to its base elevation");
        if (hardware && !style->property("effectiveReducedMotion").toBool()) {
            QTest::mouseMove(&window, center);
            expect(QTest::qWaitFor([&] {
                auto *shadow = elevationItem(probe);
                return shadow && shadow->property("animationRunning").toBool();
            }, 200), "normal motion starts the elevation transition");
        } else {
            QTest::mouseMove(&window, center);
        }
        window.setProperty("reducedMotion", true);
        settle(hovered, "reduced motion completes an active elevation transition and leaves no running animation");
        QTest::mouseMove(&window, QPoint(2, 2));
        settle(base, "reduced motion applies a new elevation target immediately");
        auto *reducedShadow = elevationItem(probe);
        expect(!hardware || (reducedShadow && !reducedShadow->property("animationRunning").toBool()),
               "reduced motion leaves the elevation animation stopped");
        window.setProperty("reducedMotion", originalMotion);

        for (bool dark : {true, false}) {
            window.setProperty("darkMode", dark);
            expect(QTest::qWaitFor([&] {
                auto *shadow = elevationItem(probe);
                auto *activeTokens = style->property("tokens").value<QObject *>();
                return !hardware || (shadow && activeTokens
                    && shadow->property("color").value<QColor>() == activeTokens->property("shadow").value<QColor>());
            }, 1000), "elevation shadow color follows the currently selected Light/Dark Theme");
        }
        window.setProperty("darkMode", originalDark);
        if (hardware && !fab) {
            const QVariant originalLightTokens = style->property("lightTokens");
            QQmlComponent themeComponent(&engine);
            themeComponent.setData("import Qavsi.Material3.Theme; Material3Theme {}", QUrl());
            std::unique_ptr<QObject> customTheme(themeComponent.createWithInitialProperties({
                {"shadow", QColor(Qt::red)}
            }));
            expect(customTheme != nullptr, "caller-provided shadow Theme creates");
            if (customTheme) {
                window.setProperty("darkMode", false);
                expect(QQmlProperty::write(style, "lightTokens", QVariant::fromValue(customTheme.get())),
                       "the style accepts caller-provided Theme shadow colors");
                expect(QTest::qWaitFor([&] {
                    auto *shadow = elevationItem(probe);
                    return shadow && shadow->property("color").value<QColor>() == QColor(Qt::red);
                }, 1000), "analytic elevation does not hard-code a black shadow instead of the caller's token");
                expect(QQmlProperty::write(style, "lightTokens", originalLightTokens),
                       "original Light Theme is restored after the shadow override probe");
                window.setProperty("darkMode", originalDark);
                expect(QTest::qWaitFor([&] {
                    auto *shadow = elevationItem(probe);
                    auto *activeTokens = style->property("tokens").value<QObject *>();
                    return shadow && activeTokens
                        && shadow->property("color").value<QColor>() == activeTokens->property("shadow").value<QColor>();
                }, 1000), "shadow bindings follow the restored Theme object");
            }
        }
        host->setProperty("requestedWidth", host->property("requestedWidth").toReal() + 20);
        expect(QTest::qWaitFor([&] {
            return qAbs(probe->width() - host->property("requestedWidth").toReal()) < 0.01
                && probe->isEnabled() && probe->opacity() == 1;
        }, 1000), "caller width, opacity, and enabled bindings remain live after elevation states and theme changes");
        host->setVisible(false);
        expect(QTest::qWaitFor([&] {
            auto *shadow = elevationItem(probe);
            return !findItem(probe, "material3.shadow") && !findItem(probe, "material3.shadow.blur")
                && (!shadow || (!shadow->isVisible() && shadow->property("targetElevation").toReal() == 0
                    && !shadow->property("animationRunning").toBool()));
        }, 1000), "hiding the control's ancestor releases both GPU shadow children and stops its target");
    }
    window.setProperty("darkMode", originalDark);
    window.setProperty("reducedMotion", originalMotion);
}
}

int checkComparison(QQmlApplicationEngine &engine, QQuickWindow &window)
{
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    expect(QTest::qWaitForWindowExposed(&window), "comparison window exposes");
    window.requestActivate();
    QTest::qWait(150);
    auto *style = window.property("materialStyle").value<QObject *>();
    auto *tokens = style ? style->property("tokens").value<QObject *>() : nullptr;
    expect(tokens, "independent Material3 tokens exist");
    if (!tokens)
        return 1;
    const auto galleryApi = window.rendererInterface()->graphicsApi();
    const bool galleryHardware = galleryApi != QSGRendererInterface::Software
        && galleryApi != QSGRendererInterface::Unknown
        && (galleryApi != QSGRendererInterface::OpenGL || window.format().majorVersion() >= 3);
    // Keep frame-driven animations advancing when the desktop comparison loses activation.
    QTimer framePump;
    framePump.setInterval(16);
    QObject::connect(&framePump, &QTimer::timeout, &window, [&] { window.update(); });
    if (galleryHardware)
        framePump.start();
    checkMenuMotion(engine, window, galleryHardware, expect);
    checkGalleryFabShadows(window, galleryHardware);
    checkSplitMenus(window, galleryHardware);

    std::vector<std::unique_ptr<QObject>> nativeCases;
    for (const auto &appearance : {"filled", "filledTonal", "outline", "ghost"}) {
        QQmlComponent component(&engine);
        const QByteArray source = "import QtQuick; import Qt.labs.StyleKit as SK; "
            "SK.Button { text: \"Native\"; visible: false; icon.color: \"transparent\"; "
            "SK.StyleVariation.variations: [\"" + QByteArray(appearance) + "\"] }";
        component.setData(source, QUrl());
        nativeCases.emplace_back(component.createWithInitialProperties(
            {{"parent", QVariant::fromValue(window.contentItem())}}));
        auto *native = qobject_cast<QQuickItem *>(nativeCases.back().get());
        expect(native, "plain native SK.Button creates without a content helper");
        if (!native)
            continue;
        QTest::qWait(25);
        auto *plate = native->findChild<QQuickItem *>("material3.small.background");
        const char *role = QByteArray(appearance) == "filledTonal" ? "secondaryContainerForeground"
            : QByteArray(appearance) == "filled" ? "primaryForeground" : "primary";
        expect(plate && plate->property("contentColor").value<QColor>() == tokens->property(role).value<QColor>(),
               "plain native button resolves interaction ink independently of transparent icon tint");
    }

    auto *commonSizes = item(window, "comparison.common.sizes");
    auto *iconSizes = item(window, "comparison.icon.sizes");
    auto *iconWidths = item(window, "comparison.icon.widths");
    auto *enabledIcons = item(window, "comparison.icon.appearances.enabled");
    auto *disabledIcons = item(window, "comparison.icon.appearances.disabled");
    expect(commonSizes && countNamedItems(commonSizes, "comparison.button.size.") == 3,
           "comparison shows only the reference XS/S/M common sizes");
    expect(iconSizes && countNamedItems(iconSizes, "comparison.iconSize.") == 4,
           "comparison shows only the reference XS/S/M/L icon sizes");
    expect(iconWidths && countNamedItems(iconWidths, "comparison.iconWidth.") == 3,
           "comparison shows the three reference narrow/default/wide icon widths");
    expect(enabledIcons && countNamedItems(enabledIcons, "comparison.iconButton.") == 4
               && disabledIcons && countNamedItems(disabledIcons, "comparison.iconButton.") == 4,
           "comparison keeps exactly four enabled and four disabled icon appearances");
    expect(!findItem(window.contentItem(), "comparison.button.size.L")
               && !findItem(window.contentItem(), "comparison.button.size.XL")
               && !findItem(window.contentItem(), "comparison.iconSize.XL"),
           "extra library sizes do not leak into the pinned comparison gallery");
    for (const auto &name : {"XS", "S", "M"}) {
        auto *sample = item(window, "comparison.button.size." + QString::fromLatin1(name));
        expect(sample && sample->isVisible(), "each reference common-size sample stays in the visible gallery");
    }
    for (const auto &name : {"XS", "S", "M", "L"}) {
        auto *sample = item(window, "comparison.iconSize." + QString::fromLatin1(name));
        expect(sample && sample->isVisible(), "each reference icon-size sample stays in the visible gallery");
    }

    // Library contracts are tested independently of the reference gallery's smaller sample set.
    std::vector<std::unique_ptr<QObject>> commonSizeCases;
    std::vector<std::unique_ptr<QObject>> iconSizeCases;
    const char *commonRoles[] = {"buttonExtraSmall", "buttonSmall", "buttonMedium", "buttonLarge", "buttonExtraLarge"};
    const char *iconRoles[] = {"iconExtraSmall", "iconSmall", "iconMedium", "iconLarge", "iconExtraLarge"};
    auto *iconSample = findItem(window.contentItem(), "comparison.iconSize.XS");
    const QVariant probeIcon = iconSample ? QQmlProperty::read(iconSample, "icon.source") : QVariant();
    const QVariant probeName = iconSample ? QQmlProperty::read(iconSample, "icon.name") : QVariant();
    expect(probeName.toString() == QStringLiteral("material:settings"), "library probes reuse the actual package icon path");
    auto createSizeCase = [&](const QString &name, const char *role, bool iconOnly, bool callerGeometry = false) {
        QQmlComponent component(&engine);
        const QByteArray source = "import QtQuick; import Qt.labs.StyleKit as SK; import Qavsi.Material3.Style; "
            "SK.Button { id: probe; property url probeIcon; property string probeName; visible: false; x: 16; y: 96; z: 1000; "
            "icon.source: probeIcon; icon.name: probeName; display: SK.Button." + QByteArray(iconOnly ? "IconOnly" : "TextBesideIcon")
            + "; SK.StyleVariation.variations: [\"" + QByteArray(role) + "\""
            + (iconOnly ? ", \"iconStandard\", \"ghost\"" : "")
            + "]; "
            + (callerGeometry ? "property real requestedWidth: 100; property real requestedHeight: 80; "
                "width: requestedWidth; height: requestedHeight; " : "")
            + "contentItem: Material3ButtonContent { control: probe } }";
        component.setData(source, QUrl());
        std::unique_ptr<QObject> probe(component.createWithInitialProperties({
            {"parent", QVariant::fromValue(window.contentItem())},
            {"objectName", "check.library." + QString(iconOnly ? "icon." : "common.") + name},
            {"text", name}, {"probeIcon", iconOnly ? probeIcon : QVariant::fromValue(QUrl())},
            {"probeName", iconOnly ? probeName : QVariant::fromValue(QString())}
        }));
        if (probe) {
            const auto initialFont = probe->property("font").value<QFont>();
            // Qt 6.12 dynamic readers miss the loaded style's initial font reset; a native state update rebuilds it.
            // Test preparation only: neither SDK/library font defaults nor consumer bindings are changed.
            probe->setProperty("enabled", false);
            probe->setProperty("enabled", true);
            if (!iconOnly && name == "S")
                qInfo() << "Dynamic StyleKit font initialization before" << initialFont
                        << "resolved px" << QFontInfo(initialFont).pixelSize()
                        << "after native state update" << probe->property("font");
        }
        expect(qobject_cast<QQuickItem *>(probe.get()), "test-only native library size probe creates with its content delegate");
        if (!probe)
            qCritical() << component.errors();
        return probe;
    };
    int roleIndex = 0;
    for (const auto &geometry : commonGeometries) {
        commonSizeCases.push_back(createSizeCase(geometry.name, commonRoles[roleIndex], false));
        iconSizeCases.push_back(createSizeCase(geometry.name, iconRoles[roleIndex], true));
        ++roleIndex;
    }
    expect(commonSizeCases.size() == 5 && iconSizeCases.size() == 5,
           "the library retains all five common and all five icon size roles outside the gallery");
    QTest::qWait(30);

    for (const auto &name : {"elevated", "filled", "filledTonal", "outlined", "text"}) {
        auto *button = item(window, "comparison.button." + QString::fromLatin1(name));
        auto *disabled = item(window, "comparison.button." + QString::fromLatin1(name) + ".disabled");
        auto *icon = item(window, "comparison.button." + QString::fromLatin1(name) + ".icon");
        if (!button || !disabled || !icon)
            continue;
        expect(container(button).isValid(), "appearance resolves a valid container");
        expect(button->height() == 40, "common button keeps the reference 40 px Small height");
        expect(button->property("leftPadding").toReal() == 24 && button->property("rightPadding").toReal() == 24,
               "each text-only common appearance uses the reference 24 px insets");
        expect(icon->property("leftPadding").toReal() == 24 && icon->property("rightPadding").toReal() == 24,
               "each icon-and-text common appearance keeps the same reference insets");
        expect(button->property("spacing").toReal() == 8 && icon->property("spacing").toReal() == 8,
               "common text and icon appearances share the reference 8 px gap");
        auto *iconContent = icon->property("contentItem").value<QQuickItem *>();
        expect(iconContent && iconContent->property("iconWidth").toReal() == 18
                   && iconContent->property("iconHeight").toReal() == 18,
               "Small common icons use the reference 18 px optical size");
        expectIntrinsicWidth(button, 48);
        expectIntrinsicWidth(icon, 48);
        expect(!disabled->isEnabled(), "disabled appearance retains native input gate");
        QSignalSpy disabledClicked(disabled, SIGNAL(clicked()));
        disabled->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(disabledClicked.isEmpty(), "disabled button cannot activate from keyboard");
        expect(!icon->property("icon").isNull(), "icon example retains native icon property");
    }
    for (const auto &name : {"comparison.button.filledTonal", "comparison.button.text", "comparison.button.size.XS"}) {
        auto *button = item(window, name);
        auto *content = button ? button->property("contentItem").value<QQuickItem *>() : nullptr;
        bool foundLabel = false;
        if (content)
            for (auto *grid : content->childItems())
                for (auto *label : grid->childItems())
                    if (label->property("text").isValid()) {
                        foundLabel = true;
                        expect(!label->property("truncated").toBool(), "unconstrained labels do not lose fractional glyph width");
                    }
        expect(foundLabel, "content delegate contains the native text label");
    }
    auto *extraLarge = qobject_cast<QQuickItem *>(commonSizeCases.back().get());
    expect(extraLarge, "XL text regression uses a test-only library probe");
    if (extraLarge)
        extraLarge->setVisible(true);
    auto *extraLargeLabel = extraLarge ? textLabel(extraLarge->property("contentItem").value<QQuickItem *>()) : nullptr;
    expect(extraLargeLabel, "XL library probe contains the native text label");
    expect(extraLargeLabel && waitForProbe(extraLarge, [extraLarge, extraLargeLabel] {
        return extraLarge->height() == 72
            && extraLarge->width() + 0.01 >= qCeil(extraLargeLabel->implicitWidth()) + 64
            && extraLargeLabel->width() + 0.01 >= qCeil(extraLargeLabel->implicitWidth())
            && !extraLargeLabel->property("truncated").toBool();
    }, "XL label layout"), "XL library text keeps its complete fractional glyph width");
    if (extraLarge)
        extraLarge->setVisible(false);
    auto *filled = item(window, "comparison.button.filled");
    auto *outlined = item(window, "comparison.button.outlined");
    auto *tonal = item(window, "comparison.button.filledTonal");
    auto *text = item(window, "comparison.button.text");
    if (!filled || !outlined || !tonal || !text)
        return 1;
    auto *filledPlate = filled->findChild<QQuickItem *>("material3.small.background");
    const auto graphicsApi = window.rendererInterface()->graphicsApi();
    const bool metal = graphicsApi == QSGRendererInterface::Metal;
    const bool hardware = graphicsApi != QSGRendererInterface::Software && graphicsApi != QSGRendererInterface::Unknown
        && (graphicsApi != QSGRendererInterface::OpenGL || window.format().majorVersion() >= 3);
    checkUnequalElevationContract(engine, window, style, hardware);
    checkElevationContract(engine, window, style, hardware);
    expect(filledPlate && filledPlate->property("feedbackRenderer").toString() == (metal ? "shader" : "painter"),
           "actual renderer selects the production shader or software painter");
    expect(filledPlate && filledPlate->property("feedbackShaderLog").toString().isEmpty(),
           "production feedback shader reports no error");
    expect(container(filled) == tokens->property("primary").value<QColor>(), "Filled uses Material3 primary");
    expect(container(tonal) == tokens->property("secondaryContainer").value<QColor>(), "Tonal uses Material3 secondary container");
    expect(container(outlined).alpha() == 0 && container(text).alpha() == 0, "Outlined and Text containers remain transparent");
    auto *outlineStyle = backgroundStyle(outlined);
    auto *border = outlineStyle ? outlineStyle->property("border").value<QObject *>() : nullptr;
    expect(border && border->property("width").toReal() > 0, "Outlined keeps its outline");
    size_t commonIndex = 0;
    for (const auto &geometry : commonGeometries) {
        auto *button = qobject_cast<QQuickItem *>(commonSizeCases[commonIndex++].get());
        if (!button)
            continue;
        button->setVisible(true);
        auto *plate = button->findChild<QQuickItem *>("material3.small.background");
        const bool layoutReady = waitForProbe(button, [button, plate, geometry] {
            auto *label = textLabel(button->property("contentItem").value<QQuickItem *>());
            return button->height() == qMax(40, geometry.height)
                && plate && plate->height() == geometry.height
                && paintedCornersMatch(plate, geometry.height / 2.0)
                && button->width() + 0.01 >= qMax<qreal>(64,
                    button->property("implicitContentWidth").toReal() + geometry.padding * 2)
                && label && label->width() + 0.01 >= qCeil(label->implicitWidth())
                && !label->property("truncated").toBool();
        }, "common idle layout");
        expect(layoutReady && button->height() == qMax(40, geometry.height), "native target preserves the 40 px desktop minimum");
        expect(plate && plate->height() == geometry.height, "painted button preserves the reference recipe height");
        expect(button->property("leftPadding").toReal() == geometry.padding
                   && button->property("rightPadding").toReal() == geometry.padding,
               "each common size preserves its reference horizontal padding");
        expect(button->property("spacing").toReal() == geometry.spacing,
               "each common size preserves its reference content gap");
        auto *content = button->property("contentItem").value<QQuickItem *>();
        expect(content && content->property("iconWidth").toReal() == geometry.iconSize
                   && content->property("iconHeight").toReal() == geometry.iconSize,
               "each common size preserves its independent reference icon size");
        const auto resolvedFont = button->property("font").value<QFont>();
        expect(resolvedFont.pixelSize() == 14,
               "common sizes preserve the reference Label Large type scale");
        expectIntrinsicWidth(button, geometry.padding * 2);
        expect(paintedCornersMatch(plate, geometry.height / 2.0), "idle common shape keeps the round reference corners");
        reveal(button);
        button->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyPress(&window, Qt::Key_Space);
        expect(button->property("pressed").toBool(), "size recipe retains the native held keyboard press");
        expect(waitForProbe(button, [plate, geometry] { return paintedCornersMatch(plate, geometry.pressedRadius); },
                            "common pressed shape"),
               "pressed common shape reaches the independent reference corner radius");
        QTest::keyRelease(&window, Qt::Key_Space);
        expect(waitForProbe(button, [plate, geometry] { return paintedCornersMatch(plate, geometry.height / 2.0); },
                            "common released shape"),
               "common shape returns to its round reference corners after release");
        button->setVisible(false);
    }
    const char *initialIconContainers[] = {nullptr, "surfaceContainerHighest", "surfaceContainerHighest", nullptr};
    const char *initialIconInks[] = {"surfaceVariantForeground", "primary", "surfaceVariantForeground", "surfaceVariantForeground"};
    const char *selectedIconContainers[] = {nullptr, "primary", "secondaryContainer", "inverseSurface"};
    const char *selectedIconInks[] = {"primary", "primaryForeground", "secondaryContainerForeground", "inverseSurfaceForeground"};
    for (int appearance = 0; appearance < 4; ++appearance) {
        auto *enabled = item(window, "comparison.iconButton." + QString::number(appearance) + ".enabled");
        auto *disabled = item(window, "comparison.iconButton." + QString::number(appearance) + ".disabled");
        if (enabled && disabled) {
            expect(enabled->property("checkable").toBool(), "icon button is natively checkable");
            expect(!disabled->isEnabled(), "disabled icon button stays disabled");
            const QColor initialContainer = initialIconContainers[appearance]
                ? tokens->property(initialIconContainers[appearance]).value<QColor>() : QColor(Qt::transparent);
            const QColor selectedContainer = selectedIconContainers[appearance]
                ? tokens->property(selectedIconContainers[appearance]).value<QColor>() : QColor(Qt::transparent);
            expect(initialContainer.isValid() && container(enabled) == initialContainer
                       && contentInk(enabled) == tokens->property(initialIconInks[appearance]).value<QColor>(),
                   "unselected icon appearance resolves its reference toggle container and ink");
            auto *plate = enabled->findChild<QQuickItem *>("material3.small.background");
            expect(enabled->width() == 48 && enabled->height() == 48
                       && plate && plate->width() == 40 && plate->height() == 40,
                   "default icon appearances keep a 40 px optical plate inside the 48 px native target");
            reveal(enabled);
            auto *glyph = enabled->findChild<QQuickItem *>("material3.button.icon");
            expect(glyph && !glyph->property("filled").toBool()
                       && glyph->property("name").toString() == QStringLiteral("material:settings")
                       && QQmlProperty::read(enabled, "icon.source").toUrl().isEmpty(),
                   "unselected icon uses AppIcon package rendering without an SVG condition");
            expect(glyph && QTest::qWaitFor([glyph] { return glyph->property("status").toInt() == 1; }, 1500),
                   "the imported Material provider resolves the actual glyph");
            QSignalSpy toggled(enabled, SIGNAL(toggled()));
            enabled->forceActiveFocus(Qt::TabFocusReason);
            QTest::keyClick(&window, Qt::Key_Space);
            expect(enabled->property("checked").toBool() && toggled.count() == 1, "Space toggles the native icon button once");
            expect(QTest::qWaitFor([enabled, selectedContainer, appearance, tokens, &selectedIconInks] {
                return container(enabled) == selectedContainer
                    && contentInk(enabled) == tokens->property(selectedIconInks[appearance]).value<QColor>();
            }, 1000), "selected icon appearance resolves the reference container and ink without changing native state");
            expect(glyph && glyph->property("filled").toBool(),
                   "the resolved icon variation policy drives FILL from native checked state");
            if (glyph) {
                auto *appearanceObject = glyph->property("appearance").value<QObject *>();
                expect(appearanceObject && appearanceObject->property("weight").toInt() == 400
                           && appearanceObject->property("opticalSize").toReal() == 24,
                       "the style supplies Material font weight and optical size");
                QQmlProperty::write(enabled, "icon.color", QColor(Qt::transparent));
                expect(glyph->property("color").value<QColor>().alpha() == 0,
                       "package icons preserve an explicit transparent native icon color");
            }
            if (appearance == 3) {
                auto *iconStyle = backgroundStyle(enabled);
                auto *iconBorder = iconStyle ? iconStyle->property("border").value<QObject *>() : nullptr;
                expect(iconBorder && iconBorder->property("width").toReal() == 1,
                       "selected outlined icon retains its one-pixel outline");
            }
            disabled->setProperty("checked", true);
            const QColor disabledContainer = appearance == 0 || appearance == 3
                ? QColor(Qt::transparent) : tokens->property("disabledContainer").value<QColor>();
            expect(container(disabled) == disabledContainer
                       && contentInk(disabled) == tokens->property("disabledLabel").value<QColor>(),
                   "disabled checked standard/outlined icons stay transparent and all disabled ink follows Theme");
            disabled->setProperty("checked", false);
        }
    }
    auto *commonChecked = item(window, "comparison.standard.choice.1");
    if (commonChecked) {
        reveal(commonChecked);
        auto *glyph = commonChecked->findChild<QQuickItem *>("material3.button.icon");
        expect(commonChecked->property("checked").toBool() && glyph
                   && !glyph->property("filled").toBool(),
               "a checked common button keeps the reference non-filled icon policy");
    }
    auto *connectedChecked = item(window, "comparison.connected.star.1");
    if (connectedChecked) {
        reveal(connectedChecked);
        auto *glyph = connectedChecked->findChild<QQuickItem *>("material3.button.icon");
        expect(connectedChecked->property("checked").toBool() && glyph
                   && glyph->property("filled").toBool(),
               "connected icon recipe preserves the style fill policy with its geometry data");
    }
    auto *narrow = item(window, "comparison.iconWidth.Narrow");
    auto *normal = item(window, "comparison.iconWidth.Default");
    auto *wide = item(window, "comparison.iconWidth.Wide");
    if (narrow && normal && wide) {
        auto *narrowPlate = narrow->findChild<QQuickItem *>("material3.small.background");
        auto *normalPlate = normal->findChild<QQuickItem *>("material3.small.background");
        auto *widePlate = wide->findChild<QQuickItem *>("material3.small.background");
        expect(narrowPlate && normalPlate && widePlate && narrowPlate->width() == 32
                   && normalPlate->width() == 40 && widePlate->width() == 52
                   && narrowPlate->height() == 40 && normalPlate->height() == 40 && widePlate->height() == 40,
               "narrow/default/wide icon plates preserve the exact reference optical dimensions");
        expect(narrow->width() == 40 && normal->width() == 48 && wide->width() == 60
                   && narrow->height() == 48 && normal->height() == 48 && wide->height() == 48,
               "icon width modes preserve the native reference insets around their optical plates");
    }
    size_t iconIndex = 0;
    for (const auto &probe : iconSizeCases) {
        const auto geometry = iconGeometries[iconIndex++];
        auto *icon = qobject_cast<QQuickItem *>(probe.get());
        if (!icon)
            continue;
        icon->setVisible(true);
        auto *plate = icon->findChild<QQuickItem *>("material3.small.background");
        auto *content = icon->property("contentItem").value<QQuickItem *>();
        const bool layoutReady = waitForProbe(icon, [icon, plate, geometry] {
            return icon->width() == geometry.nativeSize && icon->height() == geometry.nativeSize
                && plate && plate->width() == geometry.opticalSize && plate->height() == geometry.opticalSize
                && plate->mapToItem(icon, QPointF()) == QPointF(geometry.inset, geometry.inset)
                && paintedCornersMatch(plate, geometry.opticalSize / 2.0);
        }, "icon idle layout");
        expect(layoutReady && icon->width() == geometry.nativeSize && icon->height() == geometry.nativeSize,
               "all five library icon roles preserve reference native size plus the XS minimum-target adaptation");
        expect(plate && plate->width() == geometry.opticalSize && plate->height() == geometry.opticalSize,
               "all five library icon roles preserve the reference optical plate size");
        expect(icon->property("leftInset").toReal() == geometry.inset
                   && icon->property("rightInset").toReal() == geometry.inset
                   && icon->property("topInset").toReal() == geometry.inset
                   && icon->property("bottomInset").toReal() == geometry.inset,
               "StyleKit background margins resolve through native icon insets");
        expect(plate && plate->mapToItem(icon, QPointF()) == QPointF(geometry.inset, geometry.inset),
               "native icon insets position the optical plate without manual hit-area geometry");
        expect(icon->property("leftPadding").toReal() == 8 && icon->property("rightPadding").toReal() == 8
                   && icon->property("topPadding").toReal() == 8 && icon->property("bottomPadding").toReal() == 8
                   && icon->property("spacing").toReal() == 0,
               "native standalone icon padding edges preserve the reference eight pixels and zero spacing");
        expect(content && content->property("iconWidth").toReal() == geometry.iconSize
                   && content->property("iconHeight").toReal() == geometry.iconSize,
               "all five library icon roles preserve their reference glyph size");
        expect(paintedCornersMatch(plate, geometry.opticalSize / 2.0),
               "unchecked library icon buttons preserve the reference round corners");
        icon->setProperty("checkable", true);
        icon->setProperty("checked", true);
        expect(waitForProbe(icon, [plate, geometry] { return paintedCornersMatch(plate, geometry.checkedRadius); },
                            "icon checked shape"),
               "checked library icon buttons preserve each size's reference corner radius");
        QSignalSpy toggled(icon, SIGNAL(toggled()));
        icon->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyPress(&window, Qt::Key_Space);
        expect(icon->property("pressed").toBool(), "each icon-size probe keeps native keyboard press handling");
        expect(waitForProbe(icon, [plate, geometry] { return paintedCornersMatch(plate, geometry.pressedRadius); },
                            "icon pressed shape"),
               "pressed library icon buttons preserve each size's independent reference corner radius");
        QTest::keyRelease(&window, Qt::Key_Space);
        expect(!icon->property("checked").toBool() && toggled.count() == 1,
               "release toggles the native icon-size probe exactly once");
        expect(waitForProbe(icon, [plate, geometry] { return paintedCornersMatch(plate, geometry.opticalSize / 2.0); },
                            "icon released shape"),
               "released unchecked icon-size probes restore their round optical shape");
        icon->setVisible(false);
    }
    auto callerGeometryCase = createSizeCase("callerGeometry", "iconSmall", true, true);
    auto *callerIcon = qobject_cast<QQuickItem *>(callerGeometryCase.get());
    if (callerIcon) {
        callerIcon->setVisible(true);
        auto *plate = callerIcon->findChild<QQuickItem *>("material3.small.background");
        expect(waitForProbe(callerIcon, [callerIcon, plate] {
            return callerIcon->width() == 100 && callerIcon->height() == 80
                && plate && plate->width() == 92 && plate->height() == 72;
        }, "caller initial geometry"), "native icon caller geometry expands the optical background inside its four-pixel insets");
        callerIcon->setProperty("requestedWidth", 120);
        callerIcon->setProperty("requestedHeight", 96);
        expect(waitForProbe(callerIcon, [callerIcon, plate] {
            return callerIcon->width() == 120 && callerIcon->height() == 96
                && plate && plate->width() == 112 && plate->height() == 88;
        }, "caller updated geometry"), "caller width/height bindings remain live through native StyleKit icon inset layout");
        auto *content = callerIcon->property("contentItem").value<QQuickItem *>();
        if (content) {
            content->setProperty("iconWidth", 12);
            content->setProperty("iconHeight", 24);
            auto *glyph = content->findChild<QQuickItem *>("material3.button.icon");
            expect(waitForProbe(callerIcon, [glyph] {
                return glyph && glyph->property("size").toReal() == 12
                    && glyph->width() == 12 && glyph->height() == 24;
            }, "non-square package icon"),
                   "font icons fit independent caller width and height without overflowing the slot");
        }
        callerIcon->setVisible(false);
    }
    auto *tinted = item(window, "comparison.button.filled.icon");
    if (tinted) {
        const auto original = QQmlProperty::read(tinted, "icon.color");
        expect(QQmlProperty::write(tinted, "icon.color", QColor(Qt::transparent)), "native transparent icon tint is accepted");
        auto *plate = tinted->findChild<QQuickItem *>("material3.small.background");
        expect(plate && plate->property("rippleColor").value<QColor>().alpha() > 0,
               "transparent icon tint does not erase interaction ink");
        expect(plate && plate->property("contentColor").value<QColor>()
                   == tokens->property("primaryForeground").value<QColor>(),
               "interaction ink follows the resolved text role rather than the icon tint");
        QQmlProperty::write(tinted, "icon.color", original);
    }
    for (const auto &prefix : {"comparison.connected.files.", "comparison.segmented.period."}) {
        auto *first = item(window, QString::fromLatin1(prefix) + "0");
        auto *second = item(window, QString::fromLatin1(prefix) + "1");
        if (!first || !second)
            continue;
        reveal(first);
        first->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(first->property("checked").toBool() && !second->property("checked").toBool(), "group selection stays native and exclusive");
    }
    auto *connectedIcon = item(window, "comparison.connected.star.0");
    expect(connectedIcon && connectedIcon->property("leftInset").toReal() == 0
               && connectedIcon->property("rightInset").toReal() == 0
               && connectedIcon->property("topInset").toReal() == 0
               && connectedIcon->property("bottomInset").toReal() == 0,
           "connected icon recipe keeps zero native insets instead of standalone icon margins");
    auto *standardGroup = item(window, "comparison.standard.icons");
    if (standardGroup)
        expect(standardGroup->property("spacing").toReal() == tokens->property("spacingSmall").toReal(),
               "Standard groups preserve their independent spacing recipe");
    auto *split = item(window, "comparison.split.filled.menuButton");
    if (split) {
        reveal(split);
        split->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        auto *menu = split->findChild<QObject *>("comparison.split.filled.menu");
        expect(menu && menu->property("visible").toBool(), "split trailing action opens its native menu");
        auto *content = split->property("contentItem").value<QQuickItem *>();
        const bool rotated = content && QTest::qWaitFor([content] {
            return qAbs(content->property("iconRotation").toReal() - 180) < 0.1;
        }, 1000);
        if (!rotated)
            qWarning() << "SPLIT STATE" << (content ? content->property("iconRotation") : QVariant())
                       << (content ? content->property("canAnimate") : QVariant())
                       << (content ? content->property("splitTrailing") : QVariant())
                       << split->property("highlighted") << (menu ? menu->property("visible") : QVariant())
                       << window.isActive() << window.isExposed() << window.visibility();
        expect(rotated, "split indicator reaches the expanded rotation");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(menu && QTest::qWaitFor([&] { window.update(); return !menu->property("visible").toBool(); }, 1000),
               "Escape closes the split menu after its native exit transition");
    }
    for (const auto &geometry : fabGeometries) {
        auto *fab = item(window, "comparison.fab." + QString::fromLatin1(geometry.name));
        if (!fab)
            continue;
        auto *plate = fab->findChild<QQuickItem *>("material3.small.background");
        auto *content = fab->property("contentItem").value<QQuickItem *>();
        const QString accessibleName = QQmlProperty::read(fab, "Accessible.name", qmlContext(fab)).toString();
        expect(fab->height() == geometry.height && plate && plate->height() == geometry.height,
               "FAB native and painted heights match the reference variant");
        expect(paintedCornersMatch(plate, geometry.radius),
               "FAB painted corners use the rounded rectangle reference instead of a pill");
        expect(content && content->property("iconWidth").toReal() == geometry.iconSize
                   && content->property("iconHeight").toReal() == geometry.iconSize,
               "FAB variants preserve their independent reference icon sizes");
        if (geometry.leadingPadding == 0) {
            expect(fab->width() == geometry.height && plate && plate->width() == geometry.height,
                   "collapsed FAB variants keep the square reference extent");
        } else {
            auto *label = textLabel(content);
            const bool hasIcon = QByteArray(geometry.name) == "extended";
            const qreal labelLeading = label ? label->mapToItem(fab, QPointF()).x() : -1;
            const qreal labelTrailing = label ? fab->width() - label->mapToItem(fab, QPointF(label->width(), 0)).x() : -1;
            expect(label && qAbs(labelLeading - (hasIcon ? 52 : 20)) < 0.01
                       && qAbs(labelTrailing - 20) < 0.01 && fab->property("spacing").toReal() == 12,
                   "extended FAB paints the reference leading content inset and 20 px trailing label inset");
            const qreal expected = label ? qMax<qreal>(80, qCeil(label->implicitWidth())
                + (hasIcon ? geometry.iconSize + 12 : 0) + geometry.leadingPadding + 20) : 0;
            expect(label && qAbs(fab->implicitWidth() - expected) < 0.01,
                   "extended FAB intrinsic width reserves the actual leading and trailing reference insets");
            expect(label && !label->property("truncated").toBool(), "extended FAB keeps its complete visible label");
        }
        reveal(fab);
        const bool wasHoverEnabled = fab->property("hoverEnabled").toBool();
        fab->setProperty("hoverEnabled", true);
        QTest::mouseMove(&window, fab->mapToScene(QPointF(fab->width() / 2, fab->height() / 2)).toPoint());
        expect(fab->property("hovered").toBool(), "FAB receives native hover input");
        expect(paintedCornersMatch(plate, geometry.radius), "FAB hover preserves the reference rounded rectangle");
        fab->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyPress(&window, Qt::Key_Space);
        expect(fab->property("pressed").toBool(), "FAB receives the native held keyboard press");
        expect(QTest::qWaitFor([plate, &geometry] { return paintedCornersMatch(plate, geometry.radius); }, 1000),
               "FAB press keeps the reference corner radius");
        QTest::keyRelease(&window, Qt::Key_Space);
        if (QByteArray(geometry.name) == "extended") {
            expect(QTest::qWaitFor([fab, content] {
                return fab->width() == 56 && content && !content->property("showText").toBool()
                    && content->property("showIcon").toBool();
            }, 1500), "Create click collapses the same native button to the 56 px icon-only FAB");
            expect(fab->property("text").toString() == "Create", "Create collapse preserves the source label");
            expect(!accessibleName.isEmpty() && accessibleName == fab->property("text").toString()
                       && QQmlProperty::read(fab, "Accessible.name", qmlContext(fab)).toString() == accessibleName,
                   "icon-only Create retains the accessible name bound to its source label");
            QTest::keyClick(&window, Qt::Key_Space);
            expect(QTest::qWaitFor([fab, content] {
                return fab->property("expanded").toBool() && fab->width() > 80
                    && content && content->property("showText").toBool();
            }, 1500), "second Create click restores the same expanded native button");
        }
        fab->setProperty("hoverEnabled", wasHoverEnabled);
    }
    for (const auto &key : {"short", "long"}) {
        const QString prefix = "comparison.fabmenu." + QString::fromLatin1(key);
        const bool longMenu = QByteArray(key) == "long";
        auto *menu = item(window, prefix);
        auto *trigger = item(window, prefix + ".trigger");
        auto *first = item(window, prefix + ".action.0");
        auto *last = item(window, prefix + (longMenu ? ".action.5" : ".action.1"));
        auto *viewport = item(window, prefix + ".viewport");
        if (!menu || !trigger || !first || !last || !viewport)
            continue;
        expect(menu->property("expanded").toBool() == !longMenu,
               "short FAB menu starts open and long FAB menu starts collapsed like the reference");
        expect(trigger->property("checkable").toBool(), "FAB menu expansion stays on a native checkable button");
        expect(viewport->clip() && (!longMenu || viewport->property("contentHeight").toReal() > viewport->height()),
               "FAB actions use a clipped viewport and the long list has a scrollable extent");
        reveal(trigger);
        trigger->forceActiveFocus(Qt::TabFocusReason);
        if (menu->property("expanded").toBool()) {
            QTest::keyClick(&window, Qt::Key_Space);
            expect(!menu->property("expanded").toBool() && !first->property("inputEnabled").toBool()
                       && !last->property("inputEnabled").toBool(),
                   "closing the FAB menu immediately gates input before the closing animation finishes");
            expect(QTest::qWaitFor([first, last] {
                return first->property("widthProgress").toReal() == 0 && first->property("alphaProgress").toReal() == 0
                    && last->property("widthProgress").toReal() == 0 && last->property("alphaProgress").toReal() == 0;
            }, 2000), "collapsed FAB action geometry and opacity settle completely");
        }
        auto *firstPlate = first->findChild<QQuickItem *>("material3.small.background");
        auto *lastPlate = last->findChild<QQuickItem *>("material3.small.background");
        expect(firstPlate && lastPlate && QTest::qWaitFor([firstPlate, lastPlate] {
            return !firstPlate->property("feedbackEnabled").toBool()
                && !lastPlate->property("feedbackEnabled").toBool();
        }, 1000), "collapsed FAB action backgrounds stop feedback when their painted area disappears");
        QTest::keyClick(&window, Qt::Key_Space);
        expect(menu->property("expanded").toBool(), "native trigger opens the inline FAB action stack");
        expect(QTest::qWaitFor([first, last] {
            return first->property("inputEnabled").toBool() && last->property("inputEnabled").toBool()
                && first->property("widthProgress").toReal() == 1 && first->property("alphaProgress").toReal() == 1
                && last->property("widthProgress").toReal() == 1 && last->property("alphaProgress").toReal() == 1;
        }, 2000), "all inline FAB actions finish their staged reveal");
        QTest::keyClick(&window, Qt::Key_Down);
        expect(first->hasActiveFocus(), "Down moves native focus from the FAB trigger into its first action");
        if (longMenu) {
            for (int index = 0; index < 5; ++index)
                QTest::keyClick(&window, Qt::Key_Down);
            expect(last->hasActiveFocus() && viewport->property("contentY").toReal() > 0,
                   "keyboard navigation scrolls the long FAB list to its last action");
        }
        auto *selected = longMenu ? last : first;
        const QString selectedText = selected->property("text").toString();
        QTest::keyClick(&window, Qt::Key_Space);
        expect(menu->property("lastAction").toString() == selectedText && !menu->property("expanded").toBool(),
               "native FAB action activation records the selected label and closes its stack");
        expect(trigger->hasActiveFocus(), "closing a FAB action restores focus to its own trigger");
        QTest::keyClick(&window, Qt::Key_Space);
        expect(QTest::qWaitFor([first] { return first->property("inputEnabled").toBool(); }, 2000),
               "FAB actions become available after reopening");
        QTest::keyClick(&window, Qt::Key_Down);
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(!menu->property("expanded").toBool() && trigger->hasActiveFocus(),
               "Escape from a FAB action closes the inline stack and restores trigger focus");
    }
    reveal(filled);
    QSignalSpy clicked(filled, SIGNAL(clicked()));
    filled->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Space);
    expect(clicked.count() == 1, "common button keyboard activation remains native");
    for (bool dark : {true, false, true, false}) {
        window.setProperty("darkMode", dark);
        QTest::qWait(50);
        auto *currentTokens = style->property("tokens").value<QObject *>();
        expect(findItem(window.contentItem(), "comparison.button.filled") == filled, "theme changes preserve the button instance");
        expect(container(filled) == currentTokens->property("primary").value<QColor>(), "theme resolves Filled primary");
        expect(container(tonal) == currentTokens->property("secondaryContainer").value<QColor>(), "theme resolves Tonal secondary container");
        expect(container(outlined).alpha() == 0, "theme keeps outlined transparent");
        for (const auto &geometry : fabGeometries) {
            auto *fab = findItem(window.contentItem(), "comparison.fab." + QString::fromLatin1(geometry.name));
            auto *plate = fab ? fab->findChild<QQuickItem *>("material3.small.background") : nullptr;
            expect(fab && fab->height() == geometry.height && paintedCornersMatch(plate, geometry.radius),
                   "repeated theme changes preserve every FAB painted height and corner radius");
        }
        for (size_t sizeIndex = 0; sizeIndex < commonSizeCases.size(); ++sizeIndex) {
            auto *common = qobject_cast<QQuickItem *>(commonSizeCases[sizeIndex].get());
            auto *icon = qobject_cast<QQuickItem *>(iconSizeCases[sizeIndex].get());
            auto *commonPlate = common ? common->findChild<QQuickItem *>("material3.small.background") : nullptr;
            auto *iconPlate = icon ? icon->findChild<QQuickItem *>("material3.small.background") : nullptr;
            expect(common && icon && commonPlate && iconPlate
                       && common->height() == qMax(40, commonGeometries[sizeIndex].height)
                       && commonPlate->height() == commonGeometries[sizeIndex].height
                       && container(common) == currentTokens->property("primary").value<QColor>()
                       && contentInk(common) == currentTokens->property("primaryForeground").value<QColor>()
                       && icon->height() == iconGeometries[sizeIndex].nativeSize
                       && iconPlate->height() == iconGeometries[sizeIndex].opticalSize
                       && contentInk(icon) == currentTokens->property("surfaceVariantForeground").value<QColor>(),
                   "all five library common/icon size probes preserve geometry and resolved ink across theme changes");
        }
        for (int appearance = 0; appearance < 4; ++appearance) {
            auto *icon = findItem(window.contentItem(), "comparison.iconButton." + QString::number(appearance) + ".enabled");
            const QColor expected = selectedIconContainers[appearance]
                ? currentTokens->property(selectedIconContainers[appearance]).value<QColor>() : QColor(Qt::transparent);
            expect(icon && icon->property("checked").toBool() && container(icon) == expected
                       && contentInk(icon) == currentTokens->property(selectedIconInks[appearance]).value<QColor>(),
                   "selected icon appearances keep their checked state and resolve the current Theme roles");
        }
        const char *roles[] = {"primaryForeground", "secondaryContainerForeground", "primary", "primary"};
        for (size_t nativeIndex = 0; nativeIndex < nativeCases.size(); ++nativeIndex) {
            auto *native = qobject_cast<QQuickItem *>(nativeCases[nativeIndex].get());
            auto *nativePlate = native ? native->findChild<QQuickItem *>("material3.small.background") : nullptr;
            expect(nativePlate && nativePlate->property("contentColor").value<QColor>()
                       == currentTokens->property(roles[nativeIndex]).value<QColor>(),
                   "plain native interaction ink follows repeated theme changes");
        }
    }
    window.setProperty("reducedMotion", true);
    QTest::qWait(30);
    expect(style->property("effectiveReducedMotion").toBool(), "comparison reduced motion reaches the kit");
    auto *filledContent = filled->property("contentItem").value<QQuickItem *>();
    expect(filledContent && !filledContent->property("canAnimate").toBool(),
           "reduced motion stops the content delegate animations");
    for (size_t sizeIndex = 0; sizeIndex < commonSizeCases.size(); ++sizeIndex) {
        auto *common = qobject_cast<QQuickItem *>(commonSizeCases[sizeIndex].get());
        auto *icon = qobject_cast<QQuickItem *>(iconSizeCases[sizeIndex].get());
        auto *commonContent = common ? common->property("contentItem").value<QQuickItem *>() : nullptr;
        auto *iconContent = icon ? icon->property("contentItem").value<QQuickItem *>() : nullptr;
        expect(commonContent && iconContent && commonContent->property("reduceMotion").toBool()
                   && iconContent->property("reduceMotion").toBool(),
               "reduced-motion policy reaches every library common/icon size probe through StyleKit data");
    }
    auto *create = findItem(window.contentItem(), "comparison.fab.extended");
    auto *createContent = create ? create->property("contentItem").value<QQuickItem *>() : nullptr;
    if (create) {
        reveal(create);
        create->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(!create->property("expanded").toBool() && create->width() == 56
                   && createContent && !createContent->property("showText").toBool(),
               "reduced motion collapses Create without waiting for an animation");
        QTest::keyClick(&window, Qt::Key_Space);
        expect(create->property("expanded").toBool() && create->width() > 80
                   && createContent && createContent->property("showText").toBool(),
               "reduced motion immediately restores the expanded Create label");
    }
    for (const auto &geometry : fabGeometries) {
        auto *fab = findItem(window.contentItem(), "comparison.fab." + QString::fromLatin1(geometry.name));
        auto *plate = fab ? fab->findChild<QQuickItem *>("material3.small.background") : nullptr;
        expect(fab && fab->height() == geometry.height && paintedCornersMatch(plate, geometry.radius),
               "reduced motion preserves every FAB painted shape");
    }
    for (const auto &key : {"short", "long"}) {
        const QString prefix = "comparison.fabmenu." + QString::fromLatin1(key);
        auto *menu = findItem(window.contentItem(), prefix);
        auto *trigger = findItem(window.contentItem(), prefix + ".trigger");
        auto *first = findItem(window.contentItem(), prefix + ".action.0");
        auto *last = findItem(window.contentItem(), prefix + (QByteArray(key) == "long" ? ".action.5" : ".action.1"));
        if (!menu || !trigger || !first || !last)
            continue;
        reveal(trigger);
        trigger->forceActiveFocus(Qt::TabFocusReason);
        QTest::keyClick(&window, Qt::Key_Space);
        expect(menu->property("expanded").toBool() && !menu->property("canAnimate").toBool()
                   && first->property("widthProgress").toReal() == 1 && first->property("alphaProgress").toReal() == 1
                   && last->property("widthProgress").toReal() == 1 && last->property("alphaProgress").toReal() == 1,
               "reduced motion immediately reveals the complete FAB action stack");
        QTest::keyClick(&window, Qt::Key_Escape);
        expect(!menu->property("expanded").toBool()
                   && first->property("widthProgress").toReal() == 0 && first->property("alphaProgress").toReal() == 0
                   && last->property("widthProgress").toReal() == 0 && last->property("alphaProgress").toReal() == 0,
               "reduced motion immediately clears the complete FAB action stack");
    }
    expect(!window.grabWindow().isNull(), "comparison renderer produces an image");
    expect(warnings.isEmpty(), "no QML warnings during family interaction and theme switching");
    qInfo() << "Qt" << qVersion() << "comparison assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
