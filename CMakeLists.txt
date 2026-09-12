cmake_minimum_required(VERSION 3.10)
project(libco C CXX ASM)

# Set lib version
set(LIBCO_VERSION 0.5)

set(CMAKE_MACOSX_RPATH 0)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Library sources
file(GLOB LIBCO_SRCS
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/*.S)

add_library(colib_static STATIC ${LIBCO_SRCS})
add_library(colib_shared SHARED ${LIBCO_SRCS})

set_target_properties(colib_static PROPERTIES OUTPUT_NAME colib)
set_target_properties(colib_shared PROPERTIES OUTPUT_NAME colib)
set_target_properties(colib_shared PROPERTIES
        VERSION ${LIBCO_VERSION} SOVERSION ${LIBCO_VERSION})

target_include_directories(colib_static PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_include_directories(colib_shared PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)

find_package(Threads REQUIRED)
target_link_libraries(colib_shared PUBLIC Threads::Threads ${CMAKE_DL_LIBS})

# Examples
file(GLOB EXAMPLE_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/example/*.cpp)
foreach(src ${EXAMPLE_SRCS})
    get_filename_component(name ${src} NAME_WE)
    add_executable(${name} ${src})
    target_link_libraries(${name} colib_static Threads::Threads ${CMAKE_DL_LIBS})
endforeach()

# Benchmarks
file(GLOB BENCH_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/bench/*.cpp)
foreach(src ${BENCH_SRCS})
    get_filename_component(name ${src} NAME_WE)
    add_executable(${name} ${src})
    target_link_libraries(${name} colib_static Threads::Threads ${CMAKE_DL_LIBS})
endforeach()
