// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once
#include <QObject>
#include <QtQml/qqml.h>

class RadioButtonSupport : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(RadioButtonSupport)
    QML_UNCREATABLE("RadioButtonSupport is only available as an attached property.")
    Q_PROPERTY(bool readOnly READ readOnly WRITE setReadOnly NOTIFY readOnlyChanged FINAL)
public:
    explicit RadioButtonSupport(QObject *parent = nullptr);
    static RadioButtonSupport *qmlAttachedProperties(QObject *object);
    bool readOnly() const { return m_readOnly; }
    void setReadOnly(bool value);
signals:
    void readOnlyChanged();
protected:
    bool eventFilter(QObject *object, QEvent *event) override;
private:
    bool m_readOnly = false;
};
QML_DECLARE_TYPEINFO(RadioButtonSupport, QML_HAS_ATTACHED_PROPERTIES)
