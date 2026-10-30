// Copyright (c) 2024-2026 hypengw, Enes Alp
// SPDX-License-Identifier: MIT
// Width allocation adapted from QmlMaterial 0.6.1 (1912605).
#pragma once

#include "../../motion/material3spring.h"
#include <QPointer>
#include <QQuickItem>
#include <QtQmlIntegration/qqmlintegration.h>
#include <optional>

class Material3ButtonGroupAttached;

// Layout only: every action, input and selection remains a native button.
class Material3ButtonGroup : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(Material3ButtonGroupAttached)
    Q_PROPERTY(QObject *tokens READ tokens WRITE setTokens NOTIFY tokensChanged REQUIRED FINAL)
    Q_PROPERTY(bool reduceMotion READ reduceMotion WRITE setReduceMotion NOTIFY reduceMotionChanged FINAL)
    Q_PROPERTY(bool animateWidth READ animateWidth WRITE setAnimateWidth NOTIFY animateWidthChanged FINAL)
    Q_PROPERTY(qreal spacing READ spacing WRITE setSpacing NOTIFY spacingChanged FINAL)
    Q_PROPERTY(bool mirrored READ mirrored WRITE setMirrored RESET resetMirrored NOTIFY mirroredChanged FINAL)
public:
    explicit Material3ButtonGroup(QQuickItem *parent = nullptr);
    ~Material3ButtonGroup() override;
    static Material3ButtonGroupAttached *qmlAttachedProperties(QObject *object);
    QObject *tokens() const { return m_tokens; }
    bool reduceMotion() const { return m_reduceMotion; }
    bool animateWidth() const { return m_animateWidth; }
    qreal spacing() const { return m_spacing; }
    bool mirrored() const;
    void setTokens(QObject *value);
    void setReduceMotion(bool value);
    void setAnimateWidth(bool value);
    void setSpacing(qreal value);
    void setMirrored(bool value);
    void resetMirrored();
    Q_SIGNAL void tokensChanged();
    Q_SIGNAL void reduceMotionChanged();
    Q_SIGNAL void animateWidthChanged();
    Q_SIGNAL void spacingChanged();
    Q_SIGNAL void mirroredChanged();
protected:
    void itemChange(ItemChange change, const ItemChangeData &data) override;
    void componentComplete() override;
    void updatePolish() override;
private Q_SLOTS:
    void refreshMotion();
private:
    friend class Material3ButtonGroupAttached;
    void invalidate();
    void updateWindow();
    bool feedbackActive() const;
    bool canAnimate() const;
    qreal token(const char *name, qreal fallback = 0) const;
    QPointer<QObject> m_tokens;
    QList<QMetaObject::Connection> m_tokenConnections, m_windowConnections;
    std::optional<bool> m_mirrored;
    qreal m_spacing = 0;
    bool m_reduceMotion = true, m_animateWidth = true, m_destroying = false;
    quint64 m_revision = 0;
};

class Material3ButtonGroupAttached : public QObject
{
    Q_OBJECT
    QML_ANONYMOUS
    Q_PROPERTY(bool managed READ managed WRITE setManaged NOTIFY parametersChanged FINAL)
    Q_PROPERTY(qreal layoutWidth READ layoutWidth NOTIFY layoutWidthChanged FINAL)
    Q_PROPERTY(qreal preferredWidth READ preferredWidth WRITE setPreferredWidth RESET resetPreferredWidth NOTIFY parametersChanged FINAL)
    Q_PROPERTY(qreal minimumWidth READ minimumWidth WRITE setMinimumWidth RESET resetMinimumWidth NOTIFY parametersChanged FINAL)
    Q_PROPERTY(qreal weight READ weight WRITE setWeight NOTIFY parametersChanged FINAL)
    Q_PROPERTY(qreal compressionLimit READ compressionLimit WRITE setCompressionLimit RESET resetCompressionLimit NOTIFY parametersChanged FINAL)
public:
    explicit Material3ButtonGroupAttached(QObject *object);
    bool managed() const { return m_managed; }
    qreal layoutWidth() const;
    qreal preferredWidth() const { return m_preferredWidth; }
    qreal minimumWidth() const { return m_minimumWidth; }
    qreal weight() const { return m_weight; }
    qreal compressionLimit() const { return m_compressionLimit; }
    void setManaged(bool value);
    void setPreferredWidth(qreal value);
    void setMinimumWidth(qreal value);
    void setWeight(qreal value);
    void setCompressionLimit(qreal value);
    void resetPreferredWidth();
    void resetMinimumWidth();
    void resetCompressionLimit();
    Q_SIGNAL void parametersChanged();
    Q_SIGNAL void layoutWidthChanged();
private Q_SLOTS:
    void updatePress();
    void layoutChanged();
    void mirroringChanged();
private:
    friend class Material3ButtonGroup;
    void updateGroup();
    void setLayoutWidth(qreal value);
    void releaseIfReady();
    QPointer<QQuickItem> m_item;
    QPointer<Material3ButtonGroup> m_group;
    Material3Spring m_press;
    qreal m_layoutWidth = 0, m_preferredWidth = -1, m_minimumWidth = -1;
    qreal m_weight = 0, m_compressionLimit = -1;
    bool m_managed = false, m_hasLayoutWidth = false, m_releasing = false;
};
QML_DECLARE_TYPEINFO(Material3ButtonGroup, QML_HAS_ATTACHED_PROPERTIES)
