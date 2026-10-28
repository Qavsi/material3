// Adapted from QmlMaterial 0.6.1 (1912605), MIT.
#include "material3colorinput.h"
#include <QKeyEvent>
#include <QMouseEvent>
#include <numbers>
#include <cmath>
#include <algorithm>

namespace qavsi_material3
{
namespace
{
constexpr qreal tau = 2 * std::numbers::pi;
}
Material3ColorInput::Material3ColorInput(QQuickItem* parent): QQuickItem(parent) {
    setAcceptedMouseButtons(Qt::LeftButton);
    setActiveFocusOnTab(true);
    connect(this, &Material3ColorInput::hueChanged, this, &Material3ColorInput::geometryChanged);
}
void Material3ColorInput::mousePressEvent(QMouseEvent *event) {
    if (!isEnabled() || event->button() != Qt::LeftButton || !contains(event->position())) {
        event->ignore();
        return;
    }
    forceActiveFocus(Qt::MouseFocusReason);
    m_dragging = true;
    setKeepMouseGrab(true);
    m_lastPoint.reset();
    event->accept();
}
void Material3ColorInput::mouseMoveEvent(QMouseEvent *event) {
    if (!m_dragging) { event->ignore(); return; }
    m_lastPoint = event->position();
    event->accept();
    requestAt(event->position());
}
void Material3ColorInput::mouseReleaseEvent(QMouseEvent *event) {
    if (!m_dragging) { event->ignore(); return; }
    m_dragging = false;
    setKeepMouseGrab(false);
    const bool changed = m_lastPoint != event->position();
    m_lastPoint.reset();
    event->accept();
    if (changed) requestAt(event->position());
}
void Material3ColorInput::mouseUngrabEvent() {
    m_dragging = false;
    setKeepMouseGrab(false);
    m_lastPoint.reset();
}
void Material3ColorInput::cancelActivation() {
    if (m_dragging) ungrabMouse();
    m_dragging = false;
    setKeepMouseGrab(false);
    m_lastPoint.reset();
}
void Material3ColorInput::setHue(qreal value) {
    if (! std::isfinite(value)) return;
    value = std::clamp(value, qreal(0), qreal(1));
    if (m_hue == value) return;
    m_hue = value;
    Q_EMIT hueChanged();
}
#define CHANNEL(Name, Upper)                           \
    void Material3ColorInput::set##Upper(qreal value) {         \
        if (! std::isfinite(value)) return;            \
        value = std::clamp(value, qreal(0), qreal(1)); \
        if (m_##Name == value) return;                 \
        m_##Name = value;                              \
        Q_EMIT Name##Changed();                        \
    }
CHANNEL(saturation, Saturation)
CHANNEL(value, Value)
#undef CHANNEL
void Material3ColorInput::geometryChange(const QRectF& now, const QRectF& old) {
    QQuickItem::geometryChange(now, old);
    if (now.size() == old.size()) return;
    const QPointer<Material3ColorInput> guard(this);
    cancelActivation();
    if (guard) Q_EMIT geometryChanged();
}
Material3ColorTriangle::Material3ColorTriangle(QQuickItem* parent): Material3ColorInput(parent) {
    connect(this, &Material3ColorInput::geometryChanged, this, &Material3ColorTriangle::handlePositionChanged);
    connect(this, &Material3ColorInput::saturationChanged, this, &Material3ColorTriangle::handlePositionChanged);
    connect(this, &Material3ColorInput::valueChanged, this, &Material3ColorTriangle::handlePositionChanged);
}
QPointF Material3ColorTriangle::vertex(qreal angle) const {
    const auto radius = std::max(qreal(0), std::min(width(), height()) / 2);
    return QPointF(width() / 2, height() / 2) + radius * QPointF(std::cos(angle), std::sin(angle));
}
QPointF Material3ColorTriangle::hueVertex() const { return vertex(-hue() * tau); }
QPointF Material3ColorTriangle::whiteVertex() const { return vertex(-hue() * tau + tau / 3); }
QPointF Material3ColorTriangle::blackVertex() const { return vertex(-hue() * tau + 2 * tau / 3); }
QPointF Material3ColorTriangle::handlePosition() const {
    return saturation() * value() * hueVertex() + (1 - saturation()) * value() * whiteVertex() +
           (1 - value()) * blackVertex();
}
std::optional<std::array<qreal, 3>> Material3ColorTriangle::coordinates(QPointF point) const {
    const auto a = hueVertex(), b = whiteVertex() - a, c = blackVertex() - a, p = point - a;
    const auto d00 = QPointF::dotProduct(b, b), d01 = QPointF::dotProduct(b, c),
               d11 = QPointF::dotProduct(c, c);
    const auto d20 = QPointF::dotProduct(p, b), d21 = QPointF::dotProduct(p, c);
    const auto denominator = d00 * d11 - d01 * d01;
    if (std::abs(denominator) < 1e-9) return {};
    const auto beta  = (d11 * d20 - d01 * d21) / denominator;
    const auto gamma = (d00 * d21 - d01 * d20) / denominator;
    return std::array<qreal, 3> { 1 - beta - gamma, beta, gamma };
}
bool Material3ColorTriangle::contains(const QPointF& point) const {
    const auto weights = coordinates(point);
    return weights && std::all_of(weights->begin(), weights->end(), [](qreal v) {
               return v >= -1e-9;
           });
}
void Material3ColorTriangle::requestAt(QPointF point) {
    auto weights = coordinates(point);
    if (! weights) return;
    qreal sum = 0;
    for (auto& v : *weights) {
        v = std::clamp(v, qreal(0), qreal(1));
        sum += v;
    }
    if (sum < 1e-9) return;
    const auto value = std::clamp(1 - (*weights)[2] / sum, qreal(0), qreal(1));
    const auto saturation =
        value < 1e-6 ? 0 : std::clamp((*weights)[0] / sum / value, qreal(0), qreal(1));
    Q_EMIT svChangeRequested(saturation, value);
}
void Material3ColorTriangle::keyPressEvent(QKeyEvent* event) {
    auto s = saturation(), v = value();
    switch (event->key()) {
    case Qt::Key_Left: s -= .01; break;
    case Qt::Key_Right: s += .01; break;
    case Qt::Key_Up: v += .01; break;
    case Qt::Key_Down: v -= .01; break;
    default: QQuickItem::keyPressEvent(event); return;
    }
    event->accept();
    if (isEnabled())
        Q_EMIT svChangeRequested(std::clamp(s, qreal(0), qreal(1)),
                                 std::clamp(v, qreal(0), qreal(1)));
}
Material3ColorWheel::Material3ColorWheel(QQuickItem* parent): Material3ColorInput(parent) {}
Material3ColorWheel::~Material3ColorWheel() {
    for (const auto &connection : m_triangleConnections) disconnect(connection);
}
qreal Material3ColorWheel::outerRadius() const {
    return std::max(qreal(0), std::min(width(), height()) / 2 - 1);
}
qreal   Material3ColorWheel::innerRadius() const { return std::max(qreal(0), outerRadius() - thickness()); }
QPointF Material3ColorWheel::handlePosition() const {
    const auto radius = (outerRadius() + innerRadius()) / 2;
    return QPointF(width() / 2, height() / 2) +
           radius * QPointF(std::cos(hue() * tau), -std::sin(hue() * tau));
}
void Material3ColorWheel::setThickness(qreal value) {
    if (! std::isfinite(value) || value < 0 || value == m_thickness) return;
    m_thickness = value;
    const QPointer<Material3ColorWheel> guard(this);
    cancelActivation();
    if (guard) Q_EMIT geometryChanged();
}
bool Material3ColorWheel::contains(const QPointF& point) const {
    const auto delta = point - QPointF(width() / 2, height() / 2);
    const auto radius = std::hypot(delta.x(), delta.y());
    return outerRadius() > 0 && thickness() > 0 && radius >= innerRadius()
        && radius <= outerRadius() + 2;
}
void Material3ColorWheel::requestAt(QPointF point) {
    const auto delta = point - QPointF(width() / 2, height() / 2);
    if (delta.isNull()) return;
    auto angle = std::atan2(-delta.y(), delta.x()) / tau;
    if (angle < 0) angle += 1;
    requestHue(angle);
}
void Material3ColorWheel::requestHue(qreal value) {
    if (isEnabled() && isVisible() && std::isfinite(value))
        Q_EMIT hueChangeRequested(std::clamp(value, qreal(0), qreal(1)));
}
void Material3ColorWheel::keyPressEvent(QKeyEvent* event) {
    qreal delta;
    switch (event->key()) {
    case Qt::Key_Left:
    case Qt::Key_Down: delta = -1.0 / 360; break;
    case Qt::Key_Right:
    case Qt::Key_Up: delta = 1.0 / 360; break;
    default: QQuickItem::keyPressEvent(event); return;
    }
    event->accept();
    if (isEnabled()) Q_EMIT hueChangeRequested(std::fmod(hue() + delta + 1, 1));
}
void Material3ColorWheel::setTriangle(Material3ColorTriangle* triangle) {
    if (m_triangle == triangle) return;
    const QPointer<Material3ColorWheel>    guard(this);
    const QPointer<Material3ColorTriangle> next(triangle);
    for (const auto &connection : m_triangleConnections) disconnect(connection);
    m_triangleConnections.clear();
    if (m_triangle) m_triangle->cancelActivation();
    if (! guard) return;
    m_triangle = next;
    if (next) {
        m_triangleConnections.append(
            connect(next, &Material3ColorInput::svChangeRequested, this, &Material3ColorInput::svChangeRequested));
        m_triangleConnections.append(
            connect(next, &QObject::destroyed, this, &Material3ColorWheel::triangleChanged));
    }
    Q_EMIT triangleChanged();
}
} // namespace qavsi_material3
