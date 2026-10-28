// Copyright (c) 2024-2025 hypengw
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#include "qcm_carousel_view.hpp"
#include "carousel_native.h"
#include <QKeyEvent>

#include <QAbstractItemModel>
#include <QJSValue>
#include <QMetaObject>
#include <QMetaType>
#include <QMetaProperty>
#include <QPropertyAnimation>
#include <QAbstractAnimation>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlInfo>
#include <QTimer>
#include <QWheelEvent>
#include <QSet>
#include <QVariantMap>
#include <QtMath>
#include <limits>
#include <algorithm>
#include <utility>

namespace qavsi::material3::carousel
{

namespace
{

constexpr qreal kSnapStiffness = 280.0;
constexpr qreal kSnapDamping   = 28.0;
constexpr qreal kSnapDt        = 1.0 / 60.0;
constexpr int   kSizeLarge     = 2;

auto isHeroLayout(int layout) -> bool {
    return layout == CarouselLayoutId::Hero || layout == CarouselLayoutId::HeroCenter;
}

auto isHeroCenterLayout(int layout) -> bool { return layout == CarouselLayoutId::HeroCenter; }

auto isFullScreenLayout(int layout) -> bool { return layout == CarouselLayoutId::FullScreen; }

std::optional<NativeFlickable> asFlickable(QQuickItem *item) {
    if (!item) return {};
    return NativeFlickable{item};
}

QJSValue modelAsJsValue(const QVariant& model) {
    if (model.metaType() == QMetaType::fromType<QJSValue>()) {
        return model.value<QJSValue>();
    }
    return {};
}

QObject* modelAsObject(const QVariant& model) {
    if (auto* object = model.value<QObject*>()) {
        return object;
    }
    const QJSValue js = modelAsJsValue(model);
    if (js.isQObject()) {
        return js.toQObject();
    }
    QVariant converted = model;
    if (converted.convert(QMetaType::fromType<QObject*>())) {
        return converted.value<QObject*>();
    }
    return nullptr;
}

QAbstractItemModel* modelAsItemModel(const QVariant& model) {
    return qobject_cast<QAbstractItemModel*>(modelAsObject(model));
}

int modelArrayLength(const QVariant& model) {
    if (model.canConvert<QVariantList>()) {
        return model.toList().size();
    }
    const QJSValue js = modelAsJsValue(model);
    if (js.isArray()) {
        return js.property(QStringLiteral("length")).toInt();
    }
    return 0;
}

QVariant normalizeModelRow(const QVariant& row) {
    if (row.metaType() == QMetaType::fromType<QJSValue>()) {
        return row.value<QJSValue>().toVariant(QJSValue::ConvertJSObjects);
    }
    return row;
}

QVariant modelElementAt(const QVariant& model, int index) {
    if (model.canConvert<QVariantList>()) {
        const auto list = model.toList();
        if (index >= 0 && index < list.size()) {
            return normalizeModelRow(list.at(index));
        }
    }
    const QJSValue js = modelAsJsValue(model);
    if (js.isArray()) {
        return normalizeModelRow(js.property(index).toVariant(QJSValue::ConvertJSObjects));
    }
    if (auto* item_model = modelAsItemModel(model)) {
        if (index < 0 || index >= item_model->rowCount()) {
            return {};
        }
        QVariantMap       row;
        const auto        roles = item_model->roleNames();
        const QModelIndex idx   = item_model->index(index, 0);
        for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
            row[QString::fromUtf8(it.value())] = item_model->data(idx, it.key());
        }
        return row;
    }
    return index;
}

QVariantMap requestedDelegateProperties(const QObject *item, const QVariantMap &values) {
    QVariantMap requested;
    for (auto it = values.cbegin(); it != values.cend(); ++it) {
        const int index = item->metaObject()->indexOfProperty(it.key().toUtf8().constData());
        if (index < 0) continue;
        const auto property = item->metaObject()->property(index);
        if (property.isWritable()) requested.insert(it.key(), it.value());
    }
    return requested;
}

void ensureItemQmlContext(QQuickItem* owner, QQuickItem* item) {
    if (! owner || ! item || qmlContext(item)) {
        return;
    }
    QQmlEngine* engine = qmlEngine(owner);
    if (! engine) {
        return;
    }
    QQmlContext* ctx = qmlContext(owner);
    if (! ctx) {
        ctx = engine->rootContext();
    }
    if (ctx) {
        engine->setContextForObject(item, new QQmlContext(ctx, item));
    }
}

} // namespace

Material3CarouselView::Material3CarouselView(QQuickItem* parent): QQuickItem(parent) {
    setFlag(ItemHasContents, true);
    setClip(true);

    m_snap_timer = new QTimer(this);
    m_snap_timer->setInterval(16);
    connect(m_snap_timer, &QTimer::timeout, this, &Material3CarouselView::onSnapTick);
}

Material3CarouselView::~Material3CarouselView() {
    m_destroying = true;
    ++m_revision;
    m_completed = false;
    disconnect(m_flickable, nullptr, this, nullptr);
    const auto items = std::exchange(m_items, {});
    for (const auto& item : items) {
        if (! item) continue;
        disconnect(item, nullptr, this, nullptr);
    }
}

void Material3CarouselView::setMirrored(bool value) {
    if (m_mirrored == value) return;
    m_mirrored = value;
    const QPointer<Material3CarouselView> guard(this);
    cancelSnapAnimation();
    if (! guard) return;
    updateLayout();
    if (guard) Q_EMIT mirroredChanged();
}

Material3CarouselAttached* Material3CarouselView::qmlAttachedProperties(QObject* object) {
    return new Material3CarouselAttached(object);
}

QVariant Material3CarouselView::model() const { return m_model; }

void Material3CarouselView::setModel(const QVariant& model) {
    if (m_destroying || m_model == model) {
        return;
    }
    const QPointer<Material3CarouselView> guard(this);
    const auto                   request = ++m_configurationRevision;
    unbindItemModel();
    m_model = model;
    if (auto* item_model = modelAsItemModel(m_model)) {
        bindItemModel(item_model);
    }
    updateCount();
    if (! guard || request != m_configurationRevision) return;
    rebuildItems();
    if (! guard || request != m_configurationRevision) return;
    syncCurrentIndexAfterCountChange();
    if (guard && request == m_configurationRevision) Q_EMIT modelChanged();
}

QQmlComponent* Material3CarouselView::delegate() const { return m_delegate; }

void Material3CarouselView::setDelegate(QQmlComponent* delegate) {
    if (m_destroying || m_delegate == delegate) {
        return;
    }
    m_delegate = delegate;
    const QPointer<Material3CarouselView> guard(this);
    const auto                   request = ++m_configurationRevision;
    rebuildItems();
    if (guard && request == m_configurationRevision) Q_EMIT delegateChanged();
}

