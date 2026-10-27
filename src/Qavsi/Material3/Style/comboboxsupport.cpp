// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#include "comboboxsupport.h"

#include <QQmlComponent>
#include <QSignalBlocker>
#include <QVariant>
#include <QQmlContext>
#include <QQmlEngine>
#include <QUrl>

ComboBoxSupport::ComboBoxSupport(QObject *parent)
    : QObject(parent)
{
}

ComboBoxSupport *ComboBoxSupport::qmlAttachedProperties(QObject *object)
{
    return new ComboBoxSupport(object);
}

bool ComboBoxSupport::isStyleKitDefault(QObject *object) const
{
    if (!object)
        return false;

    QUrl url;
    if (const auto *component = qobject_cast<QQmlComponent *>(object))
        url = component->url();
    else if (const auto *context = QQmlEngine::contextForObject(object))
        url = context->baseUrl();

    // shortcut: Qt 6.12 has no popup/delegate slots; recheck the stock QML URL on SDK upgrades.
    return url.path().endsWith(QLatin1String("/Qt/labs/StyleKit/ComboBox.qml"));
}

void ComboBoxSupport::applyDelegate(QObject *object)
{
    auto *component = qobject_cast<QQmlComponent *>(object);
    auto *control = parent();
    if (!component || !control || control->property("delegate").value<QObject *>() == component)
        return;
    const QVariant selection = control->property("currentIndex");
    const QVariant draft = control->property("editText");
    if (!selection.isValid())
        return;
    {
        // A native delegate change resets selection; preserve it without breaking QML bindings.
        const QSignalBlocker blocked(control);
        control->setProperty("delegate", QVariant::fromValue(component));
        if (control->property("currentIndex") != selection)
            control->setProperty("currentIndex", selection);
        if (draft.isValid() && control->property("editText") != draft)
            control->setProperty("editText", draft);
    }
    QMetaObject::invokeMethod(control, "delegateChanged", Qt::DirectConnection);
}
