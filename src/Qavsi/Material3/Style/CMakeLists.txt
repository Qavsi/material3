set(module_target QavsiMaterial3Style)
set_source_files_properties(SmallButtonTheme.qml SmallButtonBackground.qml
    SmallButtonDelegate.qml SmallButtonParameters.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
qt_add_qml_module(${module_target} SHARED
    URI Qavsi.Material3.Style
    PLUGIN_TARGET ${module_target}Plugin
    IMPORTS TARGET QavsiMaterial3Theme
    QML_FILES Material3Style.qml SmallButtonTheme.qml SmallButtonBackground.qml
        SmallButtonDelegate.qml SmallButtonParameters.qml
    SOURCES materialbuttonfeedback.h materialbuttonfeedback.cpp
    OUTPUT_TARGETS module_auxiliary_targets)
qt_add_shaders(${module_target} "qavsi_material3_small_button_shaders"
    PREFIX "/Qavsi/Material3/Style"
    FILES shaders/smallbuttonfeedback.frag)
set_target_properties(${module_target} PROPERTIES EXPORT_NAME Style VERSION ${PROJECT_VERSION} SOVERSION 0.1)
set_target_properties(${module_target}Plugin PROPERTIES EXPORT_NAME StylePlugin)
target_compile_features(${module_target} PUBLIC cxx_std_20)
target_link_libraries(${module_target} PUBLIC QavsiMaterial3::Theme PRIVATE Qt6::Quick Qt6::LabsStyleKit)
add_library(QavsiMaterial3::Style ALIAS ${module_target})
include("${PROJECT_SOURCE_DIR}/cmake/InstallQmlModule.cmake")
