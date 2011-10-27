cmake_minimum_required(VERSION 2.6)

project("editor_vala" CXX C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake_module)
find_package(Vala REQUIRED)
include(UseVala)

find_package(GTK3 REQUIRED)
include_directories(${GTK3_INCLUDE_DIRS})

# file(GLOB VALA_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.vala)
# file(GLOB VALA_APIS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.vapi)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)
vala_precompile(VALA_C
  SOURCES
    src/controller.vala
    src/controller_main.vala
    src/editor.vala
    src/model.vala
    src/model_layer.vala
    src/model_map.vala
    src/model_party.vala
    src/model_vehicle.vala
    src/view_database_dialog.vala
    src/view_main_window.vala
    src/xml_node.vala
    src/xml_parser.vala
  PACKAGES gtk+-3.0 gio-2.0 posix libxml-2.0
  OPTIONS --thread
  CUSTOM_VAPIS src/config.vapi
  GENERATE_VAPI editor_vala
  GENERATE_HEADER editor_vala)

add_executable(${PROJECT_NAME} ${VALA_C})
target_link_libraries(${PROJECT_NAME} ${GTK3_LIBRARIES})
