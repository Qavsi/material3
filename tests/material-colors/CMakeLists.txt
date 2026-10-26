cmake_minimum_required(VERSION 3.30)
project(QavsiMaterialColorsCheck LANGUAGES CXX)
find_package(Qt6 6.12 REQUIRED COMPONENTS Quick LabsStyleKit Test)
qt_standard_project_setup(REQUIRES 6.12)
if(NOT TARGET QavsiMaterial3::Style)
    find_package(QavsiMaterial3 0.1 CONFIG REQUIRED)
endif()

qt_add_executable(qavsi-material-colors-check checks.cpp)
target_compile_features(qavsi-material-colors-check PRIVATE cxx_std_20)
target_link_libraries(qavsi-material-colors-check PRIVATE Qt6::Quick Qt6::Test QavsiMaterial3::Style)
target_compile_definitions(qavsi-material-colors-check PRIVATE
    QAVSI_COLOR_IMPORT_PATH="${QavsiMaterial3_QML_IMPORT_DIR}")
set(color_reference "${CMAKE_CURRENT_LIST_DIR}/../../evidence/material-color-reference.json")
qt_add_resources(qavsi-material-colors-check "material_color_reference"
    PREFIX "/qavsi-material3-tests"
    BASE "${CMAKE_CURRENT_LIST_DIR}/../../evidence"
    FILES "${color_reference}")
enable_testing()
add_test(NAME material-colors COMMAND qavsi-material-colors-check)
set_tests_properties(material-colors PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software")

if(TARGET QavsiMaterialColorUtilities)
    qt_add_executable(qavsi-material-color-utils-check utils-check.cpp)
    target_compile_features(qavsi-material-color-utils-check PRIVATE cxx_std_20)
    get_target_property(mcu_source_dir QavsiMaterialColorUtilities SOURCE_DIR)
    target_include_directories(qavsi-material-color-utils-check PRIVATE "${mcu_source_dir}")
    target_link_libraries(qavsi-material-color-utils-check PRIVATE QavsiMaterialColorUtilities)
    add_test(NAME material-color-utils COMMAND qavsi-material-color-utils-check)
endif()
