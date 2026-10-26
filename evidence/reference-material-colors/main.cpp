#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMetaProperty>
#include <QTextStream>
#include "qml_material/token/color.hpp"

int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    qml_material::MdColorMgr colors;
    colors.setUseSysColorSM(false);
    colors.setUseSysAccentColor(false);
    QJsonArray cases;
    for (const char *seed : {"#bee7fd", "#6750a4", "#006875"}) {
        colors.setAccentColor(QColor(QString::fromLatin1(seed)));
        for (const auto scheme : {qml_material::Enum::PaletteType::PaletteNeutral,
                                  qml_material::Enum::PaletteType::PaletteTonalSpot}) {
            colors.setPaletteType(scheme);
            for (const auto mode : {qml_material::Enum::ThemeMode::Light, qml_material::Enum::ThemeMode::Dark}) {
                colors.setMode(mode);
                QJsonObject roles;
                const auto *meta = colors.metaObject();
                for (int i = meta->propertyOffset(); i < meta->propertyCount(); ++i) {
                    const auto prop = meta->property(i);
                    if (prop.metaType() == QMetaType::fromType<QColor>()
                        && QByteArray(prop.name()) != "accentColor") {
                        const QColor color = prop.read(&colors).value<QColor>();
                        if (!color.isValid()) return 2;
                        roles.insert(QString::fromLatin1(prop.name()), color.name(QColor::HexArgb));
                    }
                }
                if (roles.size() < 40) return 3;
                cases.append(QJsonObject{
                    {"seed", QString::fromLatin1(seed)},
                    {"scheme", scheme == qml_material::Enum::PaletteType::PaletteNeutral ? "Neutral" : "TonalSpot"},
                    {"dark", mode == qml_material::Enum::ThemeMode::Dark},
                    {"contrastLevel", 0.0}, {"roles", roles}});
            }
        }
    }
    QTextStream(stdout) << QJsonDocument(QJsonObject{{"cases", cases}}).toJson(QJsonDocument::Indented);
}
