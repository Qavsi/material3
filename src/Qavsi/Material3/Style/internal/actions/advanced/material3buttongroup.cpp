// Copyright (c) 2024-2026 hypengw, Enes Alp
// SPDX-License-Identifier: MIT
// Width allocation adapted from QmlMaterial 0.6.1 (1912605).
#include "material3buttongroup.h"
#include <QGuiApplication>
#include <QAccessibilityHints>
#include <QStyleHints>
#include <QMetaProperty>
#include <QMetaEnum>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QSGRendererInterface>
#include <algorithm>
#include <cmath>
#include <limits>
#include <numeric>
#include <utility>

namespace {
bool isButton(QQuickItem *item)
{
    return item && item->metaObject()->indexOfProperty("pressed") >= 0
        && item->metaObject()->indexOfProperty("implicitContentWidth") >= 0;
}
Material3ButtonGroupAttached *attached(QQuickItem *item)
{
    return qobject_cast<Material3ButtonGroupAttached *>(
        qmlAttachedPropertiesObject<Material3ButtonGroup>(item, true));
}
qreal metric(QObject *object, const char *name)
{
    bool ok = false;
    const qreal value = object->property(name).toDouble(&ok);
    return ok && std::isfinite(value) ? std::max(qreal(0), value) : 0;
}
void watchProperty(QObject *source, const char *name, QObject *receiver, const char *slot)
{
    const int index = source->metaObject()->indexOfProperty(name);
    if (index < 0) return;
    const auto property = source->metaObject()->property(index);
    if (!property.hasNotifySignal()) return;
    QObject::connect(source, property.notifySignal(), receiver,
        receiver->metaObject()->method(receiver->metaObject()->indexOfSlot(slot)));
}
} // namespace

