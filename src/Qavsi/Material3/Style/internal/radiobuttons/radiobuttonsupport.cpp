// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include "radiobuttonsupport.h"
#include <QCoreApplication>
#include <QEvent>
#include <QKeyEvent>
#include <QPointer>
#include <QQuickItem>
#include <QVariant>
#include <QTouchEvent>

RadioButtonSupport::RadioButtonSupport(QObject *parent) : QObject(parent)
{
    if (parent)
        parent->installEventFilter(this);
}

RadioButtonSupport *RadioButtonSupport::qmlAttachedProperties(QObject *object)
{
    return new RadioButtonSupport(object);
}

void RadioButtonSupport::setReadOnly(bool value)
{
    if (m_readOnly == value)
        return;
    m_readOnly = value;
    if (value) {
        if (auto *item = qobject_cast<QQuickItem *>(parent())) {
            const QPointer<RadioButtonSupport> guard(this);
            item->ungrabMouse();
            if (!guard) return;
            item->ungrabTouchPoints();
            if (!guard) return;
            if (item->property("pressed").toBool()) {
                // Qt Control routes TouchCancel to its native press-cancellation path.
                QTouchEvent cancel(QEvent::TouchCancel);
                QCoreApplication::sendEvent(item, &cancel);
                if (!guard) return;
            }
        }
    }
    emit readOnlyChanged();
}

bool RadioButtonSupport::eventFilter(QObject *object, QEvent *event)
{
    if (!m_readOnly)
        return QObject::eventFilter(object, event);
    switch (event->type()) {
    case QEvent::MouseButtonPress:
    case QEvent::MouseButtonDblClick:
    case QEvent::MouseMove:
    case QEvent::MouseButtonRelease:
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
    case QEvent::Shortcut:
        event->accept();
        return true;
    case QEvent::KeyPress:
    case QEvent::KeyRelease:
        switch (static_cast<QKeyEvent *>(event)->key()) {
        case Qt::Key_Space:
        case Qt::Key_Select:
        case Qt::Key_Return:
        case Qt::Key_Enter:
        case Qt::Key_Left:
        case Qt::Key_Right:
        case Qt::Key_Up:
        case Qt::Key_Down:
        case Qt::Key_Home:
        case Qt::Key_End:
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
