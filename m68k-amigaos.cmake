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
set(M68K_COMPILER "Bebbo")

# CPU
set(M68K_CPU_TYPES "68000" "68010" "68020" "68040" "68060" "68080")
set(M68K_CPU "68000" CACHE STRING "Target CPU model")
set_property(CACHE M68K_CPU PROPERTY STRINGS ${M68K_CPU_TYPES})

# FPU
set(M68K_FPU_TYPES "soft" "hard")
set(M68K_FPU "soft" CACHE STRING "FPU type")
set_property(CACHE M68K_FPU PROPERTY STRINGS ${M68K_FPU_TYPES})

# CRT
set(M68K_CRT_TYPES "nix20" "nix13" "clib2" "ixemul" "newlib" "none")
if(NOT DEFINED CACHE{M68K_CRT})
	message(NOTICE "M68K_CRT not set, defaulting C Runtime to libnix")
endif()
set(M68K_CRT "nix20" CACHE STRING "Target std lib")
set_property(CACHE M68K_CRT PROPERTY STRINGS ${M68K_CRT_TYPES})
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES M68K_CRT)
if(NOT M68K_CRT IN_LIST M68K_CRT_TYPES)
	message(WARNING "Provided M68K_CRT variable (${M68K_CRT}) not found in M68K_CRT_TYPES (${M68K_CRT_TYPES}). Linker may not do what you intend.")
endif()
if(M68K_CRT STREQUAL "newlib")
	set(MCRT_FLAG "")
elseif(M68K_CRT STREQUAL "none")
	set(MCRT_FLAG "-nostdlib")
else()
	set(MCRT_FLAG "-mcrt=${M68K_CRT}")
endif()

# Extra flags
set(TOOLCHAIN_CFLAGS "${M68K_CFLAGS}" CACHE STRING "CFLAGS")
set(TOOLCHAIN_CXXFLAGS "${M68K_CXXFLAGS}" CACHE STRING "CXXFLAGS")
set(TOOLCHAIN_LDFLAGS "${M68K_LDFLAGS}" CACHE STRING "LDFLAGS")
set(TOOLCHAIN_COMMON "${M68K_COMMON}" CACHE STRING "Common FLAGS")

set(TOOLCHAIN_PATH_DEFAULT /opt/${TOOLCHAIN_PREFIX})
set(TOOLCHAIN_PATH ${TOOLCHAIN_PATH_DEFAULT} CACHE PATH "Path to compiler, default: ${TOOLCHAIN_PATH_DEFAULT}")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PATH})
set(CMAKE_SYSROOT ${TOOLCHAIN_PATH})

set(CMAKE_PREFIX_PATH ${TOOLCHAIN_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_INSTALL_PREFIX "${CMAKE_PREFIX_PATH}/usr" CACHE PATH "Use PREFIX path")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")

set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}g++)
set(CMAKE_CPP_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}cpp)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX_DASHED}gcc -c)

if(WIN32)
	set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER}.exe)
	set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER}.exe)
	set(CMAKE_CPP_COMPILER ${CMAKE_CPP_COMPILER}.exe)
	set(CMAKE_ASM_COMPILER ${CMAKE_ASM_COMPILER}.exe)
endif()

# Special purpose libnix object files - variables for easier linking
set(LIBNIX_SWAPSTACK_O ${TOOLCHAIN_PATH}/m68k-amigaos/libnix/lib/swapstack.o)

# Compiler flags
set(FLAGS_COMMON "${TOOLCHAIN_COMMON} -m${M68K_CPU} -m${M68K_FPU}-float -fomit-frame-pointer ${MCRT_FLAG}")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAGS_COMMON} ${TOOLCHAIN_CFLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_COMMON} ${TOOLCHAIN_CXXFLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -m${M68K_CPU} -I${TOOLCHAIN_PATH}/m68k-amigaos/sys-include")
set(BUILD_SHARED_LIBS OFF)
unset(FLAGS_COMMON)

# Linker configuration
set(CMAKE_EXE_LINKER_FLAGS "${TOOLCHAIN_LDFLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} -ldebug")
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")
