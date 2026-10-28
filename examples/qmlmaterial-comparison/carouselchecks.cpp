#include <QDebug>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScopedPointer>
#include <QSignalSpy>
#include <QStandardItemModel>
#include <QTest>
#include <memory>

int checkCarousel(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&](bool condition, const char *message) {
        if (!condition) { ++failures; qCritical() << "FAIL:" << message; }
    };
    QQmlComponent component(qmlEngine(&window));
    component.setData(R"qml(
        pragma ComponentBehavior: Bound
        import Qt.labs.StyleKit as SK
        import Qavsi.Material3.Style
        Material3Carousel {
            id: fixture
            width: 480; height: 196; reduceMotion: true
            property bool delegateContractIntact: false
            property int expectedSampleValue: 42
            delegate: Material3CarouselItem {
                required property var model
                onClicked: fixture.delegateContractIntact = display === SK.Button.TextBesideIcon
                    && model.sampleValue === fixture.expectedSampleValue
            }
            function showFullScreen(): void { layout = Material3Carousel.FullScreen; }
        }
    )qml", QUrl());
    const QScopedPointer<QObject> object(component.beginCreate(qmlEngine(&window)->rootContext()));
    auto *carousel = qobject_cast<QQuickItem *>(object.data());
    if (carousel) {
        carousel->setParentItem(window.contentItem());
        carousel->setZ(1000);
    }
    component.completeCreate();
    expect(carousel && component.isReady(), "public Carousel fixture can be created");
    if (!carousel || !component.isReady()) return failures;

    auto model = std::make_unique<QStandardItemModel>(10, 1);
    model->setItemRoleNames({{Qt::DisplayRole, "display"}, {Qt::UserRole, "sampleValue"}});
    for (int row = 0; row < model->rowCount(); ++row) {
        model->setData(model->index(row, 0), 0, Qt::DisplayRole);
        model->setData(model->index(row, 0), 42, Qt::UserRole);
    }
    carousel->setProperty("model", QVariant::fromValue(static_cast<QObject *>(model.get())));
    carousel->setProperty("currentIndex", 5);
    QMetaObject::invokeMethod(carousel, "showFullScreen");
    window.grabWindow();
    QSignalSpy activated(carousel, SIGNAL(clicked(int)));
    const auto center = carousel->mapToScene(QPointF(carousel->width() / 2, carousel->height() / 2)).toPoint();
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(carousel->property("currentIndex").toInt() == 5 && activated.size() == 1
        && activated.at(0).at(0).toInt() == 5,
        "runtime layout change keeps the selected card displayed and clickable");
    carousel->setProperty("delegateContractIntact", false);
    carousel->setProperty("expectedSampleValue", 43);
    model->setData(model->index(5, 0), 1, Qt::DisplayRole);
    model->setData(model->index(5, 0), 43, Qt::UserRole);
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, center);
    expect(activated.size() == 2 && carousel->property("delegateContractIntact").toBool(),
        "model role-map updates preserve the native delegate display API");

    model.reset();
    expect(carousel->property("count").toInt() == 0
        && carousel->property("currentIndex").toInt() == 0,
        "destroying the caller model clears Carousel selection and rows safely");
    if (carousel->property("count").toInt() == 0) {
        QMetaObject::invokeMethod(carousel, "next");
        expect(carousel->property("currentIndex").toInt() == 0,
            "empty Carousel navigation remains safe after model destruction");
    }
    window.contentItem()->forceActiveFocus();
    return failures;
}