int Material3CarouselView::count() const { return m_count; }

int Material3CarouselView::layout() const { return m_layout; }

void Material3CarouselView::setLayout(int layout) {
    if (m_layout == layout) {
        return;
    }
    m_layout = layout;
    const QPointer<Material3CarouselView> guard(this);
    cancelSnapAnimation();
    if (m_completed && m_count > 0 && !m_pending_index) m_pending_index = m_current_index;
    updateLayout();
    if (!guard) return;
    completeKeyboardNavigation();
    if (guard) Q_EMIT layoutChanged();
}

int Material3CarouselView::orientation() const { return static_cast<int>(m_orientation); }

void Material3CarouselView::setOrientation(int orientation) {
    const auto o = orientation == Qt::Vertical ? Qt::Vertical : Qt::Horizontal;
    if (m_orientation == o) {
        return;
    }
    m_orientation = o;
    const QPointer<Material3CarouselView> guard(this);
    cancelSnapAnimation();
    if (m_completed && m_count > 0 && !m_pending_index) m_pending_index = m_current_index;
    if (auto flick = asFlickable(m_flickable)) {
        flick->setContentWidth(o == Qt::Horizontal ? m_content_width : width());
        if (! guard) return;
        flick->setContentHeight(o == Qt::Vertical ? m_content_height : height());
        if (! guard) return;
    }
    updateLayout();
    if (!guard) return;
    completeKeyboardNavigation();
    if (guard) Q_EMIT orientationChanged();
}

qreal Material3CarouselView::itemExtent() const { return m_item_extent; }

void Material3CarouselView::setItemExtent(qreal extent) {
    if (qFuzzyCompare(m_item_extent, extent)) {
        return;
    }
    m_item_extent = extent;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT itemExtentChanged();
}

qreal Material3CarouselView::minSmallItemWidth() const { return m_min_small_item_width; }

void Material3CarouselView::setMinSmallItemWidth(qreal width) {
    if (qFuzzyCompare(m_min_small_item_width, width)) {
        return;
    }
    m_min_small_item_width = width;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT minSmallItemWidthChanged();
}

qreal Material3CarouselView::maxSmallItemWidth() const { return m_max_small_item_width; }

void Material3CarouselView::setMaxSmallItemWidth(qreal width) {
    if (qFuzzyCompare(m_max_small_item_width, width)) {
        return;
    }
    m_max_small_item_width = width;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT maxSmallItemWidthChanged();
}

bool Material3CarouselView::itemSnapping() const { return m_item_snapping; }

void Material3CarouselView::setItemSnapping(bool snapping) {
    if (m_item_snapping == snapping) {
        return;
    }
    m_item_snapping = snapping;
    Q_EMIT itemSnappingChanged();
}

int Material3CarouselView::currentIndex() const { return m_current_index; }

void Material3CarouselView::setCurrentIndex(int index) {
    if (m_destroying) return;
    const QPointer<Material3CarouselView> guard(this);
    const auto                   revision = ++m_revision;
    m_pending_index                       = qMax(0, index);
    cancelSnapAnimation();
    updateCurrentIndex(m_count > 0 ? qBound(0, index, m_count - 1) : 0);
    if (guard && revision == m_revision) updateLayout();
}

void Material3CarouselView::updateCurrentIndex(int index) {
    const bool changed    = m_current_index != index;
    m_current_index       = index;
    m_current_model_index = m_item_model && m_count > 0
                                ? QPersistentModelIndex(m_item_model->index(index, 0))
                                : QPersistentModelIndex();
    if (changed) Q_EMIT currentIndexChanged();
}

int Material3CarouselView::initialItem() const { return m_initial_item; }

void Material3CarouselView::setInitialItem(int item) {
    if (m_initial_item == item) {
        return;
    }
    m_initial_item = item;
    Q_EMIT initialItemChanged();
}

qreal Material3CarouselView::spacing() const { return m_spacing; }

void Material3CarouselView::setSpacing(qreal spacing) {
    if (qFuzzyCompare(m_spacing, spacing)) {
        return;
    }
    m_spacing = spacing;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT spacingChanged();
}

qreal Material3CarouselView::contentPaddingStart() const { return m_content_padding_start; }

void Material3CarouselView::setContentPaddingStart(qreal padding) {
    if (qFuzzyCompare(m_content_padding_start, padding)) {
        return;
    }
    m_content_padding_start = padding;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT contentPaddingChanged();
}

qreal Material3CarouselView::contentPaddingEnd() const { return m_content_padding_end; }

void Material3CarouselView::setContentPaddingEnd(qreal padding) {
    if (qFuzzyCompare(m_content_padding_end, padding)) {
        return;
    }
    m_content_padding_end = padding;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT contentPaddingChanged();
}

qreal Material3CarouselView::contentPaddingCross() const { return m_content_padding_cross; }

void Material3CarouselView::setContentPaddingCross(qreal padding) {
    if (qFuzzyCompare(m_content_padding_cross, padding)) {
        return;
    }
    m_content_padding_cross = padding;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT contentPaddingCrossChanged();
}

bool Material3CarouselView::clipContainer() const { return m_clip_container; }

void Material3CarouselView::setClipContainer(bool clip) {
    if (m_clip_container == clip) {
        return;
    }
    m_clip_container = clip;
    const QPointer<Material3CarouselView> guard(this);
    setClip(clip);
    if (! guard) return;
    if (auto flick = asFlickable(m_flickable)) {
        // Viewport always clips so uncontained items slide off edges instead of
        // shrinking via per-item mask.
        flick->setClip(true);
    }
    if (! guard) return;
    if (guard) Q_EMIT clipContainerChanged();
}

bool Material3CarouselView::reduceMotion() const { return m_reduce_motion; }

void Material3CarouselView::setReduceMotion(bool reduce) {
    if (m_reduce_motion == reduce) {
        return;
    }
    m_reduce_motion = reduce;
    const QPointer<Material3CarouselView> guard(this);
    if (reduce && m_snapping) {
        const auto *animation = qobject_cast<QPropertyAnimation *>(m_snap_anim);
        applySnapAnimation(animation ? animation->endValue().toReal() : m_snap_target);
        if (!guard) return;
    }
    Q_EMIT reduceMotionChanged();
    if (guard) updateLayout();
}

qreal Material3CarouselView::itemCornerRadius() const { return m_item_corner_radius; }

void Material3CarouselView::setItemCornerRadius(qreal radius) {
    if (qFuzzyCompare(m_item_corner_radius, radius)) {
        return;
    }
    m_item_corner_radius = radius;
    const QPointer<Material3CarouselView> guard(this);
    updateLayout();
    if (guard) Q_EMIT itemCornerRadiusChanged();
}

