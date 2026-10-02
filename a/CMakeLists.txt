
add_executable(a main.asm
    lib.asm)

target_include_directories(a PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# -no-pie フラグの設定（GCCリンカを使用する場合）
target_link_options(a PRIVATE -nostdlib -no-pie -e _start)
