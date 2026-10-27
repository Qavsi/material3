// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqml.h>
#include <optional>

class TextFieldSupport : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_ATTACHED(TextFieldSupport)
    QML_UNCREATABLE("TextFieldSupport is only available as an attached property.")
    Q_PROPERTY(QString prefix MEMBER m_prefix NOTIFY prefixChanged FINAL)
    Q_PROPERTY(QString suffix MEMBER m_suffix NOTIFY suffixChanged FINAL)
    Q_PROPERTY(QString leadingIcon MEMBER m_leadingIcon NOTIFY leadingIconChanged FINAL)
    Q_PROPERTY(QString trailingIcon MEMBER m_trailingIcon NOTIFY trailingIconChanged FINAL)
    Q_PROPERTY(QString supportingText MEMBER m_supportingText NOTIFY supportingTextChanged FINAL)
    Q_PROPERTY(QString errorText MEMBER m_errorText NOTIFY errorTextChanged FINAL)
    Q_PROPERTY(bool error READ error WRITE setError RESET resetError NOTIFY errorChanged FINAL)

public:
    explicit TextFieldSupport(QObject *parent = nullptr);
    static TextFieldSupport *qmlAttachedProperties(QObject *object);

    bool error() const;
    void setError(bool error);
    void resetError();

signals:
    void prefixChanged();
    void suffixChanged();
    void leadingIconChanged();
    void trailingIconChanged();
    void supportingTextChanged();
    void errorTextChanged();
    void errorChanged();

private slots:
    void updateNativeError();

private:
    QString m_prefix;
    QString m_suffix;
    QString m_leadingIcon;
    QString m_trailingIcon;
    QString m_supportingText;
    QString m_errorText;
    std::optional<bool> m_errorOverride = std::nullopt;
    bool m_nativeError = false;
};

QML_DECLARE_TYPEINFO(TextFieldSupport, QML_HAS_ATTACHED_PROPERTIES)
