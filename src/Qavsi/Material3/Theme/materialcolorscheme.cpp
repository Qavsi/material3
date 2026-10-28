// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include "materialcolorscheme.h"

#include "cpp/scheme/scheme_neutral.h"
#include "cpp/palettes/tones.h"
#include "cpp/scheme/scheme_tonal_spot.h"
#include <QDebug>
#include <algorithm>
#include <cmath>

void MaterialColorScheme::setSeedColor(QColor value)
{
    if (!value.isValid()) {
        qWarning("MaterialColorScheme: invalid seed color ignored");
        return;
    }
    value.setAlpha(255);
    if (value == m_seedColor)
        return;
    m_seedColor = value;
    m_colors.clear();
    emit seedColorChanged();
    emit colorsChanged();
}

void MaterialColorScheme::setDark(bool value)
{
    if (value == m_dark)
        return;
    m_dark = value;
    m_colors.clear();
    emit darkChanged();
    emit colorsChanged();
}

void MaterialColorScheme::setScheme(Scheme value)
{
    if (value != Neutral && value != TonalSpot) {
        qWarning("MaterialColorScheme: unsupported scheme ignored");
        return;
    }
    if (value == m_scheme)
        return;
    m_scheme = value;
    m_colors.clear();
    emit schemeChanged();
    emit colorsChanged();
}

void MaterialColorScheme::setContrastLevel(double value)
{
    if (!std::isfinite(value)) {
        qWarning("MaterialColorScheme: non-finite contrast level ignored");
        return;
    }
    value = std::clamp(value, -1.0, 1.0);
    if (value == m_contrastLevel)
        return;
    m_contrastLevel = value;
    m_colors.clear();
    emit contrastLevelChanged();
    emit colorsChanged();
}

QVariantMap MaterialColorScheme::colors() const
{
    if (!m_colors.isEmpty())
        return m_colors;
    namespace mcu = material_color_utilities;
    const mcu::Hct seed(m_seedColor.rgb());
    const mcu::DynamicScheme generated = m_scheme == Neutral
        ? mcu::DynamicScheme(mcu::SchemeNeutral(seed, m_dark, m_contrastLevel))
        : mcu::DynamicScheme(mcu::SchemeTonalSpot(seed, m_dark, m_contrastLevel));
    m_colors = {
        { QStringLiteral("primary"), QColor::fromRgba(generated.GetPrimary()) },
        { QStringLiteral("error"), QColor::fromRgba(generated.GetError()) },
        { QStringLiteral("errorForeground"), QColor::fromRgba(generated.GetOnError()) },
        { QStringLiteral("primaryForeground"), QColor::fromRgba(generated.GetOnPrimary()) },
        { QStringLiteral("primaryContainer"), QColor::fromRgba(generated.GetPrimaryContainer()) },
        { QStringLiteral("primaryContainerForeground"), QColor::fromRgba(generated.GetOnPrimaryContainer()) },
        { QStringLiteral("secondary"), QColor::fromRgba(generated.GetSecondary()) },
        { QStringLiteral("secondaryForeground"), QColor::fromRgba(generated.GetOnSecondary()) },
        { QStringLiteral("secondaryContainer"), QColor::fromRgba(generated.GetSecondaryContainer()) },
        { QStringLiteral("secondaryContainerForeground"), QColor::fromRgba(generated.GetOnSecondaryContainer()) },
        { QStringLiteral("surface"), QColor::fromRgba(generated.GetSurface()) },
        { QStringLiteral("surfaceForeground"), QColor::fromRgba(generated.GetOnSurface()) },
        { QStringLiteral("surfaceVariant"), QColor::fromRgba(generated.GetSurfaceVariant()) },
        { QStringLiteral("surfaceVariantForeground"), QColor::fromRgba(generated.GetOnSurfaceVariant()) },
        { QStringLiteral("surfaceContainer"), QColor::fromRgba(generated.GetSurfaceContainer()) },
        { QStringLiteral("surfaceContainerLow"), QColor::fromRgba(generated.GetSurfaceContainerLow()) },
        { QStringLiteral("surfaceContainerHigh"), QColor::fromRgba(generated.GetSurfaceContainerHigh()) },
        { QStringLiteral("surfaceContainerHighest"), QColor::fromRgba(generated.GetSurfaceContainerHighest()) },
        { QStringLiteral("inverseSurface"), QColor::fromRgba(generated.GetInverseSurface()) },
        { QStringLiteral("inverseSurfaceForeground"), QColor::fromRgba(generated.GetInverseOnSurface()) },
        { QStringLiteral("outline"), QColor::fromRgba(generated.GetOutline()) },
        { QStringLiteral("outlineVariant"), QColor::fromRgba(generated.GetOutlineVariant()) },
        { QStringLiteral("shadow"), QColor::fromRgba(generated.GetShadow()) }
    };
    return m_colors;
}

QColor MaterialColorScheme::paletteTone(QColor color, double tone) const
{
    if (!color.isValid() || !std::isfinite(tone))
        return {};
    const material_color_utilities::Hct hct(color.rgb());
    const material_color_utilities::TonalPalette palette(hct);
    return QColor::fromRgba(palette.get(std::clamp(tone, 0.0, 100.0)));
}

double MaterialColorScheme::toneOf(QColor color) const
{
    return color.isValid() ? material_color_utilities::Hct(color.rgb()).get_tone() : 0.0;
}
