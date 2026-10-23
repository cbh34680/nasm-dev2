
add_executable(a start.asm main.c)
target_include_directories(a PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# nasm の場合
# リンカが実行されない
#set_target_properties(a PROPERTIES LINKER_LANGUAGE ASM)
#target_link_options(a PRIVATE -nostdlib -pie -e _start --dynamic-linker=/lib64/ld-linux-x86-64.so.2)

# cc の場合
target_link_options(a PRIVATE -nostdlib -pie -e _start -Wl,--dynamic-linker=/lib64/ld-linux-x86-64.so.2)

# 非PIE
#target_link_options(a PRIVATE -nostdlib -no-pie -e _start)

#
#set_property(TARGET a PROPERTY POSITION_INDEPENDENT_CODE OFF)