bool Material3CarouselView::interactive() const { return m_interactive; }

void Material3CarouselView::setInteractive(bool interactive) {
    if (m_interactive == interactive) {
        return;
    }
    m_interactive = interactive;
    const QPointer<Material3CarouselView> guard(this);
    if (auto flick = asFlickable(m_flickable)) {
        flick->setInteractive(interactive);
    }
    if (guard) Q_EMIT interactiveChanged();
}

qreal Material3CarouselView::contentWidth() const { return m_content_width; }
qreal Material3CarouselView::contentHeight() const { return m_content_height; }

QQuickItem* Material3CarouselView::flickable() const { return m_flickable; }

void Material3CarouselView::setWheelNavigationEnabled(bool value) {
    if (std::exchange(m_wheelNavigationEnabled, value) != value)
        Q_EMIT wheelNavigationEnabledChanged();
}
void Material3CarouselView::setWheelRequiresShift(bool value) {
    if (std::exchange(m_wheelRequiresShift, value) != value) Q_EMIT wheelRequiresShiftChanged();
}
bool Material3CarouselView::eventFilter(QObject* target, QEvent* event) {
    if (auto *item = qobject_cast<QQuickItem *>(target); ownsDelegate(item)) {
        if (event->type() == QEvent::KeyPress && item->isEnabled()) {
            const auto key = static_cast<QKeyEvent *>(event)->key();
            const bool horizontal = m_orientation == Qt::Horizontal;
            const int previous = horizontal ? (m_mirrored ? Qt::Key_Right : Qt::Key_Left) : Qt::Key_Up;
            const int next = horizontal ? (m_mirrored ? Qt::Key_Left : Qt::Key_Right) : Qt::Key_Down;
            if (key == previous || key == next) {
                event->accept();
                if (key == previous) decrementCurrentIndexFromKeyboard();
                else incrementCurrentIndexFromKeyboard();
                return true;
            }
        } else if (event->type() == QEvent::MouseButtonPress) {
            const QPointer<Material3CarouselView> guard(this);
            const QPointer<QQuickItem> source(item);
            claimInteractionFocus();
            if (!guard || !source) return true;
        }
    }

    if (target != m_flickable || event->type() != QEvent::Wheel || ! m_wheelNavigationEnabled)
        return QQuickItem::eventFilter(target, event);
    auto* wheel   = static_cast<QWheelEvent*>(event);
    auto  delta   = wheel->angleDelta();
    int   advance = std::abs(delta.y()) >= std::abs(delta.x()) ? delta.y() : delta.x();
    if (wheel->inverted()) advance = -advance;
    if (! isEnabled() || ! isVisible() || ! m_interactive || m_count <= 1 || advance == 0 ||
        (m_wheelRequiresShift && ! (wheel->modifiers() & Qt::ShiftModifier))) {
        event->ignore();
        return true;
    }
    // Accept before focus/index callbacks, which may synchronously delete this view.
    event->accept();
    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;
    const auto                   revision      = m_revision;
    const auto                   requiresShift = m_wheelRequiresShift;
    claimInteractionFocus();
    if (! guard || configuration != m_configurationRevision || revision != m_revision ||
        ! m_wheelNavigationEnabled || requiresShift != m_wheelRequiresShift || ! isEnabled() ||
        ! isVisible() || ! m_interactive)
        return true;
    if (advance > 0)
        incrementCurrentIndex();
    else
        decrementCurrentIndex();
    return true;
}

void Material3CarouselView::incrementCurrentIndex() {
    if (m_count <= 0) {
        return;
    }
    setCurrentIndexAnimated(qMin(m_count - 1, m_current_index + 1));
}

void Material3CarouselView::decrementCurrentIndex() {
    if (m_count <= 0) {
        return;
    }
    setCurrentIndexAnimated(qMax(0, m_current_index - 1));
}

void Material3CarouselView::incrementCurrentIndexFromKeyboard() {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   request = m_configurationRevision;
    m_keyboard_nav_pending = true;
    incrementCurrentIndex();
    if (guard && request == m_configurationRevision) completeKeyboardNavigation();
}

void Material3CarouselView::decrementCurrentIndexFromKeyboard() {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   request = m_configurationRevision;
    m_keyboard_nav_pending = true;
    decrementCurrentIndex();
    if (guard && request == m_configurationRevision) completeKeyboardNavigation();
}

bool Material3CarouselView::ownsDelegate(const QQuickItem* item) const {
    return ! m_destroying && item && item->parentItem() == m_content &&
           std::any_of(m_items.cbegin(), m_items.cend(), [item](const auto& candidate) {
               return candidate.data() == item;
           });
}
void Material3CarouselView::focusCurrentItem() { focusCurrentItem(Qt::OtherFocusReason); }
void Material3CarouselView::focusCurrentItem(Qt::FocusReason reason) {
    if (m_current_index < 0 || m_current_index >= m_items.size()) {
        return;
    }
    if (const auto item = m_items.at(m_current_index);
        item && item->isEnabled() && item->isVisible()) {
        item->forceActiveFocus(reason);
    }
}

void Material3CarouselView::claimInteractionFocus() {
    focusCurrentItem();
}

void Material3CarouselView::completeKeyboardNavigation() {
    if (! m_keyboard_nav_pending || m_snapping) {
        return;
    }
    m_keyboard_nav_pending = false;
    focusCurrentItem(Qt::TabFocusReason);
}

void Material3CarouselView::setCurrentIndexAnimated(int index) {
    if (m_destroying) return;
    const int clamped = m_count > 0 ? qBound(0, index, m_count - 1) : 0;
    if (! m_flickable || m_snap_offsets.isEmpty() || width() <= 0 || height() <= 0) {
        setCurrentIndex(index);
        return;
    }
    ++m_revision;
    m_pending_index.reset();
    qreal target = 0;
    if (clamped == 0) {
        target = 0;
    } else if (clamped == m_count - 1) {
        target = m_end_snap_offset;
    } else if (clamped >= 0 && clamped < m_snap_offsets.size()) {
        target = m_snap_offsets.at(clamped);
    }
    applySnapAnimation(target);
}

void Material3CarouselView::componentComplete() {
    QQuickItem::componentComplete();
    ensureItemQmlContext(this, m_flickable);
    ensureItemQmlContext(this, m_content);
    if (! m_pending_index) m_pending_index = qMax(0, m_initial_item);
    m_completed = true;
    setClip(m_clip_container);
    if (auto flick = asFlickable(m_flickable)) {
        flick->setInteractive(m_interactive);
        flick->setClip(true);
    }
    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;
    updateCount();
    if (! guard || configuration != m_configurationRevision) return;
    syncCurrentIndexAfterCountChange();
    if (! guard || configuration != m_configurationRevision) return;
    rebuildItems();
}

