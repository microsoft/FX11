cmake_minimum_required(VERSION 3.2.2)
project(Effects11)

# Variables
# -----------------------------------------------------------------------------
set(ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})
set(SOURCE_DIR "${ROOT_DIR}")

file(GLOB SOURCE_FILES "${SOURCE_DIR}/*.cpp"
					   "${SOURCE_DIR}/*.h"
					   "${SOURCE_DIR}/*.inl")
add_library(Effects11 STATIC ${SOURCE_FILES})
target_include_directories(Effects11 
	PRIVATE "${ROOT_DIR}/Binary"
	PUBLIC "${ROOT_DIR}/inc")