Material3ButtonGroup::Material3ButtonGroup(QQuickItem *parent) : QQuickItem(parent)
{
    connect(this, &QQuickItem::widthChanged, this, &Material3ButtonGroup::invalidate);
    connect(this, &QQuickItem::visibleChanged, this, &Material3ButtonGroup::refreshMotion);
    connect(this, &QQuickItem::enabledChanged, this, &Material3ButtonGroup::refreshMotion);
    connect(this, &QQuickItem::opacityChanged, this, &Material3ButtonGroup::refreshMotion);
    connect(this, &QQuickItem::windowChanged, this, &Material3ButtonGroup::updateWindow);
    connect(QGuiApplication::styleHints()->accessibility(), &QAccessibilityHints::motionPreferenceChanged,
        this, &Material3ButtonGroup::refreshMotion);
    connect(qGuiApp, &QGuiApplication::layoutDirectionChanged, this, [this] {
        invalidate();
        Q_EMIT mirroredChanged();
    });
}
Material3ButtonGroup::~Material3ButtonGroup()
{
    m_destroying = true;
    for (auto *item : childItems()) {
        if (!isButton(item)) continue;
        auto *info = attached(item);
        info->m_group = nullptr;
        info->m_press.setEnabled(false);
    }
}
Material3ButtonGroupAttached *Material3ButtonGroup::qmlAttachedProperties(QObject *object)
{
    return new Material3ButtonGroupAttached(object);
}
qreal Material3ButtonGroup::token(const char *name, qreal fallback) const
{
    if (!m_tokens) return fallback;
    bool ok = false;
    const qreal value = m_tokens->property(name).toDouble(&ok);
    return ok && std::isfinite(value) && value >= 0 ? value : fallback;
}
void Material3ButtonGroup::setTokens(QObject *value)
{
    if (value == m_tokens) return;
    for (const auto &connection : std::as_const(m_tokenConnections)) disconnect(connection);
    m_tokenConnections.clear();
    m_tokens = value;
    if (value) {
        const auto slot = metaObject()->method(metaObject()->indexOfSlot("refreshMotion()"));
        for (const char *name : {"buttonGroupSpringStiffness", "buttonGroupSpringDampingRatio",
                                "buttonSpringVisibilityThreshold", "buttonGroupExpandedRatio",
                                "minimumTargetSize"}) {
            const int index = value->metaObject()->indexOfProperty(name);
            if (index >= 0) {
                const auto property = value->metaObject()->property(index);
                if (property.hasNotifySignal())
                    m_tokenConnections.append(connect(value, property.notifySignal(), this, slot));
            }
        }
        m_tokenConnections.append(connect(value, &QObject::destroyed, this, [this] {
            m_tokens = nullptr;
            QPointer<Material3ButtonGroup> guard(this);
            refreshMotion();
            if (guard) Q_EMIT tokensChanged();
        }));
    }
    QPointer<Material3ButtonGroup> guard(this);
    refreshMotion();
    if (guard) Q_EMIT tokensChanged();
}
void Material3ButtonGroup::setReduceMotion(bool value)
{
    if (value == m_reduceMotion) return;
    m_reduceMotion = value;
    QPointer<Material3ButtonGroup> guard(this);
    refreshMotion();
    if (guard) Q_EMIT reduceMotionChanged();
}
void Material3ButtonGroup::setAnimateWidth(bool value)
{
    if (value == m_animateWidth) return;
    m_animateWidth = value;
    QPointer<Material3ButtonGroup> guard(this);
    refreshMotion();
    if (guard) Q_EMIT animateWidthChanged();
}
void Material3ButtonGroup::setSpacing(qreal value)
{
    if (!std::isfinite(value) || value < 0 || value == m_spacing) return;
    m_spacing = value;
    invalidate();
    Q_EMIT spacingChanged();
}
bool Material3ButtonGroup::mirrored() const
{
    if (m_mirrored) return *m_mirrored;
    for (auto *item : childItems())
        if (isButton(item)) return item->property("mirrored").toBool();
    return QGuiApplication::layoutDirection() == Qt::RightToLeft;
}
void Material3ButtonGroup::setMirrored(bool value)
{
    if (m_mirrored && *m_mirrored == value) return;
    m_mirrored = value;
    invalidate();
    Q_EMIT mirroredChanged();
}
void Material3ButtonGroup::resetMirrored()
{
    if (!m_mirrored) return;
    m_mirrored.reset();
    invalidate();
    Q_EMIT mirroredChanged();
}
void Material3ButtonGroup::invalidate()
{
    if (m_destroying) return;
    ++m_revision;
    polish();
}
void Material3ButtonGroup::itemChange(ItemChange change, const ItemChangeData &data)
{
    QQuickItem::itemChange(change, data);
    if (change == ItemChildAddedChange || change == ItemChildRemovedChange) invalidate();
}
void Material3ButtonGroup::componentComplete()
{
    QQuickItem::componentComplete();
    updateWindow();
    refreshMotion();
}
bool Material3ButtonGroup::feedbackActive() const
{
    return m_tokens && isEnabled() && isVisible() && opacity() > 0 && window()
        && window()->isVisible() && window()->visibility() != QWindow::Minimized;
}
bool Material3ButtonGroup::canAnimate() const
{
    if (m_reduceMotion || QGuiApplication::styleHints()->accessibility()->motionPreference()
        == Qt::MotionPreference::ReducedMotion || !feedbackActive()) return false;
    const auto api = window()->rendererInterface()->graphicsApi();
    return api != QSGRendererInterface::Software && api != QSGRendererInterface::Unknown
        && api != QSGRendererInterface::Null;
}
void Material3ButtonGroup::updateWindow()
{
    for (const auto &connection : std::as_const(m_windowConnections)) disconnect(connection);
    m_windowConnections.clear();
    if (window()) {
        m_windowConnections.append(connect(window(), &QWindow::visibleChanged, this, &Material3ButtonGroup::refreshMotion));
        m_windowConnections.append(connect(window(), &QWindow::visibilityChanged, this, &Material3ButtonGroup::refreshMotion));
        m_windowConnections.append(connect(window(), &QQuickWindow::sceneGraphInitialized,
            this, &Material3ButtonGroup::refreshMotion, Qt::QueuedConnection));
        m_windowConnections.append(connect(window(), &QQuickWindow::sceneGraphInvalidated,
            this, &Material3ButtonGroup::refreshMotion, Qt::QueuedConnection));
    }
    refreshMotion();
}
void Material3ButtonGroup::refreshMotion()
{
    if (m_destroying) return;
    QPointer<Material3ButtonGroup> guard(this);
    QList<QPointer<QQuickItem>> items;
    for (auto *item : childItems()) if (isButton(item)) items.append(item);
    for (const auto &item : items) {
        if (!item) continue;
        QPointer<Material3ButtonGroupAttached> info(attached(item));
        info->updateGroup();
        if (!guard) return;
        if (info) info->updatePress();
        if (!guard) return;
    }
    invalidate();
}
void Material3ButtonGroup::updatePolish()
{
    if (m_destroying) return;
    const auto revision = m_revision;
    QPointer<Material3ButtonGroup> guard(this);
    QList<QPointer<QQuickItem>> items;
    for (auto *item : childItems())
        if (isButton(item) && (item->isVisible() || !isVisible())) items.append(item);
    const int count = int(items.size());
    QList<qreal> base(count), minimum(count), weights(count), budgets(count), progress(count);
    qreal natural = std::max(0, count - 1) * m_spacing, height = 0, fixed = 0, weightSum = 0;
    for (int i = 0; i < count; ++i) {
        auto *item = items[i].data();
        if (!item) { invalidate(); return; }
        auto *info = attached(item);
        info->updateGroup();
        if (!guard || revision != m_revision) { if (guard) polish(); return; }
        const qreal contentMinimum = metric(item, "implicitContentWidth")
            + metric(item, "leftInset") + metric(item, "rightInset");
        minimum[i] = info->minimumWidth() >= 0 ? info->minimumWidth()
            : std::max(token("minimumTargetSize"), contentMinimum);
        const qreal implicitWidth = metric(item, "implicitWidth");
        base[i] = info->managed() ? std::max(minimum[i], info->preferredWidth() >= 0
            ? info->preferredWidth() : implicitWidth) : metric(item, "width");
        weights[i] = info->managed() ? info->weight() : 0;
        weightSum += weights[i];
        if (weights[i] == 0) fixed += base[i];
        natural += base[i];
        height = std::max(height, metric(item, "height"));
        const int displayEnum = item->metaObject()->indexOfEnumerator("Display");
        const bool iconOnly = displayEnum >= 0 && item->property("display").toInt()
            == item->metaObject()->enumerator(displayEnum).keyToValue("IconOnly");
        const qreal defaultBudget = iconOnly
            ? std::max(qreal(0), (implicitWidth - contentMinimum) / 2)
            : std::min(metric(item, "leftPadding"), metric(item, "rightPadding"));
        budgets[i] = info->managed() ? info->compressionLimit() >= 0
            ? info->compressionLimit() : defaultBudget : 0;
        progress[i] = m_animateWidth && info->managed() ? std::max(qreal(0), info->m_press.value()) : 0;
    }
    setImplicitWidth(std::max(qreal(0), natural));
    if (!guard) return;
    setImplicitHeight(height);
    if (!guard) return;
    if (revision != m_revision) { polish(); return; }
    if (weightSum > 0) {
        qreal remaining = std::max(qreal(0), metric(this, "width") - fixed - std::max(0, count - 1) * m_spacing);
        QList<bool> active(count, true);
        for (int pass = 0; pass < count && weightSum > 0; ++pass) {
            bool clamped = false;
            for (int i = 0; i < count; ++i) {
                if (weights[i] <= 0 || !active[i]) continue;
                if (remaining * weights[i] / weightSum < minimum[i]) {
                    base[i] = minimum[i];
                    remaining = std::max(qreal(0), remaining - minimum[i]);
                    weightSum -= weights[i];
                    active[i] = false;
                    clamped = true;
                }
            }
            if (!clamped) break;
        }
        for (int i = 0; i < count; ++i)
            if (weights[i] > 0 && active[i] && weightSum > 0)
                base[i] = remaining * weights[i] / weightSum;
    }
    for (int i = 0; i < count; ++i)
        budgets[i] = std::min(budgets[i], std::max(qreal(0), base[i] - minimum[i]));
    QList<qreal> request(count, 0), donated(count, 0), result = base;
    for (int i = 0; i < count && count > 1; ++i) {
        const int neighbors = (i > 0) + (i + 1 < count);
        const qreal amount = progress[i] * std::min(token("buttonGroupExpandedRatio") * base[i] / neighbors,
            std::min(i > 0 ? budgets[i - 1] : std::numeric_limits<qreal>::max(),
                     i + 1 < count ? budgets[i + 1] : std::numeric_limits<qreal>::max()));
        request[i] = amount;
        if (i > 0) donated[i - 1] += amount;
        if (i + 1 < count) donated[i + 1] += amount;
    }
    for (int i = 0; i < count; ++i) {
        for (int j : {i - 1, i + 1}) {
            if (j < 0 || j >= count) continue;
            const qreal amount = request[i] * (donated[j] > 0 ? std::min(qreal(1), budgets[j] / donated[j]) : 0);
            result[i] += amount;
            result[j] -= amount;
        }
    }
    const bool rtl = mirrored();
    qreal x = rtl ? std::accumulate(base.begin(), base.end(), qreal(0))
        + std::max(0, count - 1) * m_spacing : 0;
    for (int i = 0; i < count; ++i) {
        auto item = items[i];
        if (!item) { invalidate(); return; }
        if (rtl) x -= result[i];
        // Consumers bind managed widths to layoutWidth; no caller binding is replaced here.
        attached(item)->setLayoutWidth(result[i]);
        if (!guard) return;
        if (!item || revision != m_revision) { polish(); return; }
        item->setPosition(QPointF(x, (height - metric(item, "height")) / 2));
        if (!guard) return;
        if (revision != m_revision) { polish(); return; }
        x += rtl ? -m_spacing : result[i] + m_spacing;
    }
}

