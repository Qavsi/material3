set(module_target QavsiMaterial3Style)
set_source_files_properties(SmallButtonTheme.qml SmallButtonBackground.qml
    SmallButtonDelegate.qml SmallButtonParameters.qml
    ButtonVariation.qml ButtonSizeVariation.qml IconButtonVariation.qml
    IconButtonSizeVariation.qml ButtonVariations.qml
    PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
# Recipe scripts are private explicit imports, not module-wide script exports.
set_source_files_properties(
    internal/recipes/Material3ButtonRecipe.js
    internal/recipes/Material3IconButtonRecipe.js
    internal/recipes/Material3FabRecipe.js
    internal/recipes/Material3JoinedRecipe.js
    internal/recipes/Material3ConnectedButtonRecipe.js
    internal/recipes/Material3SegmentedButtonRecipe.js
    internal/recipes/Material3SplitButtonRecipe.js
    PROPERTIES QT_QML_SKIP_QMLDIR_ENTRY TRUE)
set(material3_advanced_files
    internal/actions/advanced/Material3AdvancedButtonParameters.qml
    internal/actions/advanced/Material3JoinedButtonDelegate.qml
    internal/actions/advanced/Material3JoinedButtonBackground.qml
    internal/actions/advanced/Material3JoinedButtonVariation.qml
    internal/actions/advanced/Material3ConnectedButtonVariation.qml
    internal/actions/advanced/Material3SegmentedButtonVariation.qml
    internal/actions/advanced/Material3SplitButtonVariation.qml
    internal/actions/advanced/Material3FabVariation.qml
    internal/actions/advanced/Material3AdvancedButtonVariations.qml)
foreach(advanced_file IN LISTS material3_advanced_files)
    get_filename_component(logical_name "${advanced_file}" NAME)
    set_source_files_properties("${advanced_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
foreach(recipe IN ITEMS Button IconButton Fab Joined ConnectedButton SegmentedButton SplitButton)
    set_source_files_properties("internal/recipes/Material3${recipe}Recipe.js" PROPERTIES
        QT_RESOURCE_ALIAS "Material3${recipe}Recipe.js")
endforeach()
qt_add_qml_module(${module_target} SHARED
    URI Qavsi.Material3.Style
    PLUGIN_TARGET ${module_target}Plugin
    IMPORTS TARGET QavsiMaterial3Theme Qavsi.Icons
    IMPORT_PATH "${QavsiIcons_QML_IMPORT_DIR}"
    DEPENDENCIES QtQuick.Effects QtQuick.Controls.impl
    QML_FILES Material3ButtonContent.qml ${material3_advanced_files}
        Material3Style.qml SmallButtonTheme.qml SmallButtonBackground.qml
        SmallButtonDelegate.qml SmallButtonParameters.qml
        ButtonVariation.qml ButtonSizeVariation.qml IconButtonVariation.qml
        IconButtonSizeVariation.qml ButtonVariations.qml
        internal/recipes/Material3ButtonRecipe.js
        internal/recipes/Material3IconButtonRecipe.js
        internal/recipes/Material3FabRecipe.js
        internal/recipes/Material3JoinedRecipe.js
        internal/recipes/Material3ConnectedButtonRecipe.js
        internal/recipes/Material3SegmentedButtonRecipe.js
        internal/recipes/Material3SplitButtonRecipe.js
    SOURCES materialbuttonfeedback.h materialbuttonfeedback.cpp
    OUTPUT_TARGETS module_auxiliary_targets)
qt_add_shaders(${module_target} "qavsi_material3_small_button_shaders"
    PREFIX "/Qavsi/Material3/Style"
    FILES shaders/smallbuttonfeedback.frag)
set_target_properties(${module_target} PROPERTIES EXPORT_NAME Style VERSION ${PROJECT_VERSION} SOVERSION 0.1)
set_target_properties(${module_target}Plugin PROPERTIES EXPORT_NAME StylePlugin)
target_compile_features(${module_target} PUBLIC cxx_std_20)
target_link_libraries(${module_target} PUBLIC QavsiMaterial3::Theme QavsiIcons::Core PRIVATE Qt6::Quick Qt6::LabsStyleKit)
add_library(QavsiMaterial3::Style ALIAS ${module_target})
include("${PROJECT_SOURCE_DIR}/cmake/InstallQmlModule.cmake")
