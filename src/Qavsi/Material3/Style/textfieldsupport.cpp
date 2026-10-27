// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#include "textfieldsupport.h"

#include <QMetaProperty>
#include <QVariant>

TextFieldSupport::TextFieldSupport(QObject *parent)
    : QObject(parent)
{
    if (!parent)
        return;

    const QMetaProperty acceptableInput = parent->metaObject()->property(
        parent->metaObject()->indexOfProperty("acceptableInput"));
    if (!acceptableInput.isValid())
        return;

    m_nativeError = !acceptableInput.read(parent).toBool();
    if (acceptableInput.hasNotifySignal()) {
        connect(parent, acceptableInput.notifySignal(), this,
            metaObject()->method(metaObject()->indexOfSlot("updateNativeError()")));
    }
}

TextFieldSupport *TextFieldSupport::qmlAttachedProperties(QObject *object)
{
    return new TextFieldSupport(object);
}

bool TextFieldSupport::error() const
{
    return m_errorOverride.value_or(m_nativeError);
}

void TextFieldSupport::setError(bool error)
{
    const bool previous = this->error();
    m_errorOverride = error;
    if (this->error() != previous)
        emit errorChanged();
}

void TextFieldSupport::resetError()
{
    const bool previous = error();
    m_errorOverride.reset();
    if (error() != previous)
        emit errorChanged();
}

void TextFieldSupport::updateNativeError()
{
    const bool previous = error();
    m_nativeError = !parent()->property("acceptableInput").toBool();
    if (error() != previous)
        emit errorChanged();
}
