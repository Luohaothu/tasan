cmake_minimum_required(VERSION 3.20.0)
project(TASan VERSION 1.0.0 LANGUAGES C CXX ASM)
set(LLVM_SUBPROJECT_TITLE "TASan")

# Set position independent code for shared libraries
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# Add PIC flag for assembly files
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -fPIC")

# Set to standalone build mode
set(COMPILER_RT_STANDALONE_BUILD TRUE)

# Add local CMake module paths
list(INSERT CMAKE_MODULE_PATH 0
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules"
)

# Include localized basic configuration modules
include(base-config-ix)
include(CompilerRTUtils)
include(AddCompilerRT)
include(HandleCompilerRT)
include(SanitizerUtils)
include(CMakeDependentOption)

# Configure platform and architecture detection
include(config-ix)

# Set TASan-specific configuration options
option(TASAN_BUILD_RUNTIME "Build TASan runtime libraries" ON)
option(TASAN_BUILD_TESTS "Build TASan tests" ON)
option(TASAN_BUILD_EXAMPLES "Build TASan examples" ON)

# Configure supported architectures - limit to x86_64 for now to avoid compilation issues
set(TASAN_SUPPORTED_ARCH x86_64)
set(ASAN_SUPPORTED_ARCH ${TASAN_SUPPORTED_ARCH})

# Create top-level compiler-rt target
add_custom_target(compiler-rt)
add_custom_target(install-compiler-rt)
add_custom_target(install-compiler-rt-stripped)

# Add subdirectories
add_subdirectory(src)
add_subdirectory(include)

# Temporarily disable tests for initial build
# if(TASAN_BUILD_TESTS)
#   add_subdirectory(tests)
# endif()

if(TASAN_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

# TODO: Add package configuration later
# configure_package_config_file(
#   cmake/TASanConfig.cmake.in
#   ${CMAKE_CURRENT_BINARY_DIR}/TASanConfig.cmake
#   INSTALL_DESTINATION lib/cmake/TASan
# )
# 
# write_basic_package_version_file(
#   ${CMAKE_CURRENT_BINARY_DIR}/TASanConfigVersion.cmake
#   VERSION ${PROJECT_VERSION}
#   COMPATIBILITY AnyNewerVersion
# )
# 
# install(FILES
#   ${CMAKE_CURRENT_BINARY_DIR}/TASanConfig.cmake
#   ${CMAKE_CURRENT_BINARY_DIR}/TASanConfigVersion.cmake
#   DESTINATION lib/cmake/TASan
# )