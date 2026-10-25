#include "materialbuttonfeedback.h"

#include <QPainter>
#include <QPainterPath>
#include <algorithm>
#include <cmath>

MaterialButtonFeedback::MaterialButtonFeedback(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    setRenderTarget(QQuickPaintedItem::Image);
    setAcceptedMouseButtons(Qt::NoButton);
    connect(this, &MaterialButtonFeedback::appearanceChanged, this, [this] { update(); });
}

void MaterialButtonFeedback::paint(QPainter *painter)
{
    const QRectF container = boundingRect();
    if (container.isEmpty())
        return;
    const qreal radius = std::clamp(m_cornerRadius, qreal(0),
                                   std::min(container.width(), container.height()) / 2);
    QPainterPath mask;
    mask.addRoundedRect(container, radius, radius);

    const qreal pulse = std::clamp(m_rippleOpacity, qreal(0), qreal(1));
    const qreal baseAlpha = m_rippleColor.alphaF()
        * std::clamp(m_stateOpacity, qreal(0), qreal(1)) * (1 - pulse);
    if (baseAlpha > 0) {
        QColor stateColor = m_rippleColor;
        stateColor.setAlphaF(baseAlpha);
        painter->fillPath(mask, stateColor);
    }

    if (m_rippleOpacity > 0 && m_rippleProgress > 0 && m_rippleColor.isValid()) {
        const QPointF origin(std::clamp(m_rippleOrigin.x(), qreal(0), container.width()),
                             std::clamp(m_rippleOrigin.y(), qreal(0), container.height()));
        const qreal coverage = std::hypot(std::max(origin.x(), container.width() - origin.x()),
                                          std::max(origin.y(), container.height() - origin.y()));
        const qreal rippleRadius = coverage * std::clamp(m_rippleProgress, qreal(0), qreal(1));
        QColor color = m_rippleColor;
        // Resolve one state alpha: the ripple fades into hover/focus without stacking.
        color.setAlphaF(std::clamp(color.alphaF() * pulse / (1 - baseAlpha), qreal(0), qreal(1)));
        painter->save();
        painter->setClipPath(mask);
        painter->setPen(Qt::NoPen);
        painter->setBrush(color);
        painter->drawEllipse(container.topLeft() + origin, rippleRadius, rippleRadius);
        painter->restore();
    }
}
