set(module_target QavsiMaterial3Style)
set_source_files_properties(SmallButtonTheme.qml SmallButtonBackground.qml SmallButtonShadow.qml
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
set_source_files_properties(internal/shadows/Material3Elevation.qml PROPERTIES
    QT_RESOURCE_ALIAS Material3Elevation.qml QT_QML_INTERNAL_TYPE TRUE)
set_source_files_properties(internal/feedback/Material3Ripple.qml PROPERTIES
    QT_RESOURCE_ALIAS Material3Ripple.qml QT_QML_INTERNAL_TYPE TRUE)
set_source_files_properties(internal/menus/Material3MenuItemBackground.qml PROPERTIES
    QT_RESOURCE_ALIAS Material3MenuItemBackground.qml QT_QML_INTERNAL_TYPE TRUE)
foreach(menu_transition IN ITEMS Material3MenuEnterTransition Material3MenuExitTransition)
    set_source_files_properties("internal/menus/${menu_transition}.qml" PROPERTIES
        QT_RESOURCE_ALIAS "${menu_transition}.qml")
endforeach()
set(material3_shadow_sources
    internal/shadows/roundedrectshadow.h internal/shadows/roundedrectshadow.cpp
    internal/shadows/shadowgeometry.h internal/shadows/shadowgeometry.cpp
    internal/shadows/shadowmesh.h internal/shadows/shadowmesh.cpp
    internal/shadows/shadowmaterial.h internal/shadows/shadowmaterial.cpp
    internal/shadows/blurmaskshadow.h internal/shadows/blurmaskshadow.cpp
    internal/shadows/blurmaskmaterial.h internal/shadows/blurmaskmaterial.cpp
    internal/shadows/blurmaskmath.h internal/shadows/blurmaskmath.cpp)
set(material3_menu_files
    internal/menus/Material3MenuDelegate.qml
    internal/menus/Material3MenuParameters.qml
    internal/menus/Material3MenuShadow.qml)
foreach(menu_file IN LISTS material3_menu_files)
    get_filename_component(logical_name "${menu_file}" NAME)
    set_source_files_properties("${menu_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_field_files
    internal/fields/Material3TextFieldTheme.qml
    internal/fields/Material3TextFieldVariation.qml
    internal/fields/Material3TextFieldParameters.qml
    internal/fields/Material3TextFieldDelegate.qml
    internal/fields/Material3TextFieldBackground.qml
    internal/fields/Material3TextFieldBinding.qml
    internal/fields/Material3TextFieldDecorations.qml
    internal/fields/Material3FieldOutline.qml)
foreach(field_file IN LISTS material3_field_files)
    get_filename_component(logical_name "${field_file}" NAME)
    set_source_files_properties("${field_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_combo_files
    internal/combobox/Material3ComboBoxParameters.qml
    internal/combobox/Material3ComboBoxVariation.qml
    internal/combobox/Material3ComboBoxVariations.qml
    internal/combobox/Material3ComboBoxDelegate.qml
    internal/combobox/Material3ComboBoxBackground.qml
    internal/combobox/Material3ComboBoxIndicator.qml
    internal/combobox/Material3ComboBoxBridge.qml
    internal/combobox/Material3ComboBoxPopup.qml
    internal/combobox/Material3ComboBoxDisplay.qml)
foreach(combo_file IN LISTS material3_combo_files)
    get_filename_component(logical_name "${combo_file}" NAME)
    set_source_files_properties("${combo_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
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
set(material3_chip_files
    internal/chips/Material3ChipDelegate.qml
    internal/chips/Material3ChipParameters.qml
    internal/chips/Material3ChipVariation.qml
    internal/chips/Material3ChipVariations.qml
    internal/chips/Material3ChipBackground.qml)
foreach(chip_file IN LISTS material3_chip_files)
    get_filename_component(logical_name "${chip_file}" NAME)
    set_source_files_properties("${chip_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_checkbox_files
    internal/checkboxes/Material3CheckBoxDelegate.qml
    internal/checkboxes/Material3CheckBoxParameters.qml
    internal/checkboxes/Material3CheckBoxIndicator.qml)
foreach(checkbox_file IN LISTS material3_checkbox_files)
    get_filename_component(logical_name "${checkbox_file}" NAME)
    set_source_files_properties("${checkbox_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_badge_files
    internal/badges/Material3BadgeParameters.qml
    internal/badges/Material3BadgeDelegate.qml
    internal/badges/Material3BadgeBackground.qml
    internal/badges/Material3BadgeVariation.qml
    internal/badges/Material3BadgeVariations.qml)
foreach(badge_file IN LISTS material3_badge_files)
    get_filename_component(logical_name "${badge_file}" NAME)
    set_source_files_properties("${badge_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_radio_files
    internal/radiobuttons/Material3RadioButtonDelegate.qml
    internal/radiobuttons/Material3RadioButtonParameters.qml
    internal/radiobuttons/Material3RadioButtonIndicator.qml)
foreach(radio_file IN LISTS material3_radio_files)
    get_filename_component(logical_name "${radio_file}" NAME)
    set_source_files_properties("${radio_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
set(material3_switch_files
    internal/switches/Material3SwitchDelegate.qml
    internal/switches/Material3SwitchParameters.qml
    internal/switches/Material3SwitchIndicator.qml
)
foreach(family_file IN LISTS material3_switch_files)
    get_filename_component(logical_name "${family_file}" NAME)
    set_source_files_properties("${family_file}" PROPERTIES QT_RESOURCE_ALIAS "${logical_name}")
    if(NOT logical_name STREQUAL "Material3NavigationContent.qml")
        set_source_files_properties("${family_file}" PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
    endif()
endforeach()
set(material3_navigation_files
    internal/navigation/Material3NavigationParameters.qml
    internal/navigation/Material3NavigationDelegate.qml
    internal/navigation/Material3NavigationItemBackground.qml
    internal/navigation/Material3TabBarBackground.qml
    internal/navigation/Material3NavigationVariations.qml
    internal/navigation/Material3NavigationRailVariation.qml
    internal/navigation/Material3NavigationContent.qml
)
foreach(family_file IN LISTS material3_navigation_files)
    get_filename_component(logical_name "${family_file}" NAME)
    set_source_files_properties("${family_file}" PROPERTIES QT_RESOURCE_ALIAS "${logical_name}")
    if(NOT logical_name STREQUAL "Material3NavigationContent.qml")
        set_source_files_properties("${family_file}" PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
    endif()
endforeach()
set(material3_slider_files
    internal/sliders/Material3SliderParameters.qml
    internal/sliders/Material3SliderDelegate.qml
    internal/sliders/Material3SliderTrack.qml
    internal/sliders/Material3SliderBackground.qml
    internal/sliders/Material3SliderHandle.qml
    internal/sliders/Material3SliderVariation.qml
)
foreach(family_file IN LISTS material3_slider_files)
    get_filename_component(logical_name "${family_file}" NAME)
    set_source_files_properties("${family_file}" PROPERTIES QT_RESOURCE_ALIAS "${logical_name}")
    if(NOT logical_name STREQUAL "Material3NavigationContent.qml")
        set_source_files_properties("${family_file}" PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
    endif()
endforeach()
set(material3_progress_files
    internal/progress/Material3ProgressParameters.qml
    internal/progress/Material3ProgressDelegate.qml
    internal/progress/Material3ProgressIndicator.qml
    internal/progress/Material3ProgressVisual.qml)
foreach(progress_file IN LISTS material3_progress_files)
    get_filename_component(logical_name "${progress_file}" NAME)
    set_source_files_properties("${progress_file}" PROPERTIES
        QT_RESOURCE_ALIAS "${logical_name}" QT_QML_INTERNAL_TYPE TRUE)
endforeach()
qt_add_qml_module(${module_target} SHARED
    URI Qavsi.Material3.Style
    PLUGIN_TARGET ${module_target}Plugin
    IMPORTS TARGET QavsiMaterial3Theme Qavsi.Icons
    IMPORT_PATH "${QavsiIcons_QML_IMPORT_DIR}"
    DEPENDENCIES QtQuick.Controls.impl QtQuick.Shapes
    QML_FILES internal/feedback/Material3Ripple.qml
        internal/menus/Material3MenuItemBackground.qml
        internal/menus/Material3MenuEnterTransition.qml
        internal/menus/Material3MenuExitTransition.qml
        Material3ProgressContent.qml ${material3_progress_files}
        Material3ButtonContent.qml Material3ChipContent.qml Material3MenuItemContent.qml Material3Badge.qml ${material3_badge_files} ${material3_advanced_files} ${material3_menu_files} ${material3_field_files} ${material3_combo_files}
        ${material3_switch_files} ${material3_navigation_files} ${material3_slider_files} ${material3_radio_files} ${material3_checkbox_files} ${material3_chip_files}
        internal/shadows/Material3Elevation.qml
        Material3Style.qml SmallButtonTheme.qml SmallButtonBackground.qml SmallButtonShadow.qml
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
    SOURCES internal/progress/materialprogresspaint.h internal/progress/materialprogresspaint.cpp
        materialbuttonfeedback.h materialbuttonfeedback.cpp ${material3_shadow_sources}
        textfieldsupport.h textfieldsupport.cpp
        comboboxsupport.h comboboxsupport.cpp
        internal/sliders/slidersupport.h internal/sliders/slidersupport.cpp
        internal/radiobuttons/radiobuttonsupport.h internal/radiobuttons/radiobuttonsupport.cpp
    OUTPUT_TARGETS module_auxiliary_targets)
qt_add_shaders(${module_target} "qavsi_material3_small_button_shaders"
    PREFIX "/Qavsi/Material3/Style"
    FILES shaders/smallbuttonfeedback.frag)
qt_add_shaders(${module_target} "qavsi_material3_shadow_shaders"
    PREFIX "/Qavsi/Material3/Style"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/internal/shadows"
    BATCHABLE
    # Select interpolation by shader target, independent of the Qt OpenGL build flavor.
    PERTARGETCOMPILE
    GLSL 150,140,130,330,300es
    FILES internal/shadows/shaders/shadow.vert internal/shadows/shaders/shadow.frag
        internal/shadows/shaders/blur_mask.vert internal/shadows/shaders/blur_mask.frag)
set_target_properties(${module_target} PROPERTIES EXPORT_NAME Style VERSION ${PROJECT_VERSION} SOVERSION 0.1)
set_target_properties(${module_target}Plugin PROPERTIES EXPORT_NAME StylePlugin)
target_compile_features(${module_target} PUBLIC cxx_std_20)
target_include_directories(${module_target} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/shadows"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/progress"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/sliders"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/radiobuttons")
target_link_libraries(${module_target} PUBLIC QavsiMaterial3::Theme QavsiIcons::Core PRIVATE Qt6::Quick Qt6::LabsStyleKit)
add_library(QavsiMaterial3::Style ALIAS ${module_target})
include("${PROJECT_SOURCE_DIR}/cmake/InstallQmlModule.cmake")
