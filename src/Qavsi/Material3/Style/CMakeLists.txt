set(module_target QavsiMaterial3Style)
set_source_files_properties(Material3DialogShadow.qml Material3DialogDelegate.qml PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
set_source_files_properties(Material3ControlTheme.qml SmallButtonBackground.qml SmallButtonShadow.qml
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
set(material3_field_files
    internal/fields/Material3TextFieldVariations.qml
    internal/fields/Material3TextFieldVariation.qml
    internal/fields/Material3TextFieldParameters.qml
    internal/fields/Material3TextFieldDelegate.qml
    internal/fields/Material3TextFieldBackground.qml
    internal/fields/Material3TextFieldBinding.qml
    internal/fields/Material3TextFieldDecorations.qml
    internal/fields/Material3FieldOutline.qml)
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
set(material3_checkbox_files
    internal/checkboxes/Material3CheckBoxDelegate.qml
    internal/checkboxes/Material3CheckBoxParameters.qml
    internal/checkboxes/Material3CheckBoxIndicator.qml)
set(material3_badge_files
    internal/badges/Material3BadgeParameters.qml
    internal/badges/Material3BadgeDelegate.qml
    internal/badges/Material3BadgeBackground.qml
    internal/badges/Material3BadgeVariation.qml
    internal/badges/Material3BadgeVariations.qml)
set(material3_radio_files
    internal/radiobuttons/Material3RadioButtonDelegate.qml
    internal/radiobuttons/Material3RadioButtonParameters.qml
    internal/radiobuttons/Material3RadioButtonIndicator.qml
    internal/radiobuttons/Material3ColorChoiceVariation.qml)
set(material3_switch_files
    internal/switches/Material3SwitchDelegate.qml
    internal/switches/Material3SwitchParameters.qml
    internal/switches/Material3SwitchIndicator.qml
)
set(material3_navigation_files
    internal/navigation/Material3NavigationParameters.qml
    internal/navigation/Material3NavigationDelegate.qml
    internal/navigation/Material3NavigationItemBackground.qml
    internal/navigation/Material3TabBarBackground.qml
    internal/navigation/Material3NavigationVariations.qml
    internal/navigation/Material3NavigationRailVariation.qml
    internal/navigation/Material3NavigationContent.qml
)
set(material3_app_navigation_files
    internal/appnavigation/Material3DestinationVariation.qml
    internal/appnavigation/Material3AppDestinations.qml
    internal/appnavigation/Material3AppNavigationDelegate.qml
    internal/appnavigation/Material3SearchBackground.qml
    internal/appnavigation/Material3AppNavigationVariations.qml)
set(material3_slider_files
    internal/sliders/Material3SliderParameters.qml
    internal/sliders/Material3SliderDelegate.qml
    internal/sliders/Material3SliderTrack.qml
    internal/sliders/Material3SliderBackground.qml
    internal/sliders/Material3SliderHandle.qml
    internal/sliders/Material3SliderVariation.qml
)
set(material3_carousel_files
    internal/carousel/Material3CarouselViewport.qml
    internal/carousel/Material3CarouselVariations.qml)
set(material3_progress_files
    internal/progress/Material3BusyIndicatorParameters.qml
    internal/progress/Material3BusyIndicatorDelegate.qml
    internal/progress/Material3BusyIndicatorIndicator.qml
    internal/progress/Material3BusyIndicatorVisual.qml
    internal/progress/Material3ProgressVariations.qml
    internal/progress/Material3ProgressParameters.qml
    internal/progress/Material3ProgressDelegate.qml
    internal/progress/Material3ProgressIndicator.qml
    internal/progress/Material3ProgressVisual.qml)
set(material3_picker_files
    internal/pickers/Material3DateNavigation.qml
    internal/pickers/Material3ColorWheel.qml
    internal/pickers/Material3ColorTriangle.qml
    internal/pickers/Material3DateInput.qml
    internal/pickers/Material3PickerDialog.qml
    internal/pickers/Material3PickerVariations.qml
    internal/pickers/Material3ColorChannel.qml)
set(material3_listcard_files
    internal/listcards/Material3ListCardParameters.qml
    internal/listcards/Material3ListCardDelegate.qml
    internal/listcards/Material3ListCardBackground.qml
    internal/listcards/Material3ListCardShadow.qml
    internal/listcards/Material3ListCardVariations.qml
    internal/listcards/Material3ListVariation.qml
    internal/listcards/Material3CardVariation.qml
)
set(material3_scrollbar_files
    internal/scrollbars/Material3ScrollBarDelegate.qml
    internal/scrollbars/Material3ScrollBarParameters.qml
    internal/scrollbars/Material3ScrollBarVisual.qml)
foreach(family_file IN LISTS
    material3_menu_files
    material3_field_files
    material3_combo_files
    material3_advanced_files
    material3_chip_files
    material3_checkbox_files
    material3_badge_files
    material3_radio_files
    material3_switch_files
    material3_navigation_files
    material3_app_navigation_files
    material3_slider_files
    material3_carousel_files
    material3_progress_files
    material3_picker_files
    material3_listcard_files
    material3_scrollbar_files
)
    get_filename_component(logical_name "${family_file}" NAME)
    set_source_files_properties("${family_file}" PROPERTIES QT_RESOURCE_ALIAS "${logical_name}")
    if(NOT logical_name STREQUAL "Material3NavigationContent.qml")
        set_source_files_properties("${family_file}" PROPERTIES QT_QML_INTERNAL_TYPE TRUE)
    endif()
endforeach()
set_source_files_properties(internal/pickers/Material3DateMath.js PROPERTIES
    QT_RESOURCE_ALIAS Material3DateMath.js QT_QML_SKIP_QMLDIR_ENTRY TRUE)
qt_add_qml_module(${module_target} SHARED
    URI Qavsi.Material3.Style
    PLUGIN_TARGET ${module_target}Plugin
    IMPORTS TARGET QavsiMaterial3Theme Qavsi.Icons
    IMPORT_PATH "${QavsiIcons_QML_IMPORT_DIR}"
    DEPENDENCIES QtQuick.Controls.impl QtQuick.Controls.Basic QtQuick.Layouts QtQuick.Shapes
    QML_FILES internal/pickers/Material3DateMath.js ${material3_scrollbar_files} Material3DatePicker.qml Material3DatePickerDialog.qml Material3DateTextField.qml Material3TimePicker.qml Material3ColorPicker.qml Material3ColorPickerDialog.qml Material3ColorPickerButton.qml Material3Carousel.qml Material3CarouselItem.qml Material3CarouselImageDelegate.qml ${material3_carousel_files} ${material3_picker_files} internal/feedback/Material3Ripple.qml
        internal/menus/Material3MenuItemBackground.qml
        internal/menus/Material3MenuEnterTransition.qml
        internal/menus/Material3MenuExitTransition.qml
        Material3Drawer.qml Material3AppNavigation.qml ${material3_app_navigation_files}
        Material3BusyIndicatorContent.qml Material3ProgressContent.qml ${material3_progress_files}
        Material3ButtonContent.qml Material3ListItemContent.qml ${material3_listcard_files} Material3ChipContent.qml Material3MenuItemContent.qml Material3Badge.qml ${material3_badge_files} ${material3_advanced_files} ${material3_menu_files} ${material3_field_files} ${material3_combo_files}
        Material3DialogEnterTransition.qml Material3DialogExitTransition.qml Material3DialogOverlay.qml
        Material3DialogDelegate.qml Material3DialogShadow.qml Material3DialogHeader.qml Material3DialogButtonBox.qml Material3ToolTip.qml Material3Snackbar.qml
        ${material3_switch_files} ${material3_navigation_files} ${material3_slider_files} ${material3_radio_files} ${material3_checkbox_files} ${material3_chip_files}
        internal/shadows/Material3Elevation.qml
        Material3Style.qml Material3ControlTheme.qml SmallButtonBackground.qml SmallButtonShadow.qml
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
    SOURCES internal/motion/material3spring.h internal/motion/material3spring.cpp
        internal/actions/advanced/material3buttongroup.h internal/actions/advanced/material3buttongroup.cpp
        internal/pickers/material3colorinput.h internal/pickers/material3colorinput.cpp
        internal/carousel/qcm_carousel_view.hpp
        internal/carousel/qcm_carousel_view.cpp
        internal/carousel/qcm_carousel_attached.hpp
        internal/carousel/qcm_carousel_attached.cpp
        internal/carousel/qcm_carousel_strategy.hpp
        internal/carousel/qcm_carousel_strategies.cpp
        internal/carousel/qcm_carousel_keylines.hpp
        internal/carousel/qcm_carousel_keylines.cpp
        internal/carousel/qcm_carousel_scroll_strategy.hpp
        internal/carousel/qcm_carousel_scroll_strategy.cpp
        internal/carousel/carousel_native.h
        internal/progress/materialloadingpaint.h internal/progress/materialloadingpaint.cpp
        internal/progress/qcmloading/rounded_polygon.hpp internal/progress/qcmloading/rounded_polygon.cpp
        internal/progress/qcmloading/morph.cpp
        internal/progress/qcmloading/loadingshapes.h internal/progress/qcmloading/loadingshapes.cpp
        internal/progress/materialprogresspaint.h internal/progress/materialprogresspaint.cpp
        internal/progress/qcmprogressgeometry.h internal/progress/qcmprogressgeometry.cpp
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
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/motion"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/actions/advanced"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/carousel"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/pickers"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/shadows"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/progress"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/sliders"
    "${CMAKE_CURRENT_SOURCE_DIR}/internal/radiobuttons")
target_link_libraries(${module_target} PUBLIC QavsiMaterial3::Theme QavsiIcons::Core PRIVATE Qt6::Quick Qt6::LabsStyleKit)
add_library(QavsiMaterial3::Style ALIAS ${module_target})
include("${PROJECT_SOURCE_DIR}/cmake/InstallQmlModule.cmake")
