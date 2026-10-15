
find_package(Threads REQUIRED)

add_executable(thread main.c lib.asm
    thr.c)

target_include_directories(thread PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# -no-pie フラグの設定（GCCリンカを使用する場合）
target_link_options(thread PRIVATE -pie)
#target_link_options(thread PRIVATE -no-pie)

target_link_libraries(thread PRIVATE Threads::Threads)

message(STATUS "THREAD_LIBS=${CMAKE_THREAD_LIBS_INIT}")
message(STATUS "PTHREAD_ARG=${THREADS_PREFER_PTHREAD_FLAG}")