void Material3CarouselView::geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) {
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    const QPointer<Material3CarouselView> guard(this);
    if (auto flick = asFlickable(m_flickable); newGeometry.size() != oldGeometry.size() && flick &&
                                                ! m_pending_index && ! flick->isMoving() &&
                                                ! m_snapping && ! m_snap_offsets.isEmpty()) {
        const qreal offset =
            m_orientation == Qt::Horizontal ? flick->contentX() : flick->contentY();
        const qreal snapped = m_current_index == m_count - 1
                                  ? m_end_snap_offset
                                  : m_snap_offsets.value(m_current_index);
        if (qAbs(offset - snapped) < 0.01) m_pending_index = m_current_index;
    }
    if (m_flickable) {
        m_flickable->setWidth(newGeometry.width());
        if (! guard) return;
        m_flickable->setHeight(newGeometry.height());
        if (! guard) return;
    }
    updateLayout();
}

void Material3CarouselView::itemChange(ItemChange change, const ItemChangeData& value) {
    QQuickItem::itemChange(change, value);
    if (change == ItemEnabledHasChanged && m_flickable) {
        m_flickable->setEnabled(value.boolValue);
    }
}

void Material3CarouselView::updateCount() {
    int new_count = 0;
    if (m_model.userType() == QMetaType::Int || m_model.userType() == QMetaType::UInt ||
        m_model.userType() == QMetaType::LongLong) {
        new_count = m_model.toInt();
    } else if (auto* model = modelAsItemModel(m_model)) {
        new_count = model->rowCount();
    } else {
        new_count = modelArrayLength(m_model);
    }
    new_count = qMax(0, new_count);
    if (new_count != m_count) {
        m_count = new_count;
        Q_EMIT countChanged();
    }
}

void Material3CarouselView::unbindItemModel() {
    m_current_model_index = QPersistentModelIndex {};
    if (! m_item_model) {
        return;
    }
    disconnect(m_item_model, nullptr, this, nullptr);
    m_item_model = nullptr;
}

void Material3CarouselView::bindItemModel(QAbstractItemModel* model) {
    if (! model) {
        return;
    }
    m_item_model = model;
    connect(model, &QAbstractItemModel::rowsInserted, this, &Material3CarouselView::onModelRowsChanged);
    connect(model, &QAbstractItemModel::rowsRemoved, this, &Material3CarouselView::onModelRowsChanged);
    connect(model, &QAbstractItemModel::rowsMoved, this, &Material3CarouselView::onModelRowsChanged);
    connect(model, &QAbstractItemModel::modelReset, this, &Material3CarouselView::onModelRowsChanged);
    connect(model, &QAbstractItemModel::layoutChanged, this, &Material3CarouselView::onModelRowsChanged);
    connect(model, &QAbstractItemModel::dataChanged, this, &Material3CarouselView::onModelDataChanged);
    connect(model, &QObject::destroyed, this, [this] { setModel({}); });
}

void Material3CarouselView::onModelRowsChanged() {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   request = ++m_configurationRevision;
    updateCount();
    if (! guard || request != m_configurationRevision) return;
    const int logical_row = (! m_pending_index || *m_pending_index == m_current_index) &&
                                    m_current_model_index.isValid()
                                ? m_current_model_index.row()
                                : -1;
    if (logical_row >= 0 && (m_completed || m_pending_index)) m_pending_index = logical_row;
    rebuildItems();
    if (! guard || request != m_configurationRevision) return;
    if (logical_row >= 0 && ! m_completed && ! m_pending_index)
        updateCurrentIndex(logical_row);
    else
        syncCurrentIndexAfterCountChange();
}

void Material3CarouselView::onModelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight,
                                      const QList<int>& roles) {
    Q_UNUSED(roles);
    if (! m_completed || ! m_delegate) {
        return;
    }
    const int                    first = topLeft.row();
    const int                    last  = bottomRight.row();
    const QPointer<Material3CarouselView> guard(this);
    const auto                   revision = m_configurationRevision;
    for (int i = first; i <= last && i < m_items.size(); ++i) {
        if (m_items[i]) {
            applyDelegateProperties(m_items[i], i);
            if (! guard || revision != m_configurationRevision) return;
        }
    }
}

void Material3CarouselView::syncCurrentIndexAfterCountChange() {
    if (m_pending_index) {
        updateCurrentIndex(m_count > 0 ? qBound(0, *m_pending_index, m_count - 1) : 0);
        return;
    }
    if (! m_completed) {
        updateCurrentIndex(m_count > 0 ? qBound(0, m_current_index, m_count - 1) : 0);
        return;
    }
    if (m_count <= 0) {
        m_current_model_index = QPersistentModelIndex {};
        if (m_current_index != 0) {
            m_current_index = 0;
            Q_EMIT currentIndexChanged();
        }
        return;
    }
    setCurrentIndex(qBound(0, m_current_index, m_count - 1));
}

void Material3CarouselView::clearLayout() {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   revision = ++m_revision;
    const auto                   valid    = [&] {
        return guard && revision == m_revision;
    };
    m_geometries.clear();
    m_snap_offsets.clear();
    m_max_scroll_offset = 0;
    m_end_snap_offset   = 0;
    m_scroll_step       = 0;

    const qreal new_w = m_orientation == Qt::Horizontal ? width() : 0;
    const qreal new_h = m_orientation == Qt::Vertical ? height() : 0;
    if (! qFuzzyCompare(m_content_width, new_w)) {
        m_content_width = new_w;
        Q_EMIT contentWidthChanged();
        if (! valid()) return;
    }
    if (! qFuzzyCompare(m_content_height, new_h)) {
        m_content_height = new_h;
        Q_EMIT contentHeightChanged();
        if (! valid()) return;
    }

    if (auto flick = asFlickable(m_flickable)) {
        m_updating = true;
        flick->setContentWidth(m_orientation == Qt::Horizontal ? m_content_width : width());
        if (! valid()) return;
        flick->setContentHeight(m_orientation == Qt::Vertical ? m_content_height : height());
        if (! valid()) return;
        if (m_orientation == Qt::Horizontal) {
            flick->setContentX(0);
        } else {
            flick->setContentY(0);
        }
        if (! valid()) return;
        m_updating = false;
    }

    const auto items = m_items;
    for (const auto& item : items) {
        if (item) {
            item->setVisible(false);
            if (! valid()) return;
        }
    }

    if (m_current_index != 0) {
        m_current_index = 0;
        Q_EMIT currentIndexChanged();
        if (! valid()) return;
    }
    m_current_model_index = QPersistentModelIndex {};
}

