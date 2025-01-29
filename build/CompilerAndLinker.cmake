# This modules provides variables with recommended Compiler and Linker switches
#
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set(COMPILER_DEFINES "")
set(COMPILER_SWITCHES "")
set(LINKER_SWITCHES "")

#--- Determines target architecture if not explicitly set
if(DEFINED VCPKG_TARGET_ARCHITECTURE)
    set(DIRECTX_ARCH ${VCPKG_TARGET_ARCHITECTURE})
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
    set(DIRECTX_ARCH x86)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
    set(DIRECTX_ARCH x64)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
    set(DIRECTX_ARCH arm)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
    set(DIRECTX_ARCH arm64)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64EC$")
    set(DIRECTX_ARCH arm64ec)
elseif(CMAKE_VS_PLATFORM_NAME_DEFAULT MATCHES "^[Ww][Ii][Nn]32$")
    set(DIRECTX_ARCH x86)
elseif(CMAKE_VS_PLATFORM_NAME_DEFAULT MATCHES "^[Xx]64$")
    set(DIRECTX_ARCH x64)
elseif(CMAKE_VS_PLATFORM_NAME_DEFAULT MATCHES "^[Aa][Rr][Mm]$")
    set(DIRECTX_ARCH arm)
elseif(CMAKE_VS_PLATFORM_NAME_DEFAULT MATCHES "^[Aa][Rr][Mm]64$")
    set(DIRECTX_ARCH arm64)
elseif(CMAKE_VS_PLATFORM_NAME_DEFAULT MATCHES "^[Aa][Rr][Mm]64EC$")
    set(DIRECTX_ARCH arm64ec)
elseif(NOT (DEFINED DIRECTX_ARCH))
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "[Aa][Rr][Mm]64|aarch64|arm64")
        set(DIRECTX_ARCH arm64)
    else()
        set(DIRECTX_ARCH x64)
    endif()
endif()

#--- Determines host architecture
if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "[Aa][Rr][Mm]64|aarch64|arm64")
    set(DIRECTX_HOST_ARCH arm64)
else()
    set(DIRECTX_HOST_ARCH x64)
endif()

#--- Build with Unicode Win32 APIs per "UTF-8 Everywhere"
if(WIN32)
  list(APPEND COMPILER_DEFINES _UNICODE UNICODE)
endif()

#--- General MSVC-like SDL options
if(MSVC)
    list(APPEND COMPILER_SWITCHES "$<$<NOT:$<CONFIG:DEBUG>>:/guard:cf>")
    list(APPEND LINKER_SWITCHES /DYNAMICBASE /NXCOMPAT /INCREMENTAL:NO)

    if(WINDOWS_STORE)
      list(APPEND COMPILER_SWITCHES /bigobj)
      list(APPEND LINKER_SWITCHES /APPCONTAINER /MANIFEST:NO)
    endif()

    if((${DIRECTX_ARCH} STREQUAL "x86")
       OR ((CMAKE_SIZEOF_VOID_P EQUAL 4) AND (NOT (${DIRECTX_ARCH} MATCHES "^arm"))))
      list(APPEND LINKER_SWITCHES /SAFESEH)
    endif()

    if((MSVC_VERSION GREATER_EQUAL 1928)
       AND (CMAKE_SIZEOF_VOID_P EQUAL 8)
       AND (NOT (TARGET OpenEXR::OpenEXR))
       AND ((NOT (CMAKE_CXX_COMPILER_ID MATCHES "Clang|IntelLLVM")) OR (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 13.0)))
          list(APPEND COMPILER_SWITCHES "$<$<NOT:$<CONFIG:DEBUG>>:/guard:ehcont>")
          list(APPEND LINKER_SWITCHES "$<$<NOT:$<CONFIG:DEBUG>>:/guard:ehcont>")
    endif()
else()
    list(APPEND COMPILER_DEFINES $<IF:$<CONFIG:DEBUG>,_DEBUG,NDEBUG>)
endif()

#--- Target architecture switches
if(NOT (${DIRECTX_ARCH} MATCHES "^arm"))
    if((${DIRECTX_ARCH} STREQUAL "x86") OR (CMAKE_SIZEOF_VOID_P EQUAL 4))
        set(ARCH_SSE2 $<$<CXX_COMPILER_ID:MSVC,Intel>:/arch:SSE2> $<$<NOT:$<CXX_COMPILER_ID:MSVC,Intel>>:-msse2>)
    else()
        set(ARCH_SSE2 $<$<NOT:$<CXX_COMPILER_ID:MSVC,Intel>>:-msse2>)
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        list(APPEND ARCH_SSE2 -mfpmath=sse)
    endif()

    list(APPEND COMPILER_SWITCHES ${ARCH_SSE2})
endif()

#--- Compiler-specific switches
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|IntelLLVM")
    if(MSVC AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0))
      list(APPEND COMPILER_SWITCHES /ZH:SHA_256)
    endif()

    if(WINDOWS_STORE)
      list(APPEND COMPILER_DEFINES _SILENCE_CLANG_COROUTINE_MESSAGE)
    endif()
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    list(APPEND COMPILER_SWITCHES /Zc:__cplusplus /Zc:inline /fp:fast /Qdiag-disable:161)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    list(APPEND COMPILER_SWITCHES /sdl /Zc:inline /fp:fast)

    if(WINDOWS_STORE)
      list(APPEND COMPILER_SWITCHES /await)
    endif()

    if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
      message(STATUS "Building using Whole Program Optimization")
      list(APPEND COMPILER_SWITCHES $<$<NOT:$<CONFIG:Debug>>:/Gy /Gw>)
    endif()

    # /permissive- doesn't work on this legacy codebase.

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)
      list(APPEND COMPILER_SWITCHES /Zc:__cplusplus)
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.15)
      list(APPEND COMPILER_SWITCHES /JMC-)
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.24)
      list(APPEND COMPILER_SWITCHES /ZH:SHA_256)
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.26)
      list(APPEND COMPILER_SWITCHES /Zc:preprocessor /wd5104 /wd5105)
    endif()

    if((CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.27) AND (NOT (${DIRECTX_ARCH} MATCHES "^arm")))
      list(APPEND LINKER_SWITCHES /CETCOMPAT)
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.28)
      list(APPEND COMPILER_SWITCHES /Zc:lambda)
    endif()

    if((CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.29)
       AND (NOT VCPKG_TOOLCHAIN))
      list(APPEND COMPILER_SWITCHES /external:W4)
    endif()

    if(WINDOWS_STORE AND (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.32))
      list(APPEND COMPILER_SWITCHES "/wd5246")
    endif()

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.35)
      if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
        list(APPEND COMPILER_SWITCHES $<$<NOT:$<CONFIG:Debug>>:/Zc:checkGwOdr>)
      endif()

      list(APPEND COMPILER_SWITCHES $<$<VERSION_GREATER_EQUAL:${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION},10.0.22000>:/Zc:templateScope>)
    endif()
endif()

#--- Windows API Family
if(WINDOWS_STORE)
    list(APPEND COMPILER_DEFINES WINAPI_FAMILY=WINAPI_FAMILY_APP)
endif()
