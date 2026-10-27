// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#pragma once

class QQmlApplicationEngine;
class QQuickWindow;

void checkMenuMotion(QQmlApplicationEngine &engine, QQuickWindow &window,
                     bool hardware, void (*expect)(bool, const char *));