void Material3CarouselView::cancelSnapAnimation() {
    if (m_snap_timer) {
        m_snap_timer->stop();
    }
    if (m_snap_anim) {
        if (auto* anim = qobject_cast<QPropertyAnimation*>(m_snap_anim)) {
            anim->stop();
        }
        m_snap_anim->deleteLater();
        m_snap_anim = nullptr;
    }
    m_snapping = false;
}

QVariant Material3CarouselView::modelDataAt(int index) const {
    if (m_model.userType() == QMetaType::Int || m_model.userType() == QMetaType::UInt ||
        m_model.userType() == QMetaType::LongLong) {
        return index;
    }
    return modelElementAt(m_model, index);
}

QVariantMap Material3CarouselView::initialPropertiesForDelegate(int index) const {
    QVariantMap initial;
    initial[QStringLiteral("index")] = index;

    const QVariant row = modelDataAt(index);
    initial[QStringLiteral("modelData")] = row;
    if (auto* engine = qmlEngine(this)) {
        initial[QStringLiteral("model")] = QVariant::fromValue(engine->toScriptValue(row));
    } else {
        initial[QStringLiteral("model")] = row;
    }

    // Public Qt metadata does not expose QML required-role flags; roles stay in model/modelData.
    return initial;
}

void Material3CarouselView::applyDelegateProperties(QQuickItem* item, int index) {
    if (! item) {
        return;
    }
    const auto                   initial = requestedDelegateProperties(item, initialPropertiesForDelegate(index));
    const QPointer<Material3CarouselView> guard(this);
    const QPointer<QQuickItem>   target(item);
    const auto                   revision = m_configurationRevision;
    for (auto it = initial.cbegin(); it != initial.cend(); ++it) {
        item->setProperty(it.key().toUtf8().constData(), it.value());
        if (! guard || ! target || revision != m_configurationRevision || ! ownsDelegate(target))
            return;
    }
}

void Material3CarouselView::createDelegate(int index) {
    if (! m_delegate || index < 0 || index >= m_count) {
        return;
    }
    while (m_items.size() <= index) {
        m_items.append(nullptr);
    }
    if (m_items[index]) {
        const qreal aspect = m_items[index]->property("itemAspectRatio").toDouble();
        if (aspect > 0) {
            while (m_item_aspects.size() < m_count) {
                m_item_aspects.append(1.0);
            }
            if (! qFuzzyCompare(m_item_aspects[index], aspect)) {
                m_item_aspects[index] = aspect;
                updateLayout();
            }
        }
        return;
    }

    QQmlContext* ctx = m_delegate->creationContext();
    if (! ctx) {
        if (QQmlEngine* engine = m_delegate->engine()) {
            ctx = engine->rootContext();
        } else if (QQmlEngine* engine = qmlEngine(this)) {
            ctx = engine->rootContext();
        }
    }
    if (! ctx) {
        return;
    }
    const QPointer<Material3CarouselView>  guard(this);
    const QPointer<QQmlComponent> component(m_delegate);
    const auto                    revision = m_revision;
    QPointer<QObject> obj = component->beginCreate(ctx);
    if (obj && component) {
        if (auto *visual = qobject_cast<QQuickItem *>(obj.data())) {
            visual->setParent(m_content);
            visual->setParentItem(m_content);
        }
        if (guard && component && obj && revision == m_revision) {
            const auto values = requestedDelegateProperties(obj, initialPropertiesForDelegate(index));
            component->setInitialProperties(obj, values);
        }
    }
    if (component) component->completeCreate();
    if (! guard || ! component || revision != m_revision || component != m_delegate) {
        if (obj) obj->deleteLater();
        return;
    }
    if (! obj) {
        qmlWarning(this) << "Failed to create carousel delegate:" << m_delegate->errorString();
        return;
    }
    auto* item = qobject_cast<QQuickItem*>(obj.data());
    if (! item) {
        qmlWarning(this) << "Carousel delegate must create a QQuickItem";
        delete obj.data();
        return;
    }
    const QPointer<QQuickItem> target(item);
    item->setParent(m_content);
    if (! guard || ! target || revision != m_revision) {
        retireDelegate(target);
        return;
    }
    item->setParentItem(m_content);
    if (! guard || ! target || revision != m_revision) {
        retireDelegate(target);
        return;
    }

    m_items[index] = item;
    item->installEventFilter(this);
    if (item->metaObject()->indexOfSignal("clicked()") >= 0)
        connect(item, SIGNAL(clicked()), this, SLOT(onDelegateClicked()));
    if (item->metaObject()->indexOfSignal("itemAspectRatioChanged()") >= 0) {
        connect(item, SIGNAL(itemAspectRatioChanged()), this, SLOT(onDelegateAspectRatioChanged()));
    } else if (item->metaObject()->indexOfSignal("aspectRatioChanged()") >= 0) {
        connect(item, SIGNAL(aspectRatioChanged()), this, SLOT(onDelegateAspectRatioChanged()));
    }
}

void Material3CarouselView::onDelegateAspectRatioChanged() {
    auto* item = qobject_cast<QQuickItem*>(sender());
    if (! item) {
        return;
    }
    const int index = m_items.indexOf(item);
    if (index < 0 || index >= m_count) {
        return;
    }
    const qreal aspect = item->property("itemAspectRatio").toDouble();
    if (aspect <= 0) {
        return;
    }
    while (m_item_aspects.size() < m_count) {
        m_item_aspects.append(1.0);
    }
    if (qFuzzyCompare(m_item_aspects[index], aspect)) {
        return;
    }
    m_item_aspects[index] = aspect;
    updateLayout();
}

void Material3CarouselView::retireDelegate(QPointer<QQuickItem> item) {
    if (item) item->setVisible(false);
    if (item) item->setEnabled(false);
    if (item) item->setParentItem(nullptr);
    if (item) item->deleteLater();
}

void Material3CarouselView::rebuildItems() {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;
    ++m_revision;
    cancelSnapAnimation();
    m_keyboard_nav_pending = false;
    const auto retired     = std::exchange(m_items, {});
    m_items.resize(m_count);
    m_item_aspects.resize(m_count);
    m_item_aspects.fill(1.0);
    // Invalidate every old member before cancellation can reenter the view.
    for (const auto& item : retired)
        if (item) disconnect(item, nullptr, this, nullptr);
    for (const auto& item : retired) retireDelegate(item);
    if (! guard || configuration != m_configurationRevision) return;
    updateLayout();
}

