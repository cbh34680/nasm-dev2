
add_executable(a main.asm)

target_include_directories(a PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

#set_property(TARGET a PROPERTY POSITION_INDEPENDENT_CODE OFF)

# -no-pie フラグの設定（GCCリンカを使用する場合）
#target_link_options(a PRIVATE -pie)
#target_link_options(a PRIVATE -no-pie)

#set_source_files_properties(main.c PROPERTIES COMPILE_OPTIONS "-fno-pie")
target_link_options(a PRIVATE -no-pie)
