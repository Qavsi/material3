cmake_minimum_required(VERSION 3.30)
project(QavsiMaterial3 VERSION 0.1.0 LANGUAGES CXX)

find_package(Qt6 6.12 REQUIRED COMPONENTS Quick LabsStyleKit ShaderTools)
qt_standard_project_setup(REQUIRES 6.12)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_subdirectory(src/Qavsi/Material3/Theme)
add_subdirectory(src/Qavsi/Material3/Style)

set(QavsiMaterial3_QML_IMPORT_DIR "${CMAKE_CURRENT_BINARY_DIR}/src")
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

install(FILES LICENSE THIRD_PARTY_NOTICES.md
    DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/QavsiMaterial3")

option(QAVSI_MATERIAL3_BUILD_EXAMPLE "Build the Small Button consumer" ${PROJECT_IS_TOP_LEVEL})
if(QAVSI_MATERIAL3_BUILD_EXAMPLE)
    enable_testing()
    add_subdirectory(examples/small-button)
endif()