void Material3CarouselView::positionItem(QQuickItem* item, const CarouselItemGeometry& geom, bool isActive) {
    if (! item) {
        return;
    }
    const QPointer<Material3CarouselView> guard(this);
    const QPointer<QQuickItem>   target(item);
    const auto                   revision = m_revision;
    const auto                   valid    = [&] {
        return guard && target && revision == m_revision;
    };
    const qreal cross = qMax(0.0,
                             (m_orientation == Qt::Horizontal ? height() : width()) -
                                 2.0 * m_content_padding_cross);

    if (m_orientation == Qt::Horizontal) {
        item->setX(geom.position);
        if (! valid()) return;
        item->setY(m_content_padding_cross);
        if (! valid()) return;
        item->setWidth(geom.size);
        if (! valid()) return;
        item->setHeight(cross);
    } else {
        item->setX(m_content_padding_cross);
        if (! valid()) return;
        item->setY(geom.position);
        if (! valid()) return;
        item->setWidth(cross);
        if (! valid()) return;
        item->setHeight(geom.size);
    }
    if (! valid()) return;

    item->setZ(geom.index);
    if (! valid()) return;
    const bool mirrored = m_mirrored && m_orientation == Qt::Horizontal;
    auto       mirror   = m_itemMirrors.value(item);
    if (mirrored && ! mirror) {
        mirror = new CarouselScale(item);
        mirror->appendToItem(item);
        m_itemMirrors.insert(item, mirror);
        connect(item, &QObject::destroyed, this, [this, item] {
            m_itemMirrors.remove(item);
        });
    }
    if (mirror) {
        mirror->setOrigin(QVector3D(item->width() / 2, 0, 0));
        mirror->setXScale(mirrored ? -1 : 1);
    }

    auto* attached =
        qobject_cast<Material3CarouselAttached*>(qmlAttachedPropertiesObject<Material3CarouselView>(item, true));
    if (attached) {
        attached->setGeometry(geom.size,
                              cross,
                              mirrored ? geom.mask_end : geom.mask_start,
                              mirrored ? geom.mask_start : geom.mask_end,
                              mirrored ? -geom.parallax_shift : geom.parallax_shift,
                              geom.size_class,
                              geom.index,
                              isActive);
    }
}

int Material3CarouselView::activeIndexForLayout(const CarouselLayoutOutput& out) const {
    if (m_layout == CarouselLayoutId::FullScreen) {
        return out.leading_index;
    }

    int   best_index = out.leading_index;
    qreal best_frac  = -1.0;
    for (const auto& g : out.items) {
        if (g.mask_start > 0.001) {
            continue;
        }
        const qreal frac = qMax(0.0, 1.0 - g.mask_start - g.mask_end);
        if (frac > best_frac + 0.001 || (qFuzzyCompare(frac, best_frac) && g.index < best_index)) {
            best_frac  = frac;
            best_index = g.index;
        }
    }
    return best_index;
}

void Material3CarouselView::updateLayout() {
    if (m_destroying || ! m_completed || ! m_flickable) {
        return;
    }
    if (m_count <= 0) {
        clearLayout();
        return;
    }
    // A logical request must survive completion before the parent has laid us out.
    if (width() <= 0 || height() <= 0) return;
    const bool mirrored = m_mirrored && m_orientation == Qt::Horizontal;
    if (mirrored && ! m_viewMirror) {
        m_viewMirror = new CarouselScale(m_flickable);
        m_viewMirror->appendToItem(m_flickable);
    }
    if (m_viewMirror) {
        m_viewMirror->setOrigin(QVector3D(width() / 2, 0, 0));
        m_viewMirror->setXScale(mirrored ? -1 : 1);
    }
    const QPointer<Material3CarouselView> guard(this);
    const auto                   revision = ++m_revision;
    const auto                   valid    = [&] {
        return guard && revision == m_revision;
    };

    CarouselLayoutInput input;
    input.layout        = m_layout;
    input.orientation   = m_orientation;
    input.viewport_size = m_orientation == Qt::Horizontal ? width() : height();
    input.cross_size    = m_orientation == Qt::Horizontal ? height() : width();
    auto flick         = asFlickable(m_flickable);
    input.scroll_offset =
        flick ? (m_orientation == Qt::Horizontal ? flick->contentX() : flick->contentY()) : 0;
    input.item_extent           = m_item_extent;
    input.spacing               = m_spacing;
    input.content_padding_start = m_content_padding_start;
    input.content_padding_end   = m_content_padding_end;
    input.content_padding_cross = m_content_padding_cross;
    input.small_item_min        = m_min_small_item_width;
    input.small_item_max        = m_max_small_item_width;
    input.min_peek_px           = CarouselEngineDefaults::min_peek_px;
    input.min_item_aspect       = CarouselEngineDefaults::min_item_aspect;
    input.max_item_aspect       = CarouselEngineDefaults::max_item_aspect;
    input.item_corner_radius    = m_item_corner_radius;
    input.parallax_ratio =
        m_layout == CarouselLayoutId::FullScreen
            ? 0
            : (m_reduce_motion ? 0
                               : (m_layout == CarouselLayoutId::Uncontained ||
                                          m_layout == CarouselLayoutId::UncontainedMultiAspect
                                      ? CarouselEngineDefaults::parallax_ratio_uncontained
                                      : CarouselEngineDefaults::parallax_ratio));
    input.count         = m_count;
    input.reduce_motion = m_reduce_motion;
    input.item_aspects  = m_item_aspects;
    while (input.item_aspects.size() < m_count) {
        input.item_aspects.append(1.0);
    }

    auto out = CarouselStrategy::compute(input);
    if (m_pending_index) {
        const int index = qBound(0, *m_pending_index, m_count - 1);
        input.scroll_offset =
            qBound(0.0,
                   index == m_count - 1 ? out.end_snap_offset : out.snap_offsets.value(index),
                   out.max_scroll_offset);
        out = CarouselStrategy::compute(input);
        updateCurrentIndex(index);
        if (! valid()) return;
    }
    m_geometries        = out.items;
    m_snap_offsets      = out.snap_offsets;
    m_max_scroll_offset = out.max_scroll_offset;
    m_end_snap_offset   = out.end_snap_offset;
    m_scroll_step       = out.scroll_step > 0 ? out.scroll_step : (m_item_extent + m_spacing);

    const qreal new_w = m_orientation == Qt::Horizontal ? out.content_size : width();
    const qreal new_h = m_orientation == Qt::Vertical ? out.content_size : height();
    if (! qFuzzyCompare(m_content_width, new_w)) {
        m_content_width = new_w;
        Q_EMIT contentWidthChanged();
        if (! valid()) return;
    }
    if (! qFuzzyCompare(m_content_height, new_h)) {
        m_content_height = new_h;
        Q_EMIT contentHeightChanged();
        if (! valid()) return;
    }

    m_updating = true;
    if (flick) {
        flick->setContentWidth(m_orientation == Qt::Horizontal ? m_content_width : width());
        if (! valid()) return;
        flick->setContentHeight(m_orientation == Qt::Vertical ? m_content_height : height());
        if (! valid()) return;

        if (m_pending_index) {
            if (m_orientation == Qt::Horizontal)
                flick->setContentX(input.scroll_offset);
            else
                flick->setContentY(input.scroll_offset);
            if (! valid()) return;
        }

        const qreal viewport = m_orientation == Qt::Horizontal ? width() : height();
        const qreal max_offset =
            m_max_scroll_offset > 0
                ? m_max_scroll_offset
                : qMax(0.0,
                       (m_orientation == Qt::Horizontal ? m_content_width : m_content_height) -
                           viewport);
        const bool user_scrolling = flick->isMoving() || m_snapping;
        if (! user_scrolling) {
            if (m_orientation == Qt::Horizontal) {
                flick->setContentX(qBound(0.0, flick->contentX(), max_offset));
            } else {
                flick->setContentY(qBound(0.0, flick->contentY(), max_offset));
            }
        }
        if (! valid()) return;
    }
    m_updating = false;

    QSet<int> visible;
    const int active_index = activeIndexForLayout(out);
    for (const auto& g : out.items) {
        visible.insert(g.index);
        createDelegate(g.index);
        if (! valid()) return;
        positionItem(m_items[g.index], g, g.index == active_index);
        if (! valid()) return;
    }

    for (int i = 0; i < m_items.size(); ++i) {
        if (m_items[i]) {
            const QPointer<Material3CarouselAttached> attached = qobject_cast<Material3CarouselAttached*>(
                qmlAttachedPropertiesObject<Material3CarouselView>(m_items[i], true));
            if (attached) {
                attached->setContext(m_count, static_cast<int>(m_orientation), active_index);
                if (! valid()) return;
            }
        }
        if (! visible.contains(i) && m_items[i]) {
            m_items[i]->setVisible(false);
        } else if (m_items[i]) {
            m_items[i]->setVisible(true);
        }
        if (! valid()) return;
    }

    m_pending_index.reset();
    if (active_index != m_current_index && flick && (flick->isMoving() || m_snapping))
        updateCurrentIndex(active_index);
}

