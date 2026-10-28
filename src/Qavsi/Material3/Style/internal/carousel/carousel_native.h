// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once
#include <QQuickItem>
#include <QPointer>
#include <QMatrix4x4>
#include <QVector3D>
#include <QVariant>
#include <optional>
namespace qavsi::material3::carousel {
struct NativeFlickable {
    QPointer<QQuickItem> item;
    qreal number(const char *name) const { return item ? item->property(name).toReal() : 0; }
    void assign(const char *name, qreal value) const { if (item) item->setProperty(name, value); }
    qreal contentX() const { return number("contentX"); }
    qreal contentY() const { return number("contentY"); }
    qreal horizontalVelocity() const { return number("horizontalVelocity"); }
    qreal verticalVelocity() const { return number("verticalVelocity"); }
    bool isMoving() const { return item && item->property("moving").toBool(); }
    void setContentX(qreal value) const { assign("contentX", value); }
    void setContentY(qreal value) const { assign("contentY", value); }
    void setContentWidth(qreal value) const { assign("contentWidth", value); }
    void setContentHeight(qreal value) const { assign("contentHeight", value); }
    void setInteractive(bool value) const { if (item) item->setProperty("interactive", value); }
    void setClip(bool value) const { if (item) item->setClip(value); }
};
class CarouselScale : public QQuickTransform {
public:
    using QQuickTransform::QQuickTransform;
    void setOrigin(QVector3D value) { if (m_origin != value) { m_origin = value; update(); } }
    void setXScale(qreal value) { if (m_scale != value) { m_scale = value; update(); } }
    void applyTo(QMatrix4x4 *matrix) const override {
        matrix->translate(m_origin); matrix->scale(m_scale, 1, 1); matrix->translate(-m_origin);
    }
private:
    QVector3D m_origin;
    qreal m_scale = 1;
};
}
