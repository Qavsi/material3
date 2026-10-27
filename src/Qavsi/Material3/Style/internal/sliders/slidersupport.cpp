// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include "slidersupport.h"

#include <QEvent>
#include <QKeyEvent>
#include <QPointer>
#include <QQuickItem>

SliderSupport::SliderSupport(QObject *parent) : QObject(parent)
{
    if (parent)
        parent->installEventFilter(this);
}

SliderSupport *SliderSupport::qmlAttachedProperties(QObject *object)
{
    return new SliderSupport(object);
}

void SliderSupport::setReadOnly(bool value)
{
    if (m_readOnly == value)
        return;
    m_readOnly = value;
    if (value) {
        if (auto *item = qobject_cast<QQuickItem *>(parent())) {
            const QPointer<SliderSupport> guard(this);
            item->ungrabMouse();
            if (!guard) return;
            item->ungrabTouchPoints();
            if (!guard) return;
        }
    }
    emit readOnlyChanged();
}

bool SliderSupport::eventFilter(QObject *object, QEvent *event)
{
    if (!m_readOnly)
        return QObject::eventFilter(object, event);
    switch (event->type()) {
    case QEvent::MouseButtonPress:
    case QEvent::MouseButtonRelease:
    case QEvent::MouseButtonDblClick:
    case QEvent::MouseMove:
    case QEvent::Wheel:
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
        event->accept();
        return true;
    case QEvent::KeyPress:
        switch (static_cast<QKeyEvent *>(event)->key()) {
        case Qt::Key_Left:
        case Qt::Key_Right:
        case Qt::Key_Up:
        case Qt::Key_Down:
        case Qt::Key_Home:
        case Qt::Key_End:
        case Qt::Key_PageUp:
        case Qt::Key_PageDown:
            event->accept();
            return true;
        default:
            break;
        }
        break;
    default:
        break;
    }
    return QObject::eventFilter(object, event);
}
