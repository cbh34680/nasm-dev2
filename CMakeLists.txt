# CMakeLists.txt
cmake_minimum_required(VERSION 3.30)
project(dev2 C CXX ASM_NASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT "elf64")
else()
    set(CMAKE_ASM_NASM_OBJECT_FORMAT "elf32")
endif()

set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -g -F dwarf")

add_subdirectory(lowlevelpg)
