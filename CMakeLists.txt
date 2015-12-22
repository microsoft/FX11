cmake_minimum_required(VERSION 3.2.2)
project(FX11)


# Variables
set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})
set(SOURCE_DIR "${ROOT_DIR}")

set(PUBLIC_HEADER_FILES  
  inc/d3dx11effect.h
  inc/d3dxGlobal.h)

# Append 'D' to debug variants of the .lib by default
if(NOT DEFINED CMAKE_DEBUG_POSTFIX)
  set(CMAKE_DEBUG_POSTFIX "D")
endif()

add_library(${PROJECT_NAME} STATIC
  ${PUBLIC_HEADER_FILES}
  Effect.h
  EffectLoad.h
  EffectVariable.inl
  IUnknownImp.h
  pchfx.h
  d3dxGlobal.cpp
  EffectAPI.cpp
  EffectLoad.cpp
  EffectNonRuntime.cpp
  EffectReflection.cpp
  EffectRuntime.cpp)
							 
target_include_directories(${PROJECT_NAME} 
	PRIVATE "${ROOT_DIR}/Binary"
	PUBLIC "${ROOT_DIR}/inc")

# Setup install target
install(TARGETS ${PROJECT_NAME}
  DESTINATION lib)

install(FILES ${PUBLIC_HEADER_FILES}
  DESTINATION include)