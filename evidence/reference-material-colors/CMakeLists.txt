cmake_minimum_required(VERSION 3.30)
project(QcmColorReference LANGUAGES CXX)
find_package(Qt6 6.12 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.12)
qt_add_executable(qcm-color-reference main.cpp)
target_compile_features(qcm-color-reference PRIVATE cxx_std_20)
target_include_directories(qcm-color-reference PRIVATE
    /Volumes/Mac/SCS/dev/Qavsi/references/QmlMaterial/include
    /Volumes/Mac/SCS/dev/Qavsi/references/QmlMaterial/third_party/material-color)
target_link_libraries(qcm-color-reference PRIVATE Qt6::Quick
    /Volumes/Mac/SCS/dev/Qavsi/references/QmlMaterial/.qavsi-build/libqml_material.dylib)
