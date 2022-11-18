set(TOOLCHAIN_OS AmigaOS)
set(TOOLCHAIN_SYSTEM_INFO_FILE Platform/${TOOLCHAIN_OS})

include(${TOOLCHAIN_SYSTEM_INFO_FILE} OPTIONAL RESULT_VARIABLE _TOOLCHAIN_SYSTEM_INFO_FILE)

if(NOT _TOOLCHAIN_SYSTEM_INFO_FILE)
	set(CMAKE_SYSTEM_NAME Generic)
else()
	set(CMAKE_SYSTEM_NAME ${TOOLCHAIN_OS})
endif()

set(CMAKE_SYSTEM_PROCESSOR m68k)

string(TOLOWER ${CMAKE_SYSTEM_NAME} SYS_NAME)
string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} SYS_CPU)
set(TOOLCHAIN_PREFIX_DEFAULT "${SYS_CPU}-${SYS_NAME}")
set(TOOLCHAIN_PREFIX ${TOOLCHAIN_PREFIX_DEFAULT} CACHE STRING "Compiler prefix, default: ${TOOLCHAIN_PREFIX_DEFAULT}")
set(TOOLCHAIN_PREFIX_DASHED "${TOOLCHAIN_PREFIX}-")

set(AMIGA 1)
set(AMIGAOS3 1)
set(M68K_COMPILER "Bartman")
add_compile_definitions(BARTMAN_GCC)

# CPU
set(M68K_CPU_TYPES "68000" "68010" "68020" "68040" "68060" "68080")
set(M68K_CPU "68000" CACHE STRING "Target CPU model")
set_property(CACHE M68K_CPU PROPERTY STRINGS ${M68K_CPU_TYPES})

# Extra flags
set(TOOLCHAIN_CFLAGS "${M68K_CFLAGS}" CACHE STRING "CFLAGS")
set(TOOLCHAIN_CXXFLAGS "${M68K_CXXFLAGS}" CACHE STRING "CXXFLAGS")
set(TOOLCHAIN_LDFLAGS "${M68K_LDFLAGS}" CACHE STRING "LDFLAGS")
set(TOOLCHAIN_COMMON "${M68K_COMMON}" CACHE STRING "Common FLAGS")

set(TOOLCHAIN_PATH_DEFAULT /opt/${TOOLCHAIN_PREFIX})
set(TOOLCHAIN_PATH ${TOOLCHAIN_PATH_DEFAULT} CACHE PATH "Path to compiler, default: ${TOOLCHAIN_PATH_DEFAULT}")
file(TO_CMAKE_PATH "${TOOLCHAIN_PATH}" TOOLCHAIN_PATH)

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PATH})
set(CMAKE_SYSROOT ${TOOLCHAIN_PATH})

set(CMAKE_PREFIX_PATH ${TOOLCHAIN_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_PREFIX "${CMAKE_PREFIX_PATH}/usr" CACHE PATH "Use PREFIX path" FORCE)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}g++)
set(CMAKE_CPP_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}cpp)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}gcc)
set(ELF2HUNK ${TOOLCHAIN_PATH}/../elf2hunk)
set(OBJDUMP ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}objdump)

if(WIN32)
	set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER}.exe)
	set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER}.exe)
	set(CMAKE_CPP_COMPILER ${CMAKE_CPP_COMPILER}.exe)
	set(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER}.exe)
	set(ELF2HUNK ${ELF2HUNK}.exe)
	set(OBJDUMP ${OBJDUMP}.exe)
endif()

# Compiler flags
set(FLAGS_COMMON "${TOOLCHAIN_COMMON} -MP -MMD -m${M68K_CPU} -fomit-frame-pointer -nostdlib -Wno-unused-function -Wno-volatile-register-var -fno-tree-loop-distribution -flto -fwhole-program")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAGS_COMMON} ${TOOLCHAIN_CFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_COMMON} -fno-exceptions ${TOOLCHAIN_CXXFLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Wa,-g,--register-prefix-optional")
set(BUILD_SHARED_LIBS OFF)
unset(FLAGS_COMMON)

# Linker configuration
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--emit-relocs,-Ttext=0")
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")
