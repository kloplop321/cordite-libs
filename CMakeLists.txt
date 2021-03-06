cmake_minimum_required(VERSION 2.8)
OPTION(USE_CXX_11 "Use C++11" ON)
OPTION(FORCE_LIBS_SHARED "Force Shared Libs" OFF)
OPTION(FORCE_LIBS_STATIC "Force Static Libs" OFF)

if(FORCE_LIBS_STATIC AND FORCE_LIBS_SHARED)
	message(FATAL_ERROR "You cannot have both shared and static forced")
endif()
if(FORCE_LIBS_STATIC)
	set(LIB_TYPE STATIC)
endif()
if(FORCE_LIBS_SHARED)
	set(LIB_TYPE SHARED)
endif()
SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

if(USE_CXX_11)
include(${CMAKE_MODULE_PATH}/cxx11/CheckCXX11Features.cmake)
if (APPLE)
	set(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "com.apple.compilers.llvm.clang.1_0")
	set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
	set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
	
	if (CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_GNUCC)
		message(FATAL_ERROR "You need to use clang on Apple!
		use CC=clang CXX=clang++ cmake path/to/project")
	endif()
	
	SET(CMAKE_CXX_FLAGS "-std=c++11 -stdlib=libc++")
endif ()
if (CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_GNUCC)
  set ( CMAKE_CXX_FLAGS "-std=c++0x")
  #set ( CMAKE_CXX_FLAGS_DEBUG "")
  #set ( CMAKE_CXX_FLAGS_RELEASE  "" )
endif ()
endif(USE_CXX_11)

add_subdirectory(google)
add_subdirectory(bson)
#add_subdirectory(poco)
add_subdirectory(zmq)
add_subdirectory(yaml-cpp)