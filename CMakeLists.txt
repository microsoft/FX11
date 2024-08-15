# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

cmake_minimum_required (VERSION 3.20)

set(FX_VERSION 11.30)

project (Effects11
  VERSION ${FX_VERSION}
  DESCRIPTION "Effects for DirectX 11"
  HOMEPAGE_URL "http://go.microsoft.com/fwlink/?LinkId=271568"
  LANGUAGES CXX)

# https://devblogs.microsoft.com/cppblog/spectre-mitigations-in-msvc/
option(ENABLE_SPECTRE_MITIGATION "Build using /Qspectre for MSVC" OFF)

option(DISABLE_MSVC_ITERATOR_DEBUGGING "Disable iterator debugging in Debug configurations with the MSVC CRT" OFF)

option(ENABLE_CODE_ANALYSIS "Use Static Code Analysis on build" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

include(GNUInstallDirs)

#--- Library
set(LIBRARY_HEADERS
    Effect.h
    EffectLoad.h
    IUnknownImp.h
    EffectVariable.inl
    Binary/EffectBinaryFormat.h
    Binary/EffectStateBase11.h
    Binary/EffectStates11.h
    Binary/SOParser.h
    inc/d3dx11effect.h
    inc/d3dxGlobal.h
)

set(LIBRARY_SOURCES
    d3dxGlobal.cpp
    EffectAPI.cpp
    EffectLoad.cpp
    EffectNonRuntime.cpp
    EffectReflection.cpp
    EffectRuntime.cpp
)

add_library(${PROJECT_NAME} STATIC ${LIBRARY_SOURCES} ${LIBRARY_HEADERS})

target_precompile_headers(${PROJECT_NAME} PRIVATE pchfx.h)

target_include_directories(${PROJECT_NAME} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
  PRIVATE Binary/)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)

#--- Package
include(CMakePackageConfigHelpers)

string(TOLOWER ${PROJECT_NAME} PACKAGE_NAME)

write_basic_package_version_file(
  ${PACKAGE_NAME}-config-version.cmake
  VERSION ${FX_VERSION}
  COMPATIBILITY AnyNewerVersion)

install(TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}-targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/build/${PROJECT_NAME}-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME})

install(EXPORT ${PROJECT_NAME}-targets
  FILE ${PROJECT_NAME}-targets.cmake
  NAMESPACE Microsoft::
  DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME})

install(FILES inc/d3dx11effect.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME})

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
  DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PACKAGE_NAME})

if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4 /EHsc /GR-)
endif()

include(build/CompilerAndLinker.cmake)

target_compile_definitions(${PROJECT_NAME} PRIVATE ${COMPILER_DEFINES})
target_compile_options(${PROJECT_NAME} PRIVATE ${COMPILER_SWITCHES})
target_link_options(${PROJECT_NAME} PRIVATE ${LINKER_SWITCHES})

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|IntelLLVM")
    set(WarningsLib "-Wno-microsoft-exception-spec" "-Wno-microsoft-goto" "-Wno-switch"
        "-Wno-unused-value" "-Wno-unused-function" "-Wno-dynamic-class-memaccess"
        "-Wno-tautological-constant-out-of-range-compare" "-Wno-invalid-offsetof")
    target_compile_options(${PROJECT_NAME} PRIVATE ${WarningsLib})
elseif( CMAKE_CXX_COMPILER_ID MATCHES "MSVC" )
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.34)
      target_compile_options(${PROJECT_NAME} PRIVATE /wd5262)
    endif()

    if(ENABLE_CODE_ANALYSIS)
      target_compile_options(${PROJECT_NAME} PRIVATE /analyze /WX)
    endif()

    if(ENABLE_SPECTRE_MITIGATION
       AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.13))
        message(STATUS "Building Spectre-mitigated libraries")
        target_compile_options(${PROJECT_NAME} PRIVATE "/Qspectre")
    endif()
endif()

if(WIN32)
    if(WINDOWS_STORE OR (${DIRECTX_ARCH} MATCHES "^arm64"))
        message(STATUS "Building for Windows 10/Windows 11.")
        set(WINVER 0x0A00)
    elseif(${DIRECTX_ARCH} MATCHES "^arm")
        message(STATUS "Building for Windows 8.")
        set(WINVER 0x0602)
    else()
        message(STATUS "Building for Windows 7.")
        set(WINVER 0x0601)
    endif()

    target_compile_definitions(${PROJECT_NAME} PRIVATE _WIN32_WINNT=${WINVER})

    if(DISABLE_MSVC_ITERATOR_DEBUGGING)
      target_compile_definitions(${PROJECT_NAME} PRIVATE _ITERATOR_DEBUG_LEVEL=0)
    endif()
endif()
