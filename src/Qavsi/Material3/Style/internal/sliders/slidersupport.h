// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqml.h>

class SliderSupport : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(SliderSupport)
    QML_UNCREATABLE("SliderSupport is only available as an attached property.")
    Q_PROPERTY(bool readOnly READ readOnly WRITE setReadOnly NOTIFY readOnlyChanged FINAL)
    Q_PROPERTY(LabelBehavior labelBehavior MEMBER m_labelBehavior NOTIFY labelBehaviorChanged FINAL)
    Q_PROPERTY(TickVisibilityMode tickVisibilityMode MEMBER m_tickVisibilityMode NOTIFY tickVisibilityModeChanged FINAL)
    Q_PROPERTY(QString insetIcon MEMBER m_insetIcon NOTIFY insetIconChanged FINAL)
    Q_PROPERTY(QString insetIconAtMinimum MEMBER m_insetIconAtMinimum NOTIFY insetIconAtMinimumChanged FINAL)

public:
    enum LabelBehavior : int { LabelFloating, LabelVisible, LabelGone };
    Q_ENUM(LabelBehavior)
    enum TickVisibilityMode : int { TickAutoLimit, TickNone, TickAll };
    Q_ENUM(TickVisibilityMode)
    explicit SliderSupport(QObject *parent = nullptr);
    static SliderSupport *qmlAttachedProperties(QObject *object);
    bool readOnly() const { return m_readOnly; }
    void setReadOnly(bool value);

signals:
    void readOnlyChanged();
    void labelBehaviorChanged();
    void tickVisibilityModeChanged();
    void insetIconChanged();
    void insetIconAtMinimumChanged();

protected:
    bool eventFilter(QObject *object, QEvent *event) override;

private:
    bool m_readOnly = false;
    LabelBehavior m_labelBehavior = LabelFloating;
    TickVisibilityMode m_tickVisibilityMode = TickAutoLimit;
    QString m_insetIcon;
    QString m_insetIconAtMinimum;
};

QML_DECLARE_TYPEINFO(SliderSupport, QML_HAS_ATTACHED_PROPERTIES)
