// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqml.h>

class ComboBoxSupport : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(ComboBoxSupport)
    QML_UNCREATABLE("ComboBoxSupport is only available as an attached property.")
    Q_PROPERTY(QString label MEMBER m_label NOTIFY labelChanged FINAL)

public:
    explicit ComboBoxSupport(QObject *parent = nullptr);
    static ComboBoxSupport *qmlAttachedProperties(QObject *object);

    Q_INVOKABLE bool isStyleKitDefault(QObject *object) const;
    Q_INVOKABLE void applyDelegate(QObject *component);

signals:
    void labelChanged();

private:
    QString m_label;
};

QML_DECLARE_TYPEINFO(ComboBoxSupport, QML_HAS_ATTACHED_PROPERTIES)
