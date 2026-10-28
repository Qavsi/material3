// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#include <QColor>
#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QSignalSpy>

#include <limits>
#include <memory>

namespace {
int assertions = 0;
int failures = 0;

void expect(bool value, const QString &message)
{
    ++assertions;
    if (!value) {
        ++failures;
        qCritical().noquote() << "FAIL:" << message;
    }
}

std::unique_ptr<QObject> create(QQmlEngine &engine, const QByteArray &source,
                                const QVariantMap &inputs = {})
{
    QQmlComponent component(&engine);
    component.setData(source, QUrl(QStringLiteral("qrc:/qavsi-material3-tests/Fixture.qml")));
    auto object = std::unique_ptr<QObject>(component.createWithInitialProperties(inputs));
    expect(object != nullptr, component.errorString());
    return object;
}

QColor color(QObject *object, const char *name)
{
    return object->property(name).value<QColor>();
}

QVariantMap palette(QObject *theme, const QJsonObject &roles)
{
    QVariantMap result;
    for (auto role = roles.begin(); role != roles.end(); ++role)
        result.insert(role.key(), color(theme, role.key().toUtf8().constData()));
    return result;
}

QByteArray themeSource()
{
    return "import QtQuick\nimport Qavsi.Material3.Theme\nMaterial3Theme {}";
}
} // namespace

