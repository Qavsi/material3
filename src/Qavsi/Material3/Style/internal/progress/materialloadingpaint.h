// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

#include <QQuickPaintedItem>
#include <QtQml/qqmlregistration.h>

class MaterialLoadingPaint : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(qreal phase READ phase WRITE setPhase NOTIFY phaseChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal shapeSize READ shapeSize WRITE setShapeSize NOTIFY shapeSizeChanged)
public:
    explicit MaterialLoadingPaint(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;

    qreal phase() const { return m_phase; }
    void setPhase(qreal phase);
    QColor color() const { return m_color; }
    void setColor(const QColor &color);
    qreal shapeSize() const { return m_shapeSize; }
    void setShapeSize(qreal size);

signals:
    void phaseChanged();
    void colorChanged();
    void shapeSizeChanged();

private:
    Q_DISABLE_COPY_MOVE(MaterialLoadingPaint)
    qreal m_phase = 0;
    QColor m_color;
    qreal m_shapeSize = 40;
};
