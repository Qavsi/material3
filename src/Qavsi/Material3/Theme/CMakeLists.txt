set(module_target QavsiMaterial3Theme)
qt_add_qml_module(${module_target} SHARED
    URI Qavsi.Material3.Theme
    PLUGIN_TARGET ${module_target}Plugin
    SOURCES materialcolorscheme.cpp materialcolorscheme.h
    QML_FILES Material3Theme.qml
    OUTPUT_TARGETS module_auxiliary_targets)
set_target_properties(${module_target} PROPERTIES EXPORT_NAME Theme VERSION ${PROJECT_VERSION} SOVERSION 0.1)
set_target_properties(${module_target}Plugin PROPERTIES EXPORT_NAME ThemePlugin)
target_compile_features(${module_target} PUBLIC cxx_std_20)
target_link_libraries(${module_target} PRIVATE Qt6::Quick)
target_sources(${module_target} PRIVATE $<TARGET_OBJECTS:QavsiMaterialColorUtilities>)
target_include_directories(${module_target} PRIVATE "${PROJECT_SOURCE_DIR}/third_party/material-color-utilities")
add_library(QavsiMaterial3::Theme ALIAS ${module_target})
include("${PROJECT_SOURCE_DIR}/cmake/InstallQmlModule.cmake")
