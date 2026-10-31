// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once
#include <QQuickPaintedItem>
#include <QtQml/qqmlregistration.h>
#include <memory>
class MaterialProgressPaint : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool circular MEMBER m_circular NOTIFY appearanceChanged)
    Q_PROPERTY(bool indeterminate MEMBER m_indeterminate NOTIFY appearanceChanged)
    Q_PROPERTY(bool mirrored MEMBER m_mirrored NOTIFY appearanceChanged)
    Q_PROPERTY(bool wavy MEMBER m_wavy NOTIFY appearanceChanged)
    Q_PROPERTY(bool running MEMBER m_running NOTIFY appearanceChanged)
    Q_PROPERTY(bool animationsEnabled MEMBER m_animationsEnabled NOTIFY appearanceChanged)
    Q_PROPERTY(int motionType MEMBER m_motionType NOTIFY appearanceChanged)
    Q_PROPERTY(qreal position MEMBER m_position NOTIFY appearanceChanged)
    Q_PROPERTY(qreal thickness MEMBER m_thickness NOTIFY appearanceChanged)
    Q_PROPERTY(qreal padding MEMBER m_padding NOTIFY appearanceChanged)
    Q_PROPERTY(qreal gap MEMBER m_gap NOTIFY appearanceChanged)
    Q_PROPERTY(qreal gapAngle MEMBER m_gapAngle NOTIFY appearanceChanged)
    Q_PROPERTY(qreal stopDiameter MEMBER m_stopDiameter NOTIFY appearanceChanged)
    Q_PROPERTY(qreal waveLength MEMBER m_waveLength NOTIFY appearanceChanged)
    Q_PROPERTY(qreal waveAmplitude MEMBER m_waveAmplitude NOTIFY appearanceChanged)
    Q_PROPERTY(int valueDuration MEMBER m_valueDuration NOTIFY appearanceChanged)
    Q_PROPERTY(int amplitudeDuration MEMBER m_amplitudeDuration NOTIFY appearanceChanged)
    Q_PROPERTY(int opacityDuration MEMBER m_opacityDuration NOTIFY appearanceChanged)
    Q_PROPERTY(int cycleDuration MEMBER m_cycleDuration NOTIFY appearanceChanged)
    Q_PROPERTY(int waveCycleDuration MEMBER m_waveCycleDuration NOTIFY appearanceChanged)
    Q_PROPERTY(QColor color MEMBER m_color NOTIFY appearanceChanged)
    Q_PROPERTY(QColor trackColor MEMBER m_trackColor NOTIFY appearanceChanged)
    Q_PROPERTY(bool animating READ animating NOTIFY frameChanged)
public:
    explicit MaterialProgressPaint(QQuickItem *parent = nullptr);
    ~MaterialProgressPaint() override;
    void paint(QPainter *painter) override;
    bool animating() const;
    Q_INVOKABLE void advanceAnimations(qreal milliseconds);
protected:
    void componentComplete() override;
signals:
    void appearanceChanged();
    void frameChanged();
private:
    void synchronize();
    struct Motion;
    std::unique_ptr<Motion> d;
    bool m_circular = false;
    bool m_indeterminate = false;
    bool m_mirrored = false;
    bool m_wavy = false;
    bool m_running = true;
    bool m_animationsEnabled = true;
    int m_motionType = 0;
    qreal m_position = 0;
    qreal m_thickness = 4;
    qreal m_padding = -1;
    qreal m_gap = 4;
    qreal m_gapAngle = 8;
    qreal m_stopDiameter = 4;
    qreal m_waveLength = 40;
    qreal m_waveAmplitude = 3;
    int m_valueDuration = 150;
    int m_amplitudeDuration = 500;
    int m_opacityDuration = 100;
    int m_cycleDuration = 1800;
    int m_waveCycleDuration = 1000;
    QColor m_color = {};
    QColor m_trackColor = {};
};
