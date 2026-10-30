// Copyright (c) 2024-2026 hypengw, Enes Alp
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#pragma once

#include <QObject>
#include <QQmlParserStatus>
#include <QVector4D>
#include <QtQmlIntegration/qqmlintegration.h>
#include <array>
#include <memory>

class Material3SpringClock;

class Material3SpringBase : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    QML_ANONYMOUS
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(qreal stiffness READ stiffness WRITE setStiffness NOTIFY specChanged FINAL)
    Q_PROPERTY(qreal dampingRatio READ dampingRatio WRITE setDampingRatio NOTIFY specChanged FINAL)
    Q_PROPERTY(qreal visibilityThreshold READ visibilityThreshold WRITE setVisibilityThreshold NOTIFY visibilityThresholdChanged FINAL)
    Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged FINAL)
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged FINAL)
public:
    ~Material3SpringBase() override;
    void classBegin() override;
    void componentComplete() override;
    qreal stiffness() const { return m_stiffness; }
    qreal dampingRatio() const { return m_dampingRatio; }
    qreal visibilityThreshold() const { return m_threshold; }
    bool isEnabled() const { return m_enabled; }
    bool isRunning() const { return m_running; }
    void setStiffness(qreal value);
    void setDampingRatio(qreal value);
    void setVisibilityThreshold(qreal value);
    void setEnabled(bool value);
    Q_INVOKABLE void complete();
    Q_SIGNAL void specChanged();
    Q_SIGNAL void visibilityThresholdChanged();
    Q_SIGNAL void enabledChanged();
    Q_SIGNAL void runningChanged();
    Q_SIGNAL void targetChanged();
    Q_SIGNAL void valueChanged();
protected:
    explicit Material3SpringBase(int dimensions, QObject *parent);
    void setTargets(const std::array<qreal, 4> &targets, bool snap = false, bool preserveVelocity = true);
    qreal target(int index) const;
    qreal value(int index) const;
    qreal velocity(int index) const;
    int elapsed() const;
    virtual qreal displacementThreshold(int index) const;
private:
    friend class Material3SpringClock;
    void restart();
    void tick(int time);
    void settle();
    struct Sample { qreal value = 0, velocity = 0; };
    struct Track {
        qreal from = 0, target = 0, initialVelocity = 0;
        Sample current;
        int duration = 0;
    };
    const int m_dimensions;
    std::array<Track, 4> m_tracks;
    std::unique_ptr<Material3SpringClock> m_clock;
    qreal m_stiffness = 1500, m_dampingRatio = 1, m_threshold = .01;
    bool m_enabled = true, m_complete = true, m_running = false;
    quint64 m_revision = 0;
};

class Material3Spring : public Material3SpringBase
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(qreal targetValue READ targetValue WRITE setTargetValue NOTIFY targetChanged FINAL)
    Q_PROPERTY(qreal value READ value NOTIFY valueChanged FINAL)
public:
    explicit Material3Spring(QObject *parent = nullptr);
    qreal targetValue() const { return target(0); }
    qreal value() const { return Material3SpringBase::value(0); }
    void setTargetValue(qreal value) { setTargets({value}); }
    void snapTo(qreal value) { setTargets({value}, true); }
    using Material3SpringBase::elapsed;
};

class Material3CornerSpring : public Material3SpringBase
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QVector4D targetCorners READ targetCorners WRITE setTargetCorners NOTIFY targetChanged FINAL)
    Q_PROPERTY(QVector4D corners READ corners NOTIFY valueChanged FINAL)
public:
    explicit Material3CornerSpring(QObject *parent = nullptr);
    QVector4D targetCorners() const;
    QVector4D corners() const;
    void setTargetCorners(const QVector4D &value);
private:
    qreal displacementThreshold(int index) const override;
    QVector4D m_start;
};
