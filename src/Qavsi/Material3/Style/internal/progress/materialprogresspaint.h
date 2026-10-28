// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

#include <QQuickPaintedItem>
#include <QtQml/qqmlregistration.h>

class MaterialProgressPaint : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool circular MEMBER m_circular NOTIFY appearanceChanged)
    Q_PROPERTY(bool indeterminate MEMBER m_indeterminate NOTIFY appearanceChanged)
    Q_PROPERTY(bool mirrored MEMBER m_mirrored NOTIFY appearanceChanged)
    Q_PROPERTY(qreal position MEMBER m_position NOTIFY appearanceChanged)
    Q_PROPERTY(qreal phase MEMBER m_phase NOTIFY appearanceChanged)
    Q_PROPERTY(qreal thickness MEMBER m_thickness NOTIFY appearanceChanged)
    Q_PROPERTY(qreal gap MEMBER m_gap NOTIFY appearanceChanged)
    Q_PROPERTY(qreal gapAngle MEMBER m_gapAngle NOTIFY appearanceChanged)
    Q_PROPERTY(qreal stopDiameter MEMBER m_stopDiameter NOTIFY appearanceChanged)
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY appearanceChanged)
    Q_PROPERTY(QColor trackColor MEMBER m_trackColor NOTIFY appearanceChanged)
public:
    explicit MaterialProgressPaint(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;
signals:
    void appearanceChanged();
private:
    bool m_circular = false;
    bool m_indeterminate = false;
    bool m_mirrored = false;
    qreal m_position = 0;
    qreal m_phase = 0;
    qreal m_thickness = 4;
    qreal m_gap = 4;
    qreal m_gapAngle = 8;
    qreal m_stopDiameter = 4;
    QColor m_color;
    QColor m_trackColor;
};
