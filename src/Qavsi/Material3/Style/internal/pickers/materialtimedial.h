// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 229bc3e64ff71f1ac88cf73e976637ffbcf7e33c.

#pragma once

#include <QQuickItem>
#include <QPointer>
#include <QVariant>
#include "materialtimestate.h"

namespace Qavsi::Material3
{
class MaterialTimeDial : public QQuickItem {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Qavsi::Material3::MaterialTimeState* time READ time WRITE setTime NOTIFY timeChanged FINAL)
    Q_PROPERTY(qreal handAngle READ handAngle NOTIFY metricsChanged FINAL)
    Q_PROPERTY(qreal handLength READ handLength NOTIFY metricsChanged FINAL)
    Q_PROPERTY(QVariantList labels READ labels NOTIFY metricsChanged FINAL)
    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged FINAL)
    Q_PROPERTY(qreal dialPadding READ dialPadding WRITE setDialPadding NOTIFY metricsChanged FINAL)
    Q_PROPERTY(qreal innerRadiusRatio READ innerRadiusRatio WRITE setInnerRadiusRatio NOTIFY metricsChanged FINAL)
    Q_PROPERTY(qreal selectorSize READ selectorSize WRITE setSelectorSize NOTIFY metricsChanged FINAL)
    Q_PROPERTY(qreal centerSize READ centerSize WRITE setCenterSize NOTIFY metricsChanged FINAL)
public:
    explicit MaterialTimeDial(QQuickItem* parent = nullptr);
    MaterialTimeState* time() const { return m_time; }
    void          setTime(MaterialTimeState*);
    qreal         handAngle() const;
    qreal         handLength() const;
    QVariantList  labels() const;
    bool          pressed() const { return m_active; }
    qreal         dialPadding() const { return m_dialPadding; }
    void          setDialPadding(qreal);
    qreal         innerRadiusRatio() const { return m_innerRadiusRatio; }
    void          setInnerRadiusRatio(qreal);
    qreal         selectorSize() const { return m_selectorSize; }
    void          setSelectorSize(qreal);
    qreal         centerSize() const { return m_centerSize; }
    void          setCenterSize(qreal);
    Q_SIGNAL void timeChanged();
    Q_SIGNAL void metricsChanged();
    Q_SIGNAL void pressedChanged();

protected:
    void geometryChange(const QRectF&, const QRectF&) override;
    void itemChange(ItemChange, const ItemChangeData&) override;
    void mousePressEvent(QMouseEvent*) override;
    void mouseMoveEvent(QMouseEvent*) override;
    void mouseReleaseEvent(QMouseEvent*) override;
    void mouseUngrabEvent() override;
    void touchEvent(QTouchEvent*) override;
    void touchUngrabEvent() override;
    void keyPressEvent(QKeyEvent*) override;

private:
    Q_DISABLE_COPY_MOVE(MaterialTimeDial)

    void                    setMetric(qreal& metric, qreal value);
    qreal                   radius() const;
    bool                    begin(const QPointF&);
    void                    update(const QPointF&, bool complete);
    void                    cancel();
    QPointer<MaterialTimeState> m_time;
    QMetaObject::Connection m_changed, m_destroyed, m_windowActive;
    QPointF                 m_start;
    bool                    m_active = false, m_moved = false, m_updating = false;
    int                     m_touchId  = -1;
    quint64                 m_revision = 0;
    qreal                   m_dialPadding = 0;
    qreal                   m_innerRadiusRatio = 0.66;
    qreal                   m_selectorSize = 0;
    qreal                   m_centerSize = 0;
};
} // namespace Qavsi::Material3
