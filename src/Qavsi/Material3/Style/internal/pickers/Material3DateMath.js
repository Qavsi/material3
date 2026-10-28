.pragma library

function dayNumber(value) {
    const day = new Date(0);
    day.setUTCFullYear(value.getFullYear(), value.getMonth(), value.getDate());
    day.setUTCHours(0, 0, 0, 0);
    return day.getTime();
}

function isSelectable(value, minimum, maximum) {
    const day = dayNumber(value);
    return !isNaN(day) && value.getFullYear() >= 1 && value.getFullYear() <= 9999
        && (isNaN(minimum.getTime()) || day >= dayNumber(minimum))
        && (isNaN(maximum.getTime()) || day <= dayNumber(maximum));
}