int main(int argc, char **argv)
{
    QGuiApplication application(argc, argv);
    QQmlEngine engine;
    engine.addImportPath(QString::fromUtf8(QAVSI_COLOR_IMPORT_PATH));
    QSignalSpy warnings(&engine, &QQmlEngine::warnings);
    QFile reference(QStringLiteral(":/qavsi-material3-tests/material-color-reference.json"));
    expect(reference.open(QIODevice::ReadOnly), QStringLiteral("independent QCM reference opens"));
    QJsonParseError parseError;
    const auto document = QJsonDocument::fromJson(reference.readAll(), &parseError);
    expect(parseError.error == QJsonParseError::NoError && document.isObject(),
           QStringLiteral("independent QCM reference is valid JSON"));
    const auto evidence = document.object();
    const auto cases = evidence.value(QStringLiteral("cases")).toArray();
    const auto roles = evidence.value(QStringLiteral("currentQavsiRoleMapping")).toObject();
    auto theme = create(engine, themeSource());
    if (!theme || cases.isEmpty() || roles.isEmpty())
        return 2;

    expect(!theme->property("dynamicColors").toBool(), QStringLiteral("legacy palette remains the default"));
    expect(color(theme.get(), "primary") == QColor(QStringLiteral("#6750a4"))
               && color(theme.get(), "surface") == QColor(QStringLiteral("#fef7ff")),
           QStringLiteral("legacy light primary and surface stay unchanged"));
    theme->setProperty("dark", true);
    expect(color(theme.get(), "primary") == QColor(QStringLiteral("#d0bcff"))
               && color(theme.get(), "surface") == QColor(QStringLiteral("#141218")),
           QStringLiteral("legacy dark primary and surface stay unchanged"));
    theme->setProperty("dynamicColors", true);
    for (const auto &entry : cases) {
        const auto test = entry.toObject();
        const auto seed = test.value(QStringLiteral("seed")).toString();
        const auto scheme = test.value(QStringLiteral("scheme")).toString();
        const bool dark = test.value(QStringLiteral("dark")).toBool();
        expect(theme->setProperty("seedColor", QColor(seed))
                   && theme->setProperty("scheme", scheme == QStringLiteral("Neutral") ? 0 : 1)
                   && theme->setProperty("dark", dark)
                   && theme->setProperty("contrastLevel", 0.0),
               QStringLiteral("dynamic inputs update the same Theme instance"));
        const auto expected = test.value(QStringLiteral("roles")).toObject();
        expect(color(theme.get(), "errorForeground") == QColor(expected.value(QStringLiteral("on_error")).toString()),
               QStringLiteral("badge error foreground matches the independent QCM on_error role"));
        for (auto role = roles.begin(); role != roles.end(); ++role) {
            const auto name = role.key().toUtf8();
            const auto target = QColor(expected.value(role.value().toString()).toString());
            const auto actual = color(theme.get(), name.constData());
            expect(target.isValid() && actual == target,
                   QStringLiteral("QCM exact ARGB %1/%2/%3 %4 expected %5 actual %6")
                       .arg(seed, scheme, dark ? QStringLiteral("Dark") : QStringLiteral("Light"),
                            role.key(), target.name(QColor::HexArgb), actual.name(QColor::HexArgb)));
        }
    }

    const auto dynamicColor = color(theme.get(), "primary");
    theme->setProperty("dynamicColors", false);
    expect(color(theme.get(), "primary") == QColor(QStringLiteral("#d0bcff")),
           QStringLiteral("disabling dynamic colors restores the static dark palette"));
    theme->setProperty("dynamicColors", true);
    expect(color(theme.get(), "primary") == dynamicColor,
           QStringLiteral("re-enabling dynamic colors restores the live scheme"));
    const auto savedSeed = color(theme.get(), "seedColor");
    const auto savedScheme = theme->property("scheme").toInt();
    const auto savedPalette = palette(theme.get(), roles);
    theme->setProperty("seedColor", QColor());
    theme->setProperty("scheme", 999);
    theme->setProperty("contrastLevel", std::numeric_limits<double>::quiet_NaN());
    expect(color(theme.get(), "seedColor") == savedSeed
               && theme->property("scheme").toInt() == savedScheme
               && theme->property("contrastLevel").toDouble() == 0.0
               && palette(theme.get(), roles) == savedPalette,
           QStringLiteral("invalid seed, scheme and NaN preserve the last valid palette through Theme aliases"));
    theme->setProperty("contrastLevel", std::numeric_limits<double>::infinity());
    expect(theme->property("contrastLevel").toDouble() == 0.0,
           QStringLiteral("nonfinite contrast is rejected"));
    theme->setProperty("contrastLevel", 3.0);
    const auto highContrast = palette(theme.get(), roles);
    expect(theme->property("contrastLevel").toDouble() == 1.0 && highContrast != savedPalette,
           QStringLiteral("high contrast clamps to one and generates a changed palette"));
    theme->setProperty("contrastLevel", -3.0);
    expect(theme->property("contrastLevel").toDouble() == -1.0
               && palette(theme.get(), roles) != highContrast,
           QStringLiteral("low contrast clamps to minus one and generates a distinct palette"));
    theme->setProperty("contrastLevel", 0.0);
    QColor alphaSeed(QStringLiteral("#6750a4"));
    alphaSeed.setAlpha(32);
    theme->setProperty("seedColor", alphaSeed);
    expect(color(theme.get(), "seedColor") == QColor(QStringLiteral("#6750a4")),
           QStringLiteral("seed alpha is normalized to opaque before generation"));

    auto overrideRoot = create(engine, R"(
        import QtQuick
        import Qavsi.Material3.Theme
        QtObject {
            id: root
            property color requestedPrimary: "#123456"
            property Material3Theme bound: Material3Theme {
                dynamicColors: true
                primary: root.requestedPrimary
            }
            property Material3Theme explicitRole: Material3Theme {
                dynamicColors: true
                primary: "#aabbcc"
            }
        })");
    if (!overrideRoot)
        return 2;
    auto *bound = overrideRoot->property("bound").value<QObject *>();
    auto *explicitRole = overrideRoot->property("explicitRole").value<QObject *>();
    expect(bound && explicitRole, QStringLiteral("caller override fixtures exist"));
    if (bound && explicitRole) {
        for (auto *fixture : {bound, explicitRole}) {
            fixture->setProperty("seedColor", QColor(QStringLiteral("#bee7fd")));
            fixture->setProperty("scheme", 0);
            fixture->setProperty("dark", true);
            fixture->setProperty("dynamicColors", false);
            fixture->setProperty("dynamicColors", true);
        }
        expect(color(bound, "primary") == QColor(QStringLiteral("#123456"))
                   && color(explicitRole, "primary") == QColor(QStringLiteral("#aabbcc")),
               QStringLiteral("seed, scheme, mode and dynamic toggle preserve explicit caller color ownership"));
        overrideRoot->setProperty("requestedPrimary", QColor(QStringLiteral("#654321")));
        expect(color(bound, "primary") == QColor(QStringLiteral("#654321")),
               QStringLiteral("the caller color binding remains live after dynamic updates"));
    }

    {
        QQmlEngine secondEngine;
        secondEngine.addImportPath(QString::fromUtf8(QAVSI_COLOR_IMPORT_PATH));
        auto isolated = create(secondEngine, themeSource(), {{"dynamicColors", true},
            {"seedColor", QColor(QStringLiteral("#bee7fd"))}, {"scheme", 0}, {"dark", false}});
        if (!isolated)
            return 2;
        const auto isolatedPalette = palette(isolated.get(), roles);
        theme->setProperty("seedColor", QColor(QStringLiteral("#006875")));
        theme->setProperty("dark", false);
        expect(palette(isolated.get(), roles) == isolatedPalette && palette(theme.get(), roles) != isolatedPalette,
               QStringLiteral("separate engines and Theme instances do not share mutable palettes"));
    }
    expect(!palette(theme.get(), roles).isEmpty(), QStringLiteral("destroying another engine leaves the surviving Theme usable"));

    expect(warnings.isEmpty(), QStringLiteral("no QML warnings during dynamic color transitions"));
    qInfo() << "Material colors:" << "assertions" << assertions << "failures" << failures;
    return failures ? 1 : 0;
}
