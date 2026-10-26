#pragma once

#include <QColor>
#include <QPointF>
#include <QQuickPaintedItem>
#include <QVector4D>
#include <QtQmlIntegration/qqmlintegration.h>

// Internal renderer; native AbstractButton continues to own input and focus.
class MaterialButtonFeedback : public QQuickPaintedItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(MaterialButtonFeedback)
    Q_PROPERTY(qreal cornerRadius MEMBER m_cornerRadius NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QVector4D cornerRadii MEMBER m_cornerRadii NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QPointF rippleOrigin MEMBER m_rippleOrigin NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal rippleProgress MEMBER m_rippleProgress NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal ripplePhase MEMBER m_ripplePhase NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal rippleOpacity MEMBER m_rippleOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(qreal stateOpacity MEMBER m_stateOpacity NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QColor rippleColor MEMBER m_rippleColor NOTIFY appearanceChanged FINAL)
    Q_PROPERTY(QColor sparkleColor MEMBER m_sparkleColor NOTIFY appearanceChanged FINAL)

public:
    explicit MaterialButtonFeedback(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;

signals:
    void appearanceChanged();

private:
    qreal m_cornerRadius = 0;
    QVector4D m_cornerRadii = QVector4D(-1, -1, -1, -1);
    QPointF m_rippleOrigin;
    qreal m_rippleProgress = 0;
    qreal m_ripplePhase = 0;
    qreal m_rippleOpacity = 0;
    qreal m_stateOpacity = 0;
    QColor m_rippleColor = Qt::transparent;
    QColor m_sparkleColor = Qt::transparent;
};
