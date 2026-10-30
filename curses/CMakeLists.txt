add_executable(curses main.c part1to7.c)
target_include_directories(curses PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_definitions(curses PRIVATE _XOPEN_SOURCE_EXTENDED=1)

find_package(Curses REQUIRED)
target_link_libraries(curses PRIVATE ${CURSES_LIBRARIES})
target_include_directories(curses PRIVATE ${CURSES_INCLUDE_DIRS})
