cmake_minimum_required(VERSION 3.30)
project(QavsiMaterial3 VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.12 REQUIRED COMPONENTS Quick LabsStyleKit ShaderTools)
qt_standard_project_setup(REQUIRES 6.12)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
if(NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/src")
endif()

if(NOT TARGET QavsiIcons::Core)
    if(QAVSI_ICONS_SOURCE)
        set(QAVSI_ICONS_BUILD_TESTS OFF)
        add_subdirectory("${QAVSI_ICONS_SOURCE}" qavsi-icons)
    else()
        find_package(QavsiIcons 0.1 CONFIG REQUIRED COMPONENTS Core)
    endif()
endif()

add_subdirectory(third_party/material-color-utilities)
add_subdirectory(src/Qavsi/Material3/Theme)
add_subdirectory(src/Qavsi/Material3/Style)

set(QavsiMaterial3_QML_IMPORT_DIR "${QT_QML_OUTPUT_DIRECTORY}")
if(NOT PROJECT_IS_TOP_LEVEL)
    set(QavsiMaterial3_QML_IMPORT_DIR "${QavsiMaterial3_QML_IMPORT_DIR}" PARENT_SCOPE)
endif()
set(qml_install_dir "${CMAKE_INSTALL_LIBDIR}/qml")
configure_package_config_file(cmake/QavsiMaterial3Config.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/QavsiMaterial3Config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/QavsiMaterial3"
    PATH_VARS qml_install_dir)
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/QavsiMaterial3ConfigVersion.cmake"
    VERSION "${PROJECT_VERSION}" COMPATIBILITY SameMinorVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/QavsiMaterial3Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/QavsiMaterial3ConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/QavsiMaterial3")
install(EXPORT QavsiMaterial3Targets NAMESPACE QavsiMaterial3::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/QavsiMaterial3")

install(FILES third_party/material-color-utilities/LICENSE
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/QavsiMaterial3/material-color-utilities")
install(DIRECTORY third_party/ripple-reference/
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/QavsiMaterial3/ripple-reference")
install(FILES LICENSE THIRD_PARTY_NOTICES.md
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/QavsiMaterial3")

option(QAVSI_MATERIAL3_BUILD_EXAMPLE "Build the Small Button consumer" ${PROJECT_IS_TOP_LEVEL})
if(QAVSI_MATERIAL3_BUILD_EXAMPLE)
    enable_testing()
    add_subdirectory(examples/small-button)
endif()

option(QAVSI_MATERIAL3_BUILD_COMPARISON "Build the QmlMaterial button comparison" ${QAVSI_MATERIAL3_BUILD_EXAMPLE})
if(QAVSI_MATERIAL3_BUILD_COMPARISON)
    enable_testing()
    add_subdirectory(examples/qmlmaterial-comparison)
endif()

option(QAVSI_MATERIAL3_BUILD_TESTS "Build focused kit contract tests" ${QAVSI_MATERIAL3_BUILD_EXAMPLE})
if(QAVSI_MATERIAL3_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests/material-colors)
endif()
