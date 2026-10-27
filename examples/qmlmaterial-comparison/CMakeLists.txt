cmake_minimum_required(VERSION 3.30)
project(QavsiMaterial3Comparison LANGUAGES CXX)
find_package(Qt6 6.12 REQUIRED COMPONENTS Quick LabsStyleKit Test)
qt_standard_project_setup(REQUIRES 6.12)

if(QAVSI_MATERIAL3_SOURCE AND NOT TARGET QavsiMaterial3::Style)
    set(QAVSI_MATERIAL3_BUILD_EXAMPLE OFF)
    set(QAVSI_MATERIAL3_BUILD_COMPARISON OFF)
    add_subdirectory("${QAVSI_MATERIAL3_SOURCE}" material3)
endif()
if(NOT TARGET QavsiMaterial3::Style)
    find_package(QavsiMaterial3 0.1 CONFIG REQUIRED)
endif()
if(NOT TARGET QavsiIcons::Material)
    find_package(QavsiIcons 0.1 CONFIG REQUIRED COMPONENTS Material)
endif()
foreach(unwanted IN ITEMS Merce::Theme MerceTheme MerceStyle QavsiRuntime)
    if(TARGET ${unwanted})
        message(FATAL_ERROR "Independent comparison must not depend on ${unwanted}")
    endif()
endforeach()

qt_add_executable(qavsi-material3-comparison MACOSX_BUNDLE
    main.cpp checks.cpp menu-motion-checks.cpp menu-motion-checks.h)
set_target_properties(qavsi-material3-comparison PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.qavsi.material3.comparison)
file(GLOB comparison_icons CONFIGURE_DEPENDS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "icons/*.svg")
qt_add_qml_module(qavsi-material3-comparison URI Qavsi.Material3.Comparison
    IMPORTS Qavsi.Icons.Material
    QML_FILES Main.qml ComparisonPage.qml ActionsGallery.qml DemoCard.qml FabMenuExamples.qml ComparisonMetrics.qml
    RESOURCES ${comparison_icons}
    IMPORT_PATH "${QavsiMaterial3_QML_IMPORT_DIR}")
target_compile_features(qavsi-material3-comparison PRIVATE cxx_std_20)
target_compile_definitions(qavsi-material3-comparison PRIVATE $<$<CONFIG:Debug>:QT_QML_DEBUG>)
target_link_libraries(qavsi-material3-comparison PRIVATE Qt6::Quick Qt6::Test QavsiMaterial3::Style QavsiIcons::Material)
enable_testing()
add_test(NAME comparison-software COMMAND qavsi-material3-comparison --check)
set_tests_properties(comparison-software PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software")