bool Material3CarouselView::usesSingleAdvanceFling() const {
    return m_layout == CarouselLayoutId::MultiBrowse || isHeroLayout(m_layout) ||
           m_layout == CarouselLayoutId::FullScreen;
}

bool Material3CarouselView::usesFreeScrollSnap() const {
    return m_layout == CarouselLayoutId::Uncontained ||
           m_layout == CarouselLayoutId::UncontainedMultiAspect;
}

int Material3CarouselView::snapIndexForFling(qreal offset, qreal velocity) const {
    if (usesSingleAdvanceFling() && qAbs(velocity) > 50) {
        if (isHeroCenterLayout(m_layout) && m_count >= 3 && m_snap_offsets.size() >= m_count &&
            velocity > 0) {
            const qreal end_mid =
                (m_snap_offsets.at(m_count - 2) + m_snap_offsets.at(m_count - 1)) * 0.5;
            if (m_current_index >= m_count - 2 && offset >= end_mid - 0.5) {
                return m_count - 1;
            }
        }
        return velocity > 0 ? qMin(m_count - 1, m_current_index + 1) : qMax(0, m_current_index - 1);
    }

    const qreal stride = m_scroll_step > 0 ? m_scroll_step : 1.0;
    const qreal end_zone =
        isHeroCenterLayout(m_layout) && m_count >= 3 && m_snap_offsets.size() >= m_count
            ? (m_snap_offsets.at(m_count - 2) + m_snap_offsets.at(m_count - 1)) * 0.5
            : m_max_scroll_offset - stride * 0.25;

    if (isHeroCenterLayout(m_layout)) {
        return snapIndexForOffset(offset);
    }

    if (offset >= end_zone) {
        return m_count > 0 ? m_count - 1 : 0;
    }

    if (qAbs(velocity) > 50) {
        if (velocity > 0 && offset >= m_max_scroll_offset - stride * 0.5) {
            return m_count > 0 ? m_count - 1 : 0;
        }
        int   best   = m_current_index;
        qreal best_d = std::numeric_limits<qreal>::max();
        for (int i = 0; i < m_snap_offsets.size(); ++i) {
            const qreal d = m_snap_offsets.at(i) - offset;
            if ((velocity > 0 && d > 0) || (velocity < 0 && d < 0)) {
                const qreal ad = qAbs(d);
                if (ad < best_d) {
                    best_d = ad;
                    best   = i;
                }
            }
        }
        if (best != m_current_index) {
            return best;
        }
    }
    return snapIndexForOffset(offset);
}

qreal Material3CarouselView::snapTargetForGesture(qreal offset, qreal velocity) const {
    if (isFullScreenLayout(m_layout) && m_count > 0 && ! m_snap_offsets.isEmpty()) {
        const int target_index =
            qAbs(velocity) > 50 ? snapIndexForFling(offset, velocity) : snapIndexForOffset(offset);
        const int clamped = qBound(0, target_index, m_snap_offsets.size() - 1);
        return m_snap_offsets.at(clamped);
    }

    if (isHeroCenterLayout(m_layout) && m_count >= 3 && m_snap_offsets.size() >= m_count) {
        const int target_index =
            qAbs(velocity) > 50 ? snapIndexForFling(offset, velocity) : snapIndexForOffset(offset);

        if (target_index == m_count - 1) {
            return m_end_snap_offset;
        }
        if (target_index >= 0 && target_index < m_snap_offsets.size()) {
            return m_snap_offsets.at(target_index);
        }
        return offset;
    }

    const qreal stride     = m_scroll_step > 0 ? m_scroll_step : 1.0;
    const qreal end_zone   = m_max_scroll_offset - stride * 0.25;
    const qreal start_zone = stride * 0.25;

    if (offset >= end_zone ||
        (qAbs(velocity) > 50 && velocity > 0 && offset >= m_max_scroll_offset - stride * 0.5)) {
        return m_end_snap_offset;
    }

    if (offset <= start_zone && velocity <= 50) {
        return 0;
    }

    const int best = snapIndexForFling(offset, velocity);
    if (best == m_count - 1) {
        return m_end_snap_offset;
    }
    if (best == 0) {
        return 0;
    }
    if (best >= 0 && best < m_snap_offsets.size()) {
        return m_snap_offsets.at(best);
    }
    return offset;
}

void Material3CarouselView::snapAfterGesture() {
    if (! m_flickable || m_snap_offsets.isEmpty()) {
        return;
    }
    auto flick = asFlickable(m_flickable);
    if (! flick) {
        return;
    }
    const qreal offset = m_orientation == Qt::Horizontal ? flick->contentX() : flick->contentY();
    const qreal velocity =
        m_orientation == Qt::Horizontal ? flick->horizontalVelocity() : flick->verticalVelocity();

    const qreal target = snapTargetForGesture(offset, velocity);
    applySnapAnimation(target);
}

