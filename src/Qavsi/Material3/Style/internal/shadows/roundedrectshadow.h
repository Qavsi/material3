// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

#include <QColor>
#include <QQuickItem>
#include <QVector3D>
#include <QVector4D>
#include <QtQmlIntegration/qqmlintegration.h>

// Internal primitive; design tokens and animation policy belong to the kit.
class RoundedRectShadow : public QQuickItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(RoundedRectShadow)
    Q_PROPERTY(qreal elevation MEMBER m_elevation NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QVector4D cornerRadii MEMBER m_cornerRadii NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal ambientOpacity MEMBER m_ambientOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal spotOpacity MEMBER m_spotOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QVector3D lightDirection MEMBER m_lightDirection NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal lightRadius MEMBER m_lightRadius NOTIFY appearanceChanged FINAL)

public:
    explicit RoundedRectShadow(QQuickItem *parent = nullptr);

signals:
    void appearanceChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    qreal m_elevation = 0;
    QVector4D m_cornerRadii;
    QColor m_color = Qt::transparent;
    qreal m_ambientOpacity = 0;
    qreal m_spotOpacity = 0;
    QVector3D m_lightDirection = QVector3D(0, 0, 1);
    qreal m_lightRadius = 1;
};
