#include <QDebug>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScopedPointer>
#include <QSignalSpy>
#include <QTest>
#include <cmath>

int checkButtonGroupMotion(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool condition, const char *message) {
        if (!condition) { ++failures; qCritical() << "FAIL:" << message; }
    };
    QQmlComponent component(qmlEngine(&window));
    component.setData(R"qml(
        pragma ComponentBehavior: Bound
        import QtQuick
        import QtQuick.Controls as C
        import QtQuick.Templates as T
        import Qt.labs.StyleKit as SK
        import Qavsi.Material3.Style
        import Qavsi.Material3.Theme
        Item {
            id: fixture
            width: 480; height: 56
            property real callerWidth: 90
            property bool reduceMotion: false
            property bool rtl: false
            readonly property Material3Theme fixtureTokens: Material3Theme { }
            LayoutMirroring.enabled: rtl
            LayoutMirroring.childrenInherit: true
            C.ButtonGroup { id: selection }
            Material3ButtonGroup {
                id: group
                objectName: "buttonmotion.group"
                width: parent.width
                tokens: fixture.fixtureTokens
                spacing: 2
                reduceMotion: fixture.reduceMotion
                Repeater {
                    model: 3
                    delegate: SK.Button {
                        id: action
                        required property int index
                        objectName: "buttonmotion.action." + index
                        text: index === 0 ? qsTr("One") : index === 1 ? qsTr("Two") : qsTr("Three")
                        checkable: true
                        checked: index === 0
                        C.ButtonGroup.group: selection
                        SK.StyleVariation.variations: [index === 0 ? "connectedLeading" : "connectedMiddle", "filledTonal"]
                        Material3ButtonGroup.managed: true
                        Material3ButtonGroup.weight: 1
                        width: Material3ButtonGroup.layoutWidth
                        contentItem: Material3ButtonContent { control: action }
                    }
                }
                SK.Button {
                    id: fixed
                    objectName: "buttonmotion.fixed"
                    text: qsTr("Fixed")
                    width: fixture.callerWidth
                    SK.StyleVariation.variations: ["connectedTrailing", "filledTonal"]
                    contentItem: Material3ButtonContent { control: fixed }
                }
            }
        }
    )qml", QUrl());
    const QScopedPointer<QObject> object(component.beginCreate(qmlEngine(&window)->rootContext()));
    auto *fixture = qobject_cast<QQuickItem *>(object.data());
    if (fixture) {
        fixture->setParentItem(window.contentItem());
        fixture->setZ(1000);
    }
    component.completeCreate();
    expect(fixture && component.isReady(), "native button group fixture can be created");
    if (!fixture || !component.isReady()) { qWarning() << component.errors(); return failures; }
    const auto findVisual = [](auto &&self, QQuickItem *root, const QString &name) -> QQuickItem * {
        if (root->objectName() == name) return root;
        for (auto *child : root->childItems())
            if (auto *found = self(self, child, name)) return found;
        return nullptr;
    };
    const auto item = [&](const char *name) { return findVisual(findVisual, fixture, QString::fromLatin1(name)); };
    auto *group = item("buttonmotion.group");
    auto *first = item("buttonmotion.action.0");
    auto *middle = item("buttonmotion.action.1");
    auto *last = item("buttonmotion.action.2");
    auto *fixed = item("buttonmotion.fixed");
    expect(group && first && middle && last && fixed, "native group actions are present");
    if (!group || !first || !middle || !last || !fixed) return failures;
    window.grabWindow();
    const qreal firstWidth = first->width(), middleWidth = middle->width(), lastWidth = last->width();
    const qreal total = firstWidth + middleWidth + lastWidth + fixed->width();
    QSignalSpy activated(middle, SIGNAL(clicked()));
    middle->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyPress(&window, Qt::Key_Space);
    fixture->setProperty("reduceMotion", true);
    window.grabWindow();
    expect(middle->width() > middleWidth && first->width() < firstWidth && last->width() < lastWidth
        && std::abs(first->width() + middle->width() + last->width() + fixed->width() - total) < .01
        && std::abs(fixed->width() - 90) < .01,
        "reduced motion snaps pressed native width, shares only neighbors and preserves the total and caller width");
    QTest::keyRelease(&window, Qt::Key_Space);
    window.grabWindow();
    expect(activated.size() == 1 && middle->property("checked").toBool() && !first->property("checked").toBool()
        && std::abs(middle->width() - middleWidth) < .01,
        "width feedback preserves native activation and exclusive selection and returns immediately");
    fixture->setProperty("rtl", true);
    fixture->setProperty("callerWidth", 100);
    window.grabWindow();
    expect(first->x() > middle->x() && middle->x() > last->x() && last->x() > fixed->x()
        && first->property("mirrored").toBool() && std::abs(fixed->width() - 100) < .01
        && middle->property("checked").toBool(),
        "RTL reverses native positions while caller widths and selection remain live");
    window.contentItem()->forceActiveFocus();
    return failures;
}