Material3ButtonGroupAttached::Material3ButtonGroupAttached(QObject *object)
    : QObject(object), m_item(qobject_cast<QQuickItem *>(object)), m_press(this)
{
    m_press.setEnabled(false);
    connect(&m_press, &Material3Spring::valueChanged, this, [this] {
        QPointer<Material3ButtonGroupAttached> guard(this);
        layoutChanged();
        if (guard) releaseIfReady();
    });
    if (!m_item || !isButton(m_item)) return;
    connect(m_item, &QQuickItem::parentChanged, this, &Material3ButtonGroupAttached::updateGroup);
    connect(m_item, &QQuickItem::widthChanged, this, [this] { if (!m_managed) layoutChanged(); });
    connect(m_item, &QQuickItem::heightChanged, this, &Material3ButtonGroupAttached::layoutChanged);
    connect(m_item, &QQuickItem::implicitWidthChanged, this, &Material3ButtonGroupAttached::layoutChanged);
    connect(m_item, &QQuickItem::implicitHeightChanged, this, &Material3ButtonGroupAttached::layoutChanged);
    for (const char *name : {"pressed", "enabled", "visible", "opacity"})
        watchProperty(m_item, name, this, "updatePress()");
    for (const char *name : {"implicitContentWidth", "leftPadding", "rightPadding", "leftInset", "rightInset", "display"})
        watchProperty(m_item, name, this, "layoutChanged()");
    watchProperty(m_item, "mirrored", this, "mirroringChanged()");
    connect(m_item, &QQuickItem::visibleChanged, this, &Material3ButtonGroupAttached::layoutChanged);
    updateGroup();
}
qreal Material3ButtonGroupAttached::layoutWidth() const
{
    return m_hasLayoutWidth ? m_layoutWidth : m_item ? metric(m_item, "implicitWidth") : 0;
}
void Material3ButtonGroupAttached::setLayoutWidth(qreal value)
{
    if (m_hasLayoutWidth && m_layoutWidth == value) return;
    m_layoutWidth = value;
    m_hasLayoutWidth = true;
    Q_EMIT layoutWidthChanged();
}
void Material3ButtonGroupAttached::updateGroup()
{
    auto *group = m_item ? qobject_cast<Material3ButtonGroup *>(m_item->parentItem()) : nullptr;
    if (group == m_group) return;
    if (m_group) m_group->invalidate();
    m_group = group;
    m_releasing = false;
    QPointer<Material3ButtonGroupAttached> guard(this);
    m_press.setEnabled(false);
    if (!guard) return;
    m_press.snapTo(0);
    if (!guard) return;
    m_hasLayoutWidth = false;
    Q_EMIT layoutWidthChanged();
    if (!guard) return;
    layoutChanged();
    updatePress();
}
void Material3ButtonGroupAttached::layoutChanged()
{
    if (m_group) m_group->invalidate();
}
void Material3ButtonGroupAttached::mirroringChanged()
{
    if (!m_group) return;
    m_group->invalidate();
    Q_EMIT m_group->mirroredChanged();
}
void Material3ButtonGroupAttached::updatePress()
{
    const bool active = m_group && m_item && m_managed && m_group->animateWidth()
        && m_group->feedbackActive() && m_item->isEnabled() && m_item->isVisible() && m_item->opacity() > 0;
    QPointer<Material3ButtonGroupAttached> guard(this);
    if (!active) {
        m_releasing = false;
        m_press.setEnabled(false);
        if (guard) m_press.snapTo(0);
        return;
    }
    m_press.setStiffness(m_group->token("buttonGroupSpringStiffness"));
    if (!guard) return;
    m_press.setDampingRatio(m_group->token("buttonGroupSpringDampingRatio"));
    if (!guard) return;
    m_press.setVisibilityThreshold(m_group->token("buttonSpringVisibilityThreshold"));
    if (!guard) return;
    m_press.setEnabled(m_group->canAnimate());
    if (!guard) return;
    if (m_item->property("pressed").toBool()) {
        m_releasing = false;
        m_press.setTargetValue(1);
    } else {
        m_releasing = m_press.targetValue() != 0;
        releaseIfReady();
    }
}
void Material3ButtonGroupAttached::releaseIfReady()
{
    // QCM keeps a quick press visible before reversing the width spring.
    if (m_releasing && (m_press.value() > .75 || m_press.elapsed() >= 1000 || !m_press.isRunning())) {
        m_releasing = false;
        m_press.setTargetValue(0);
    }
}
void Material3ButtonGroupAttached::setManaged(bool value)
{
    if (m_managed == value) return;
    m_managed = value;
    QPointer<Material3ButtonGroupAttached> guard(this);
    updatePress();
    if (!guard) return;
    layoutChanged();
    Q_EMIT parametersChanged();
}
#define SET_PARAMETER(Upper, Member) \
    void Material3ButtonGroupAttached::set##Upper(qreal value) { \
        if (!std::isfinite(value) || value < 0 || value == Member) return; \
        Member = value; layoutChanged(); Q_EMIT parametersChanged(); \
    }
SET_PARAMETER(PreferredWidth, m_preferredWidth)
SET_PARAMETER(MinimumWidth, m_minimumWidth)
SET_PARAMETER(Weight, m_weight)
SET_PARAMETER(CompressionLimit, m_compressionLimit)
#undef SET_PARAMETER
void Material3ButtonGroupAttached::resetPreferredWidth()
{
    if (m_preferredWidth < 0) return;
    m_preferredWidth = -1; layoutChanged(); Q_EMIT parametersChanged();
}
void Material3ButtonGroupAttached::resetMinimumWidth()
{
    if (m_minimumWidth < 0) return;
    m_minimumWidth = -1; layoutChanged(); Q_EMIT parametersChanged();
}
void Material3ButtonGroupAttached::resetCompressionLimit()
{
    if (m_compressionLimit < 0) return;
    m_compressionLimit = -1; layoutChanged(); Q_EMIT parametersChanged();
}
