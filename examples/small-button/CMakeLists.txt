cmake_minimum_required(VERSION 3.30)
project(QavsiSmallButton LANGUAGES CXX)
find_package(Qt6 6.12 REQUIRED COMPONENTS Quick LabsStyleKit Test)
qt_standard_project_setup(REQUIRES 6.12)

if(QAVSI_MATERIAL3_SOURCE AND NOT TARGET QavsiMaterial3::Style)
    set(QAVSI_MATERIAL3_BUILD_EXAMPLE OFF)
    add_subdirectory("${QAVSI_MATERIAL3_SOURCE}" material3)
endif()
if(NOT TARGET QavsiMaterial3::Style)
    find_package(QavsiMaterial3 0.1 CONFIG REQUIRED)
endif()
foreach(unwanted IN ITEMS Merce::Theme MerceTheme MerceStyle QavsiRuntime)
    if(TARGET ${unwanted})
        message(FATAL_ERROR "Independent example must not depend on ${unwanted}")
    endif()
endforeach()

qt_add_executable(qavsi-small-button MACOSX_BUNDLE main.cpp checks.cpp benchmark.cpp)
set_target_properties(qavsi-small-button PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.qavsi.material3.smallbutton)
qt_add_qml_module(qavsi-small-button URI Qavsi.Material3.SmallButton
    QML_FILES Main.qml SmallButtonPage.qml Benchmark.qml
    IMPORT_PATH "${QavsiMaterial3_QML_IMPORT_DIR}")
target_compile_features(qavsi-small-button PRIVATE cxx_std_20)
target_compile_definitions(qavsi-small-button PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)
target_link_libraries(qavsi-small-button PRIVATE Qt6::Quick Qt6::Test QavsiMaterial3::Style)
enable_testing()
add_test(NAME small-button-software COMMAND qavsi-small-button --check)
set_tests_properties(small-button-software PROPERTIES
    LABELS "controls;software"
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software")
