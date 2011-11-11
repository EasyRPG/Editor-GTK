cmake_minimum_required(VERSION 2.6)

project("editor_vala" CXX C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake_module)
find_package(Vala REQUIRED)
include(${VALA_USE_FILE})

find_package(GTK3 REQUIRED)
include_directories(${GTK3_INCLUDE_DIRS})

find_library(GDK3_LIBRARY gdk-3)
if(GDK3_LIBRARY)
  message(STATUS "gdk-3.0 found")
else()
  message(FATAL_ERROR "gdk-3.0 not found")
endif()

file(GLOB VALA_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.vala)
file(GLOB VALA_APIS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.vapi)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
vala_precompile(VALA_C
  SOURCES ${VALA_SRCS}
  PACKAGES gtk+-3.0 gio-2.0 posix libxml-2.0 gdk-3.0
  OPTIONS --thread
  CUSTOM_VAPIS ${VALA_APIS}
  GENERATE_VAPI editor_vala
  GENERATE_HEADER editor_vala)

add_executable(${PROJECT_NAME} ${VALA_C})
target_link_libraries(${PROJECT_NAME} ${GTK3_LIBRARIES} ${GDK3_LIBRARY})
