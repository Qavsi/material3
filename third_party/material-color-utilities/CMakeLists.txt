add_library(QavsiMaterialColorUtilities OBJECT
    cpp/cam/cam.cc
    cpp/cam/hct.cc
    cpp/cam/hct_solver.cc
    cpp/cam/viewing_conditions.cc
    cpp/contrast/contrast.cc
    cpp/dislike/dislike.cc
    cpp/dynamiccolor/dynamic_color.cc
    cpp/dynamiccolor/dynamic_scheme.cc
    cpp/dynamiccolor/material_dynamic_colors.cc
    cpp/palettes/tones.cc
    cpp/scheme/scheme_rainbow.cc
    cpp/scheme/scheme_monochrome.cc
    cpp/scheme/scheme_vibrant.cc
    cpp/scheme/scheme_content.cc
    cpp/scheme/scheme_fidelity.cc
    cpp/scheme/scheme_expressive.cc
    cpp/scheme/scheme_fruit_salad.cc
    cpp/temperature/temperature_cache.cc
    cpp/quantize/lab.cc
    cpp/scheme/scheme_neutral.cc
    cpp/scheme/scheme_tonal_spot.cc
    cpp/utils/utils.cc
)
target_compile_features(QavsiMaterialColorUtilities PRIVATE cxx_std_20)
target_include_directories(QavsiMaterialColorUtilities PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
set_target_properties(QavsiMaterialColorUtilities PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON)
