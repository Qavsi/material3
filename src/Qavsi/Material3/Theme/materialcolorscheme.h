// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

#include <QColor>
#include <QObject>
#include <QVariantMap>
#include <QtQmlIntegration/qqmlintegration.h>

class MaterialColorScheme : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QColor seedColor READ seedColor WRITE setSeedColor NOTIFY seedColorChanged FINAL)
    Q_PROPERTY(bool dark READ dark WRITE setDark NOTIFY darkChanged FINAL)
    Q_PROPERTY(Scheme scheme READ scheme WRITE setScheme NOTIFY schemeChanged FINAL)
    Q_PROPERTY(double contrastLevel READ contrastLevel WRITE setContrastLevel NOTIFY contrastLevelChanged FINAL)
    Q_PROPERTY(QVariantMap colors READ colors NOTIFY colorsChanged FINAL)
public:
    enum Scheme {
        Neutral = 0,
        TonalSpot = 1,
        Rainbow = 2,
        Monochrome = 3,
        Vibrant = 4,
        Content = 5,
        Fidelity = 6,
        Expressive = 7,
        FruitSalad = 8,
    };
    Q_ENUM(Scheme)
    explicit MaterialColorScheme(QObject *parent = nullptr) : QObject(parent) {}
    QColor seedColor() const { return m_seedColor; }
    bool dark() const { return m_dark; }
    Scheme scheme() const { return m_scheme; }
    double contrastLevel() const { return m_contrastLevel; }
    QVariantMap colors() const;
    Q_INVOKABLE QColor paletteTone(QColor color, double tone) const;
    Q_INVOKABLE double toneOf(QColor color) const;
    void setSeedColor(QColor value);
    void setDark(bool value);
    void setScheme(Scheme value);
    void setContrastLevel(double value);
signals:
    void seedColorChanged();
    void darkChanged();
    void schemeChanged();
    void contrastLevelChanged();
    void colorsChanged();
private:
    QColor m_seedColor { 0x67, 0x50, 0xa4 };
    bool m_dark = false;
    Scheme m_scheme = TonalSpot;
    double m_contrastLevel = 0;
    mutable QVariantMap m_colors;
};
