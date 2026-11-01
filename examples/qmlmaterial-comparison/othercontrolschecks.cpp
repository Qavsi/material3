#include <QFont>
#include <QImage>
#include <QMetaObject>
#include <QQmlEngine>
#include <QQmlListReference>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTest>

int checkOtherControls(QQuickWindow &window)
{
    int failures = 0;
    const auto expect = [&failures](bool ok, const char *message) {
        if (!ok) { ++failures; qCritical() << "FAIL:" << message; }
    };
    auto *gallery = window.findChild<QQuickItem *>("comparison.otherControls");
    auto *spin = window.findChild<QQuickItem *>("comparison.spinBox");
    auto *area = window.findChild<QQuickItem *>("comparison.textArea");
    auto *filled = window.findChild<QQuickItem *>("comparison.textArea.filled");
    auto *sheet = window.findChild<QObject *>("comparison.bottomSheet");
    auto *standardSheet = window.findChild<QObject *>("comparison.bottomSheet.standard");
    expect(gallery && spin && area && filled && sheet && standardSheet, "native other-controls gallery is available");
    if (!gallery || !spin || !area || !filled || !sheet || !standardSheet) return failures;
    const auto quantity = gallery->property("quantity");
    const auto notes = gallery->property("notes");
    expect(qFuzzyCompare(spin->implicitHeight(), 24.0) && spin->property("font").value<QFont>().pixelSize() == 11,
           "native SpinBox uses QCM compact geometry and LabelSmall");
    spin->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_Up);
    expect(gallery->property("quantity").toInt() == 4, "native stepping updates the caller value");
    auto *viewport = window.findChild<QQuickItem *>("comparison.viewport");
    if (viewport) {
        auto *content = viewport->property("contentItem").value<QQuickItem *>();
        viewport->setProperty("contentY", spin->mapToItem(content, QPointF()).y() - viewport->height() / 2);
        window.grabWindow();
    }
    auto *up = QQmlProperty::read(spin, QStringLiteral("up.indicator")).value<QQuickItem *>();
    expect(up && up->width() > 0 && up->height() > 0 && spin->boundingRect().contains(up->mapToItem(spin, up->boundingRect().center())),
           "native SpinBox up indicator stays in its hit region");
    auto *down = QQmlProperty::read(spin, QStringLiteral("down.indicator")).value<QQuickItem *>();
    expect(up && down && qFuzzyCompare(up->x(), down->x()), "stepper arrows share the native vertical column");
    if (up) {
        QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, up->mapToScene(up->boundingRect().center()).toPoint());
        expect(gallery->property("quantity").toInt() == 5, "native pointer stepping reaches the caller");
        if (down) {
            QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, down->mapToScene(down->boundingRect().center()).toPoint());
            expect(gallery->property("quantity").toInt() == 4, "native pointer decrement reaches the caller");
        }
    }
    const bool mirrorSet = QQmlProperty::write(spin, QStringLiteral("LayoutMirroring.enabled"), true, qmlContext(spin));
    window.grabWindow();
    expect(mirrorSet && spin->property("mirrored").toBool() && up && down && qFuzzyCompare(up->x(), down->x())
               && spin->boundingRect().contains(up->mapToItem(spin, up->boundingRect().center())),
           "native RTL keeps both stepper arrows in one hit column");
    QQmlProperty::write(spin, QStringLiteral("LayoutMirroring.enabled"), false, qmlContext(spin));
    gallery->setProperty("quantity", 9);
    QTest::keyClick(&window, Qt::Key_Up);
    expect(gallery->property("quantity").toInt() == 0, "native SpinBox preserves wrap at its range limit");
    auto *editor = spin->property("contentItem").value<QQuickItem *>();
    expect(editor, "native SpinBox retains an editable content item");
    if (editor) {
        editor->forceActiveFocus(Qt::TabFocusReason);
        QMetaObject::invokeMethod(editor, "selectAll");
        QTest::keyClick(&window, Qt::Key_7);
        QTest::keyClick(&window, Qt::Key_Return);
        expect(gallery->property("quantity").toInt() == 7, "native SpinBox commits validated text");
    }
    spin->setEnabled(false);
    QTest::keyClick(&window, Qt::Key_Up);
    expect(spin->property("value").toInt() == 7, "disabled SpinBox blocks keyboard stepping");
    spin->setEnabled(true);
    area->forceActiveFocus(Qt::TabFocusReason);
    QTest::keyClick(&window, Qt::Key_A);
    QTest::keyClick(&window, Qt::Key_Return);
    QTest::keyClick(&window, Qt::Key_B);
    expect(area->property("text").toString() == QStringLiteral("a\nb"),
           "native TextArea preserves multiline keyboard editing");
    area->setProperty("readOnly", true);
    QTest::keyClick(&window, Qt::Key_C);
    expect(area->property("text").toString() == QStringLiteral("a\nb"), "read-only TextArea blocks edits");
    area->setProperty("readOnly", false);
    gallery->setProperty("notes", QStringLiteral("caller notes"));
    expect(area->property("text").toString() == QStringLiteral("caller notes")
               && area->property("font").value<QFont>().pixelSize() == 16,
           "TextArea preserves caller text ownership and Material3 BodyLarge");
    expect(area->property("placeholderTextColor").value<QColor>().alpha() == 0
               && filled->property("placeholderTextColor").value<QColor>().alpha() == 0,
           "TextArea uses one managed floating caption in both appearances");
    auto *theme = gallery->property("tokens").value<QObject *>();
    expect(theme && area->property("selectionColor") == theme->property("primary")
               && editor && editor->property("selectionColor") == theme->property("primary"),
           "native input selection uses Material3 primary ink");
    const bool originalTheme = window.property("darkMode").toBool();
    const int originalWidth = window.width();
    window.resize(900, window.height());
    const auto beforeModal = window.grabWindow();
    sheet->setProperty("modal", true);
    QMetaObject::invokeMethod(sheet, "open");
    expect(QTest::qWaitFor([&] { return sheet->property("opened").toBool(); }), "modal bottom sheet opens natively");
    const QQmlListReference sheetContent(sheet, "content");
    auto *callerContent = sheetContent.count() > 0 ? qobject_cast<QQuickItem *>(sheetContent.at(0)) : nullptr;
    if (callerContent) {
        const auto originalY = callerContent->y();
        callerContent->setY(20);
        window.grabWindow();
        expect(sheet->property("implicitContentHeight").toReal() >= callerContent->y() + callerContent->height(),
               "bottom sheet natural height includes a caller content offset");
        callerContent->setY(originalY);
    } else {
        expect(false, "bottom sheet exposes its caller-owned content list");
    }
    expect(sheet->property("edge").toInt() == Qt::BottomEdge
               && sheet->property("width").toReal() <= window.width()
               && sheet->property("height").toReal() > 48
               && sheet->property("x").toReal() >= 0 && sheet->property("dim").toBool(),
           "bottom sheet stays in the host window with a modal scrim");
    const auto withModal = window.grabWindow();
    expect(!beforeModal.isNull() && !withModal.isNull()
               && beforeModal.pixelColor(0, 0) != withModal.pixelColor(0, 0),
           "modal scrim covers the host even outside a width-limited sheet");
    window.setProperty("darkMode", !originalTheme);
    auto *tokens = sheet->property("tokens").value<QObject *>();
    expect(tokens && tokens->property("dark").toBool() == !originalTheme, "open bottom sheet follows selected Theme");
    auto *heading = window.findChild<QQuickItem *>("comparison.bottomSheet.heading");
    expect(heading && tokens && heading->property("color") == tokens->property("surfaceForeground"),
           "native labels remain readable on the selected sheet Theme");
    QTest::keyClick(&window, Qt::Key_Escape);
    expect(QTest::qWaitFor([&] { return !sheet->property("visible").toBool(); }), "Escape dismisses modal bottom sheet");
    QMetaObject::invokeMethod(sheet, "open");
    expect(QTest::qWaitFor([&] { return sheet->property("opened").toBool(); }), "modal bottom sheet reopens");
    QTest::mouseClick(&window, Qt::LeftButton, Qt::NoModifier, QPoint(4, 4));
    expect(QTest::qWaitFor([&] { return !sheet->property("visible").toBool(); }),
           "press outside the width-limited sheet dismisses it across the full overlay");
    QMetaObject::invokeMethod(standardSheet, "open");
    expect(QTest::qWaitFor([&] { return standardSheet->property("opened").toBool(); })
               && !standardSheet->property("dim").toBool() && !standardSheet->property("focus").toBool(),
           "standard sheet keeps the surrounding application interactive");
    area->forceActiveFocus(Qt::TabFocusReason);
    area->setProperty("cursorPosition", area->property("length"));
    QTest::keyClick(&window, Qt::Key_C);
    expect(area->property("text").toString().endsWith(u'c'), "TextArea remains editable beside a standard sheet");
    QMetaObject::invokeMethod(standardSheet, "close");
    expect(QTest::qWaitFor([&] { return !standardSheet->property("visible").toBool(); }), "standard sheet closes natively");
    window.setProperty("darkMode", originalTheme);
    window.resize(originalWidth, window.height());
    gallery->setProperty("quantity", quantity);
    gallery->setProperty("notes", notes);
    return failures;
}