int Material3CarouselView::snapIndexForOffset(qreal offset) const {
    if (isFullScreenLayout(m_layout) && m_count >= 2 && m_snap_offsets.size() >= m_count) {
        for (int i = 0; i < m_count - 1; ++i) {
            const qreal threshold = (m_snap_offsets.at(i) + m_snap_offsets.at(i + 1)) * 0.5;
            if (offset < threshold) {
                return i;
            }
        }
        return m_count - 1;
    }

    if (isHeroCenterLayout(m_layout) && m_count >= 3 && m_snap_offsets.size() >= m_count) {
        const qreal end_mid =
            (m_snap_offsets.at(m_count - 2) + m_snap_offsets.at(m_count - 1)) * 0.5;
        if (offset >= end_mid - 0.5) {
            return m_count - 1;
        }

        for (int i = 0; i < m_count - 1; ++i) {
            const qreal threshold = (m_snap_offsets.at(i) + m_snap_offsets.at(i + 1)) * 0.5;
            if (offset < threshold) {
                return i;
            }
        }
        return m_count - 1;
    }

    int   best   = m_current_index;
    qreal best_d = std::numeric_limits<qreal>::max();
    for (int i = 0; i < m_snap_offsets.size(); ++i) {
        const qreal d = qAbs(m_snap_offsets.at(i) - offset);
        if (d < best_d) {
            best_d = d;
            best   = i;
        }
    }
    return best;
}

void Material3CarouselView::applySnapAnimation(qreal targetOffset) {
    if (! m_flickable) {
        return;
    }
    auto flick = asFlickable(m_flickable);
    if (! flick) {
        return;
    }

    cancelSnapAnimation();
    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;

    const qreal clamped_target = qBound(0.0, targetOffset, m_max_scroll_offset);

    const qreal current = m_orientation == Qt::Horizontal ? flick->contentX() : flick->contentY();
    if (qFuzzyCompare(current, clamped_target)) {
        finishSnap(clamped_target);
        return;
    }

    if (m_reduce_motion) {
        m_updating = true;
        if (m_orientation == Qt::Horizontal) {
            flick->setContentX(clamped_target);
        } else {
            flick->setContentY(clamped_target);
        }
        if (! guard || configuration != m_configurationRevision) return;
        m_updating = false;
        finishSnap(clamped_target);
        return;
    }

    if (usesFreeScrollSnap()) {
        const QByteArray prop = m_orientation == Qt::Horizontal ? QByteArrayLiteral("contentX")
                                                                : QByteArrayLiteral("contentY");
        auto*            anim = new QPropertyAnimation(m_flickable.data(), prop, this);
        anim->setDuration(m_snapDuration);
        QEasingCurve easing(QEasingCurve::BezierSpline);
        easing.addCubicBezierSegment({0.1, 0.7}, {0.1, 1}, {1, 1});
        anim->setEasingCurve(easing);
        anim->setStartValue(current);
        anim->setEndValue(clamped_target);
        m_snap_anim = anim;
        m_snapping  = true;
        connect(anim, &QPropertyAnimation::finished, this, [this, clamped_target]() {
            m_snapping  = false;
            m_snap_anim = nullptr;
            finishSnap(clamped_target);
        });
        anim->start(QAbstractAnimation::DeleteWhenStopped);
        return;
    }

    m_snap_pos      = current;
    m_snap_velocity = 0;
    m_snap_target   = clamped_target;
    m_snapping      = true;
    m_snap_timer->start();
}

void Material3CarouselView::onSnapTick() {
    if (! m_flickable) {
        m_snap_timer->stop();
        m_snapping = false;
        return;
    }
    auto flick = asFlickable(m_flickable);
    if (! flick) {
        m_snap_timer->stop();
        m_snapping = false;
        return;
    }

    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;
    const qreal                  force =
        -kSnapStiffness * (m_snap_pos - m_snap_target) - kSnapDamping * m_snap_velocity;
    m_snap_velocity += force * kSnapDt;
    m_snap_pos += m_snap_velocity * kSnapDt;

    m_updating = true;
    if (m_orientation == Qt::Horizontal) {
        flick->setContentX(m_snap_pos);
    } else {
        flick->setContentY(m_snap_pos);
    }
    if (! guard || configuration != m_configurationRevision) return;
    m_updating = false;
    updateLayout();
    if (! guard || configuration != m_configurationRevision) return;

    if (qAbs(m_snap_pos - m_snap_target) < 0.5 && qAbs(m_snap_velocity) < 5.0) {
        m_snap_timer->stop();
        m_updating = true;
        if (m_orientation == Qt::Horizontal) {
            flick->setContentX(m_snap_target);
        } else {
            flick->setContentY(m_snap_target);
        }
        if (! guard || configuration != m_configurationRevision) return;
        m_updating = false;
        finishSnap(m_snap_target);
    }
}

void Material3CarouselView::finishSnap(qreal targetOffset) {
    const QPointer<Material3CarouselView> guard(this);
    const auto                   configuration = m_configurationRevision;
    m_snapping                                 = false;
    if (m_count > 0 && qAbs(targetOffset - m_end_snap_offset) < 1.0) {
        setCurrentIndex(m_count - 1);
    } else if (qAbs(targetOffset) < 1.0) {
        setCurrentIndex(0);
    } else {
        setCurrentIndex(snapIndexForOffset(targetOffset));
    }
    if (! guard || configuration != m_configurationRevision) return;
    updateLayout();
    if (guard) completeKeyboardNavigation();
}

void Material3CarouselView::setFlickable(QQuickItem *item) {
    if (m_flickable == item) return;
    if (m_flickable) disconnect(m_flickable, nullptr, this, nullptr);
    m_flickable = item;
    if (item) {
        item->installEventFilter(this);
        m_content = new QQuickItem(item->property("contentItem").value<QQuickItem *>());
        connect(item, SIGNAL(contentXChanged()), this, SLOT(onViewportChanged()));
        connect(item, SIGNAL(contentYChanged()), this, SLOT(onViewportChanged()));
        connect(item, SIGNAL(movementEnded()), this, SLOT(onMovementEnded()));
        connect(item, SIGNAL(movementStarted()), this, SLOT(onMovementStarted()));
    }
    emit flickableChanged();
}
void Material3CarouselView::onViewportChanged() { if (!m_updating) updateLayout(); }
void Material3CarouselView::onMovementEnded() { if (m_item_snapping && !m_snapping) snapAfterGesture(); }
void Material3CarouselView::onMovementStarted() { claimInteractionFocus(); }
void Material3CarouselView::onDelegateClicked() {
    auto *item = qobject_cast<QQuickItem *>(sender());
    if (ownsDelegate(item) && item->isEnabled() && item->isVisible()) emit clicked(m_items.indexOf(item));
}

} // namespace qavsi::material3::carousel
