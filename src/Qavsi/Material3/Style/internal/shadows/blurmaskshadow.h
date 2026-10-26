// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#pragma once

#include <QColor>
#include <QQuickItem>
#include <QVector4D>
#include <QtQmlIntegration/qqmlintegration.h>

// Internal Outer-only blurred rounded-rectangle shadow; motion and tokens stay in the kit.
class BlurMaskShadow : public QQuickItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(BlurMaskShadow)
    Q_PROPERTY(qreal sigma MEMBER m_sigma NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QVector4D cornerRadii MEMBER m_cornerRadii NOTIFY appearanceChanged FINAL)

public:
    explicit BlurMaskShadow(QQuickItem *parent = nullptr);

signals:
    void appearanceChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    qreal m_sigma = 0;
    QColor m_color = Qt::transparent;
    QVector4D m_cornerRadii;
};
