// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 229bc3e64ff71f1ac88cf73e976637ffbcf7e33c.

#include "materialtimestate.h"
#include <QPointer>
#include <QTime>

namespace Qavsi::Material3
{
namespace
{
QString digits(const QLocale& locale, int value, bool padded) {
    auto result = locale.toString(value);
    if (padded && value < 10) result.prepend(locale.zeroDigit());
    return result;
}
int parseDigits(const QLocale& locale, const QString& text, int minimum, int maximum) {
    // Reject signs, grouping and whitespace; locale digits and ASCII digits are accepted.
    if (text.isEmpty() || text.size() > 2) return -1;
    for (auto ch : text)
        if (! ch.isDigit()) return -1;
    bool      ok    = false;
    const int value = locale.toInt(text, &ok);
    return ok && value >= minimum && value <= maximum ? value : -1;
}
} // namespace
MaterialTimeState::MaterialTimeState(QObject* parent): QObject(parent) {
    auto data = m_data.value();
    formatInput(data);
    m_data = data;
}
bool MaterialTimeState::uses24Hour(const Data& data) {
    if (data.format != LocaleFormat) return data.format == Hour24;
    const auto pattern = data.locale.timeFormat(QLocale::ShortFormat);
    bool       quoted  = false;
    for (qsizetype i = 0; i < pattern.size(); ++i) {
        if (pattern[i] == QLatin1Char('\'')) {
            if (i + 1 < pattern.size() && pattern[i + 1] == QLatin1Char('\''))
                ++i;
            else
                quoted = ! quoted;
        } else if (! quoted && (pattern[i] == QLatin1Char('A') || pattern[i] == QLatin1Char('a'))) {
            return false;
        }
    }
    return true;
}
bool MaterialTimeState::is24Hour() const { return uses24Hour(m_data.value()); }
void MaterialTimeState::formatInput(Data& data) {
    const int hour   = data.value / 60;
    data.draftHour   = uses24Hour(data) ? hour : (hour % 12 == 0 ? 12 : hour % 12);
    data.draftMinute = data.value % 60;
    data.hourText    = digits(data.locale, data.draftHour, true);
    data.minuteText  = digits(data.locale, data.draftMinute, true);
}
void MaterialTimeState::publish(Data data, bool user) {
    if (data == m_data.value()) return;
    QPointer<MaterialTimeState> guard(this);
    m_data = data;
    if (! guard) return;
    Q_EMIT changed();
    // Notify user edits even when only a draft buffer or selection changed.
    if (guard && user && m_data.value() == data) Q_EMIT modified(data.value);
}
void MaterialTimeState::setValue(int value) {
    // A caller acknowledgement of this value must retain the editing buffers.
    if (value < 0 || value >= 1440 || value == this->value()) return;
    auto data  = m_data.value();
    data.value = value;
    formatInput(data);
    publish(data);
}
bool MaterialTimeState::setTime(int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return false;
    setValue(hour * 60 + minute);
    return true;
}
void MaterialTimeState::setHour(int hour) { setTime(hour, minute()); }
void MaterialTimeState::setMinute(int minute) { setTime(hour(), minute); }
void MaterialTimeState::setLocale(const QLocale& locale) {
    if (this->locale() == locale) return;
    auto data   = m_data.value();
    data.locale = locale;
    formatInput(data);
    publish(data);
}
void MaterialTimeState::setHourFormat(HourFormat format) {
    if (format < LocaleFormat || format > Hour24 || format == hourFormat()) return;
    auto data   = m_data.value();
    data.format = format;
    formatInput(data);
    publish(data);
}
void MaterialTimeState::setSelection(Selection selection) {
    if (selection != Hours && selection != Minutes) return;
    auto data      = m_data.value();
    data.selection = selection;
    publish(data);
}
void MaterialTimeState::setDisplayMode(DisplayMode mode) {
    if ((mode != Clock && mode != Input) || mode == displayMode()) return;
    if (mode == Clock && ! acceptableInput()) return;
    auto data = m_data.value();
    data.mode = mode;
    formatInput(data);
    publish(data);
}
void MaterialTimeState::setPeriod(int period) {
    if (period < 0 || period > 1 || period == this->period()) return;
    auto data  = m_data.value();
    data.value = (hour() % 12 + 12 * period) * 60 + minute();
    if (is24Hour()) formatInput(data);
    publish(data, true);
}
void MaterialTimeState::edit(const QString& text, bool hourField) {
    auto data = m_data.value();
    if (hourField) {
        data.hourText  = text;
        data.draftHour = parseDigits(data.locale, text, is24Hour() ? 0 : 1, is24Hour() ? 23 : 12);
    } else {
        data.minuteText  = text;
        data.draftMinute = parseDigits(data.locale, text, 0, 59);
    }
    if (data.draftHour >= 0 && data.draftMinute >= 0) {
        const int hour = is24Hour() ? data.draftHour : data.draftHour % 12 + 12 * period();
        data.value     = hour * 60 + data.draftMinute;
    }
    publish(data, true);
}
void MaterialTimeState::editHour(const QString& text) { edit(text, true); }
void MaterialTimeState::editMinute(const QString& text) { edit(text, false); }
void MaterialTimeState::discardInput() {
    auto data = m_data.value();
    formatInput(data);
    publish(data);
}
bool MaterialTimeState::commitInput() {
    if (! acceptableInput()) return false;
    discardInput();
    return true;
}
void MaterialTimeState::selectDial(int selected, bool complete) {
    auto data = m_data.value();
    if (selection() == Hours) {
        if (selected < 0 || selected > (is24Hour() ? 23 : 12)) return;
        const int hour = is24Hour() ? selected : selected % 12 + 12 * period();
        data.value     = hour * 60 + minute();
        if (complete) data.selection = Minutes;
    } else {
        if (selected < 0 || selected > 59) return;
        data.value = hour() * 60 + selected;
    }
    formatInput(data);
    publish(data, true);
}
void MaterialTimeState::step(int delta) {
    const int limit    = selection() == Hours ? 24 : 60;
    const int previous = selection() == Hours ? hour() : minute();
    const int next     = ((previous + delta % limit) % limit + limit) % limit;
    auto      data     = m_data.value();
    data.value         = selection() == Hours ? next * 60 + minute() : hour() * 60 + next;
    formatInput(data);
    publish(data, true);
}
QString MaterialTimeState::number(int value, bool padded) const { return digits(locale(), value, padded); }
QString MaterialTimeState::inputFormat() const {
    return is24Hour() ? QStringLiteral("HH:mm") : QStringLiteral("hh:mm AP");
}
QString MaterialTimeState::formatTime(int value) const {
    return value >= 0 && value < 1440
               ? locale().toString(QTime(value / 60, value % 60), inputFormat())
               : QString();
}
} // namespace Qavsi::Material3
