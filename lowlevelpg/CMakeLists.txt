
add_executable(lowlevelpg main.asm lib.asm)

target_include_directories(lowlevelpg PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# -no-pie フラグの設定（GCCリンカを使用する場合）
#target_link_options(lowlevelpg PRIVATE -nostdlib -pie -e _start --dynamic-linker=/lib64/ld-linux-x86-64.so.2)
target_link_options(lowlevelpg PRIVATE -nostdlib -no-pie -e _start)
