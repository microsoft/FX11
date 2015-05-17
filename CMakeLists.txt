cmake_minimum_required(VERSION 3.2.2)
project(Effects11)

# Variables
# -----------------------------------------------------------------------------
set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})
set(SOURCE_DIR "${ROOT_DIR}")

add_library(Effects11 STATIC "${SOURCE_DIR}/Effect.h"
							 "${SOURCE_DIR}/EffectLoad.h" 
							 "${SOURCE_DIR}/EffectVariable.inl"
							 "${SOURCE_DIR}/IUnknownImp.h"
							 "${SOURCE_DIR}/pchfx.h"
							 "${SOURCE_DIR}/d3dxGlobal.cpp"
							 "${SOURCE_DIR}/EffectAPI.cpp"
							 "${SOURCE_DIR}/EffectLoad.cpp"
							 "${SOURCE_DIR}/EffectNonRuntime.cpp"
							 "${SOURCE_DIR}/EffectReflection.cpp"
							 "${SOURCE_DIR}/EffectRuntime.cpp")
							 
target_include_directories(Effects11 
	PRIVATE "${ROOT_DIR}/Binary"
	PUBLIC "${ROOT_DIR}/inc")