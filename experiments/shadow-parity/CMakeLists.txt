cmake_minimum_required(VERSION 3.30)
project(QavsiShadowParity LANGUAGES CXX)
find_package(Qt6 6.12 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.12)
set(QCM_BUILD "/private/tmp/qavsi-shadow-benchmark/build" CACHE PATH "Existing QCM Release build")
set(M3_BUILD "/private/tmp/qavsi-migration-source" CACHE PATH "Existing current Material3 build")
set(M3_SOURCE "/Volumes/Mac/SCS/dev/Qavsi/material3" CACHE PATH "Current Material3 source")
add_library(qcm_reference SHARED IMPORTED)
set_target_properties(qcm_reference PROPERTIES IMPORTED_LOCATION "${QCM_BUILD}/qcm/libqml_material.dylib")
add_library(material3_current SHARED IMPORTED)
set_target_properties(material3_current PROPERTIES IMPORTED_LOCATION
    "${M3_BUILD}/src/Qavsi/Material3/Style/libQavsiMaterial3Style.dylib")
qt_add_executable(shadow-parity MACOSX_BUNDLE main.cpp)
target_compile_features(shadow-parity PRIVATE cxx_std_20)
target_link_libraries(shadow-parity PRIVATE Qt6::Quick qcm_reference material3_current)
target_include_directories(shadow-parity PRIVATE "${M3_SOURCE}/src/Qavsi/Material3/Style/internal/shadows")
target_compile_definitions(shadow-parity PRIVATE PARITY_SOURCE="${CMAKE_CURRENT_SOURCE_DIR}"
    QCM_BUILD="${QCM_BUILD}" M3_BUILD="${M3_BUILD}")
set_target_properties(shadow-parity PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER dev.qavsi.shadowparity
    BUILD_RPATH "${QCM_BUILD}/qcm;${M3_BUILD}/src/Qavsi/Material3/Style;${M3_BUILD}/src/Qavsi/Material3/Theme;${M3_BUILD}/qavsi-icons/src/Qavsi/Icons")
