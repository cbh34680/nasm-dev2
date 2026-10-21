
add_executable(str main.c str.asm)

target_include_directories(str PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

#set_property(TARGET str PROPERTY POSITION_INDEPENDENT_CODE OFF)

# -no-pie フラグの設定（GCCリンカを使用する場合）
#target_link_options(str PRIVATE -pie)
#target_link_options(str PRIVATE -no-pie)

#set_source_files_properties(main.c PROPERTIES COMPILE_OPTIONS "-fno-pie")
target_link_options(str PRIVATE -no-pie)
