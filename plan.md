# ASan库独立模块重构方案（本地化CMake基础设施）

## 项目概述

本项目旨在将AddressSanitizer (ASan)库从LLVM项目中抽离为独立的模块，**将必要的LLVM CMake基础设施文件复制到本地目录**，确保跨平台兼容性，使其能够独立构建和使用，而不依赖于任何外部LLVM项目。

## 关键设计原则

1. **本地化基础设施**: 将必要的CMake文件复制到本地，避免外部依赖
2. **保持兼容性**: 维持与原有LLVM构建系统的API兼容性
3. **跨平台支持**: 继承LLVM的跨平台构建能力
4. **最小化修改**: 尽可能保持原有代码结构和构建逻辑

## 目录结构设计

```
tasan/
├── CMakeLists.txt                 # 主CMake配置文件
├── cmake/                         # 本地化的CMake基础设施
│   ├── base-config-ix.cmake       # 基础配置（从LLVM复制）
│   ├── config-ix.cmake            # 平台和架构检测配置（从LLVM复制）
│   ├── Modules/                   # CMake模块（从LLVM复制）
│   │   ├── AddCompilerRT.cmake    # 添加编译器运行时函数
│   │   ├── CompilerRTUtils.cmake  # 编译器运行时工具函数
│   │   ├── HandleCompilerRT.cmake # 处理编译器运行时配置
│   │   ├── CompilerRTCompile.cmake
│   │   ├── CompilerRTLink.cmake
│   │   ├── SanitizerUtils.cmake
│   │   ├── CompilerRTDarwinUtils.cmake
│   │   ├── CompilerRTAIXUtils.cmake
│   │   ├── BuiltinTests.cmake
│   │   ├── AllSupportedArchDefs.cmake
│   │   ├── CheckSectionExists.cmake
│   │   └── UseLibtool.cmake
│   └── caches/                    # 构建缓存配置（从LLVM复制）
│       ├── Apple.cmake
│       ├── GPU.cmake
│       ├── hexagon-linux-builtins.cmake
│       └── hexagon-linux-clangrt.cmake
├── src/
│   ├── asan/                     # ASan核心源文件（从compiler-rt/lib/asan复制）
│   │   ├── asan_allocator.cpp
│   │   ├── asan_activation.cpp
│   │   ├── asan_debugging.cpp
│   │   ├── asan_descriptions.cpp
│   │   ├── asan_errors.cpp
│   │   ├── asan_fake_stack.cpp
│   │   ├── asan_flags.cpp
│   │   ├── asan_fuchsia.cpp
│   │   ├── asan_globals.cpp
│   │   ├── asan_globals_win.cpp
│   │   ├── asan_interceptors.cpp
│   │   ├── asan_interceptors_memintrinsics.cpp
│   │   ├── asan_linux.cpp
│   │   ├── asan_mac.cpp
│   │   ├── asan_malloc_linux.cpp
│   │   ├── asan_malloc_mac.cpp
│   │   ├── asan_malloc_win.cpp
│   │   ├── asan_memory_profile.cpp
│   │   ├── asan_poisoning.cpp
│   │   ├── asan_posix.cpp
│   │   ├── asan_premap_shadow.cpp
│   │   ├── asan_report.cpp
│   │   ├── asan_rtl.cpp
│   │   ├── asan_shadow_setup.cpp
│   │   ├── asan_stack.cpp
│   │   ├── asan_stats.cpp
│   │   ├── asan_suppressions.cpp
│   │   ├── asan_thread.cpp
│   │   ├── asan_win.cpp
│   │   ├── asan_new_delete.cpp
│   │   ├── asan_rtl_static.cpp
│   │   ├── asan_preinit.cpp
│   │   ├── CMakeLists.txt
│   │   └── *.h, *.inc, *.txt, *.S
│   ├── sanitizer_common/          # 通用sanitizer组件（从compiler-rt/lib/sanitizer_common复制）
│   │   ├── *.cpp, *.h, *.inc
│   │   └── CMakeLists.txt
│   └── interception/             # 拦截器模块（从compiler-rt/lib/interception复制）
│       ├── *.cpp, *.h
│       └── CMakeLists.txt
├── include/
│   └── sanitizer/                # 公共头文件（从compiler-rt/include/sanitizer复制）
│       ├── asan_interface.h
│       ├── common_interface_defs.h
│       └── sanitizer_internal_defs.h
├── tests/                          # 测试文件（从compiler-rt/test/asan复制）
│   ├── TestCases/                  # 测试用例（523个测试文件）
│   │   ├── Linux/                  # Linux特定测试
│   │   ├── Darwin/                 # macOS特定测试
│   │   ├── Android/                # Android特定测试
│   │   ├── Windows/                # Windows特定测试
│   │   ├── Fuchsia/                # Fuchsia特定测试
│   │   ├── Posix/                  # POSIX特定测试
│   │   ├── aio_overflow.cpp        # 异步IO溢出测试
│   │   ├── alloc_dealloc_mismatch.cpp # 分配释放不匹配测试
│   │   ├── alloca_overflow.cpp     # 栈溢出测试
│   │   ├── array_bounds.cpp        # 数组越界测试
│   │   ├── asan_and_llvm_coverage_test.cpp # ASan与LLVM覆盖率测试
│   │   ├── asan_options.cpp        # ASan选项测试
│   │   ├── atoi_strict.c           # 严格atoi测试
│   │   ├── big_malloc_delete.cpp   # 大内存分配删除测试
│   │   ├── bitfield.cpp            # 位域测试
│   │   ├── calloc_overflow.cpp     # calloc溢出测试
│   │   ├── common.h                # 测试通用头文件
│   │   ├── custom_malloc_test.cpp  # 自定义分配器测试
│   │   ├── double_free.cpp         # 双重释放测试
│   │   ├── global_overflow.cpp     # 全局变量溢出测试
│   │   ├── heap_overflow.cpp       # 堆溢出测试
│   │   ├── interface_test.cpp      # 接口测试
│   │   ├── large_func_test.cpp     # 大函数测试
│   │   ├── malloc_delete_usable_size.cpp # 分配删除可用大小测试
│   │   ├── malloc_instrumentation_test.cpp # 分配器插桩测试
│   │   ├── mismatched_delete.cpp   // 不匹配删除测试
│   │   ├── new_delete_test.cpp     # new/delete测试
│   │   ├── odr_test.cpp            # ODR测试
│   │   ├── overflow_right.cpp     // 右溢出测试
│   │   ├── partial_right.cpp       // 部分右溢出测试
│   │   ├── poison_memcpy.cpp       // 毒化memcpy测试
│   │   ├── printf_test.cpp         # printf测试
│   │   ├── quarantine_test.cpp     # 隔离测试
│   │   ├── realloc_test.cpp       # realloc测试
│   │   ├── stack_overflow.cpp     # 栈溢出测试
│   │   ├── str_test_*.cpp          # 字符串测试系列
│   │   ├── thread_test.cpp         # 线程测试
│   │   ├── use_after_free.cpp      # 释放后使用测试
│   │   ├── use_after_return.cpp    # 返回后使用测试
│   │   ├── use_after_scope.cpp    # 作用域后使用测试
│   │   ├── vector_test.cpp         # 向量测试
│   │   └── ...                     # 其他500+测试用例
│   ├── Unit/                        # 单元测试
│   │   └── lit.site.cfg.py.in     # 单元测试配置
│   ├── CMakeLists.txt              # 测试主配置文件
│   ├── lit.cfg.py                  # LLVM测试配置
│   └── lit.site.cfg.py.in          # 测试站点配置
├── examples/                       # 示例代码（从测试用例中提取和创建）
│   ├── basic_usage.cpp             # 基本使用示例
│   ├── custom_allocator.cpp         # 自定义分配器示例
│   ├── heap_overflow_detection.cpp  # 堆溢出检测示例
│   ├── stack_overflow_detection.cpp # 栈溢出检测示例
│   ├── use_after_free_detection.cpp # 释放后使用检测示例
│   ├── global_overflow_detection.cpp # 全局变量溢出检测示例
│   ├── thread_sanitizer_example.cpp # 线程安全示例
│   ├── interface_usage_example.cpp  # 接口使用示例
│   ├── asan_options_example.cpp    # ASan选项配置示例
│   ├── custom_malloc_example.cpp   # 自定义malloc示例
│   ├── signal_safe_example.cpp     # 信号安全示例
│   ├── coverage_example.cpp        # 覆盖率示例
│   └── README.md                   # 示例说明文档
├── docs/                          # 文档
│   ├── README.md
│   ├── BUILD.md
│   └── API.md
└── scripts/                       # 构建脚本
    ├── build.sh
    └── install.sh
```

## CMake配置设计（本地化基础设施）

### 1. 主CMakeLists.txt - 使用本地化CMake基础设施
```cmake
cmake_minimum_required(VERSION 3.20.0)
project(TASan VERSION 1.0.0 LANGUAGES C CXX ASM)
set(LLVM_SUBPROJECT_TITLE "TASan")

# 设置为独立构建模式
set(COMPILER_RT_STANDALONE_BUILD TRUE)

# 添加本地CMake模块路径
list(INSERT CMAKE_MODULE_PATH 0
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules"
)

# 包含本地化的基础配置模块
include(base-config-ix)
include(CompilerRTUtils)
include(AddCompilerRT)
include(HandleCompilerRT)
include(CMakeDependentOption)

# 配置平台和架构检测
include(config-ix)

# 设置TASan特定的配置选项
option(TASAN_BUILD_RUNTIME "Build TASan runtime libraries" ON)
option(TASAN_BUILD_TESTS "Build TASan tests" ON)
option(TASAN_BUILD_EXAMPLES "Build TASan examples" ON)

# 配置支持的架构
set(TASAN_SUPPORTED_ARCH ${COMPILER_RT_SUPPORTED_ARCH})
filter_available_targets(TASAN_SUPPORTED_ARCH
  x86_64
  i386
  aarch64
  arm
  armhf
  armeb
  armv7m
  armv7em
  armv6m
  armv7
  armv7s
  armv7k
  arm64e
  powerpc64
  powerpc64le
  mips
  mips64
  mips64el
  mipsel
  riscv32
  riscv64
  sparc
  sparcv9
  s390x
  wasm32
  wasm64
)

# 添加子目录
add_subdirectory(src)
add_subdirectory(include)

if(TASAN_BUILD_TESTS)
  add_subdirectory(tests)
endif()

if(TASAN_BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

# 生成包配置文件
configure_package_config_file(
  cmake/TASanConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/TASanConfig.cmake
  INSTALL_DESTINATION lib/cmake/TASan
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TASanConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

# 安装配置
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/TASanConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/TASanConfigVersion.cmake
  DESTINATION lib/cmake/TASan
)
```

### 2. src/asan/CMakeLists.txt - 使用本地化基础设施
```cmake
# 使用本地化的ASan构建逻辑
include_directories(..)

# 设置编译器运行时公共标志
set(SANITIZER_COMMON_CFLAGS
  ${COMPILER_RT_COMMON_CFLAGS}
  -fno-exceptions
  -fno-rtti
  -fno-builtin
  -fno-stack-protector
  -funwind-tables
  -fasynchronous-unwind-tables
)

# 设置链接标志
set(SANITIZER_COMMON_LINK_FLAGS ${COMPILER_RT_COMMON_LINK_FLAGS})

# 配置ASan源文件列表（重用原有定义）
set(ASAN_SOURCES
  asan_allocator.cpp
  asan_activation.cpp
  asan_debugging.cpp
  asan_descriptions.cpp
  asan_errors.cpp
  asan_fake_stack.cpp
  asan_flags.cpp
  asan_fuchsia.cpp
  asan_globals.cpp
  asan_globals_win.cpp
  asan_interceptors.cpp
  asan_interceptors_memintrinsics.cpp
  asan_linux.cpp
  asan_mac.cpp
  asan_malloc_linux.cpp
  asan_malloc_mac.cpp
  asan_malloc_win.cpp
  asan_memory_profile.cpp
  asan_poisoning.cpp
  asan_posix.cpp
  asan_premap_shadow.cpp
  asan_report.cpp
  asan_rtl.cpp
  asan_shadow_setup.cpp
  asan_stack.cpp
  asan_stats.cpp
  asan_suppressions.cpp
  asan_thread.cpp
  asan_win.cpp
)

# 平台特定源文件
if(WIN32)
  set(ASAN_DYNAMIC_RUNTIME_THUNK_SOURCES
    asan_globals_win.cpp
    asan_win_common_runtime_thunk.cpp
    asan_win_dynamic_runtime_thunk.cpp
  )
  set(ASAN_STATIC_RUNTIME_THUNK_SOURCES
    asan_globals_win.cpp
    asan_malloc_win_thunk.cpp
    asan_win_common_runtime_thunk.cpp
    asan_win_static_runtime_thunk.cpp
  )
endif()

if (NOT WIN32 AND NOT APPLE)
  list(APPEND ASAN_SOURCES
    asan_interceptors_vfork.S
  )
endif()

# C++特定源文件
set(ASAN_CXX_SOURCES
  asan_new_delete.cpp
)

# 静态库特定源文件
set(ASAN_STATIC_SOURCES
  asan_rtl_static.cpp
)

if ("x86_64" IN_LIST TASAN_SUPPORTED_ARCH AND NOT WIN32 AND NOT APPLE)
  list(APPEND ASAN_STATIC_SOURCES
    asan_rtl_x86_64.S
  )
endif()

# 预初始化源文件
set(ASAN_PREINIT_SOURCES
  asan_preinit.cpp
)

# ASan头文件
set(ASAN_HEADERS
  asan_activation.h
  asan_activation_flags.inc
  asan_allocator.h
  asan_descriptions.h
  asan_errors.h
  asan_fake_stack.h
  asan_flags.h
  asan_flags.inc
  asan_init_version.h
  asan_interceptors.h
  asan_interceptors_memintrinsics.h
  asan_interface.inc
  asan_interface_internal.h
  asan_internal.h
  asan_mapping.h
  asan_poisoning.h
  asan_premap_shadow.h
  asan_report.h
  asan_scariness_score.h
  asan_stack.h
  asan_stats.h
  asan_suppressions.h
  asan_thread.h
)

# 设置ASan编译标志
set(ASAN_CFLAGS ${SANITIZER_COMMON_CFLAGS})
append_list_if(MSVC /Zl ASAN_CFLAGS)
append_rtti_flag(OFF ASAN_CFLAGS)

# 设置ASan链接标志
set(ASAN_DYNAMIC_LINK_FLAGS ${SANITIZER_COMMON_LINK_FLAGS})

# 设置ASan定义
set(ASAN_COMMON_DEFINITIONS "")
set(ASAN_DYNAMIC_DEFINITIONS
  ${ASAN_COMMON_DEFINITIONS} ASAN_DYNAMIC=1)
append_list_if(WIN32 INTERCEPTION_DYNAMIC_CRT ASAN_DYNAMIC_DEFINITIONS)

# 设置ASan动态库编译标志
set(ASAN_DYNAMIC_CFLAGS ${ASAN_CFLAGS})
append_list_if(COMPILER_RT_HAS_FTLS_MODEL_INITIAL_EXEC
  -ftls-model=initial-exec ASAN_DYNAMIC_CFLAGS)

# 配置ASan动态库链接库
set(ASAN_DYNAMIC_LIBS
  ${COMPILER_RT_UNWINDER_LINK_LIBS}
  ${SANITIZER_CXX_ABI_LIBRARIES}
  ${SANITIZER_COMMON_LINK_LIBS}
)

append_list_if(COMPILER_RT_HAS_LIBDL dl ASAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBRT rt ASAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBM m ASAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBPTHREAD pthread ASAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBLOG log ASAN_DYNAMIC_LIBS)
append_list_if(MINGW "${MINGW_LIBRARIES}" ASAN_DYNAMIC_LIBS)

# 使用本地化的AddCompilerRT函数创建对象库
add_compiler_rt_object_libraries(RTAsan_dynamic
  OS ${SANITIZER_COMMON_SUPPORTED_OS}
  ARCHS ${TASAN_SUPPORTED_ARCH}
  SOURCES ${ASAN_SOURCES} ${ASAN_CXX_SOURCES}
  ADDITIONAL_HEADERS ${ASAN_HEADERS}
  CFLAGS ${ASAN_DYNAMIC_CFLAGS}
  DEFS ${ASAN_DYNAMIC_DEFINITIONS}
)

if(NOT APPLE)
  add_compiler_rt_object_libraries(RTAsan
    ARCHS ${TASAN_SUPPORTED_ARCH}
    SOURCES ${ASAN_SOURCES}
    ADDITIONAL_HEADERS ${ASAN_HEADERS}
    CFLAGS ${ASAN_CFLAGS}
    DEFS ${ASAN_COMMON_DEFINITIONS}
  )
  
  add_compiler_rt_object_libraries(RTAsan_cxx
    ARCHS ${TASAN_SUPPORTED_ARCH}
    SOURCES ${ASAN_CXX_SOURCES}
    ADDITIONAL_HEADERS ${ASAN_HEADERS}
    CFLAGS ${ASAN_CFLAGS}
    DEFS ${ASAN_COMMON_DEFINITIONS}
  )
  
  add_compiler_rt_object_libraries(RTAsan_static
    ARCHS ${TASAN_SUPPORTED_ARCH}
    SOURCES ${ASAN_STATIC_SOURCES}
    ADDITIONAL_HEADERS ${ASAN_HEADERS}
    CFLAGS ${ASAN_CFLAGS}
    DEFS ${ASAN_COMMON_DEFINITIONS}
  )
  
  add_compiler_rt_object_libraries(RTAsan_preinit
    ARCHS ${TASAN_SUPPORTED_ARCH}
    SOURCES ${ASAN_PREINIT_SOURCES}
    ADDITIONAL_HEADERS ${ASAN_HEADERS}
    CFLAGS ${ASAN_CFLAGS}
    DEFS ${ASAN_COMMON_DEFINITIONS}
  )
endif()

# 添加TASan组件
add_compiler_rt_component(asan)

# 配置通用运行时对象库依赖
set(ASAN_COMMON_RUNTIME_OBJECT_LIBS
  RTInterception
  RTSanitizerCommon
  RTSanitizerCommonLibc
  RTSanitizerCommonCoverage
  RTSanitizerCommonSymbolizer
  RTSanitizerCommonSymbolizerInternal
  RTLSanCommon
  RTUbsan
)

# 使用本地化的AddCompilerRT函数创建运行时库
if(APPLE)
  # macOS平台特定配置
  add_weak_symbols("asan" WEAK_SYMBOL_LINK_FLAGS)
  add_weak_symbols("lsan" WEAK_SYMBOL_LINK_FLAGS)
  add_weak_symbols("ubsan" WEAK_SYMBOL_LINK_FLAGS)
  add_weak_symbols("sanitizer_common" WEAK_SYMBOL_LINK_FLAGS)
  add_weak_symbols("xray" WEAK_SYMBOL_LINK_FLAGS)

  add_compiler_rt_runtime(clang_rt.asan
    SHARED
    OS ${SANITIZER_COMMON_SUPPORTED_OS}
    ARCHS ${TASAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTAsan_dynamic
                RTInterception
                RTSanitizerCommon
                RTSanitizerCommonLibc
                RTSanitizerCommonCoverage
                RTSanitizerCommonSymbolizer
                RTLSanCommon
                RTUbsan
    CFLAGS ${ASAN_DYNAMIC_CFLAGS}
    LINK_FLAGS ${WEAK_SYMBOL_LINK_FLAGS}
    DEFS ${ASAN_DYNAMIC_DEFINITIONS}
    PARENT_TARGET asan
  )

  add_compiler_rt_runtime(clang_rt.asan_static
    STATIC
    ARCHS ${TASAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTAsan_static
    CFLAGS ${ASAN_CFLAGS}
    DEFS ${ASAN_COMMON_DEFINITIONS}
    PARENT_TARGET asan
  )
else()
  # 非Apple平台配置
  if (NOT WIN32)
    add_compiler_rt_runtime(clang_rt.asan
      STATIC
      ARCHS ${TASAN_SUPPORTED_ARCH}
      OBJECT_LIBS RTAsan_preinit
                  RTAsan
                  ${ASAN_COMMON_RUNTIME_OBJECT_LIBS}
      CFLAGS ${ASAN_CFLAGS}
      DEFS ${ASAN_COMMON_DEFINITIONS}
      PARENT_TARGET asan
    )

    add_compiler_rt_runtime(clang_rt.asan_cxx
      STATIC
      ARCHS ${TASAN_SUPPORTED_ARCH}
      OBJECT_LIBS RTAsan_cxx
      CFLAGS ${ASAN_CFLAGS}
      DEFS ${ASAN_COMMON_DEFINITIONS}
      PARENT_TARGET asan
    )

    add_compiler_rt_runtime(clang_rt.asan_static
      STATIC
      ARCHS ${TASAN_SUPPORTED_ARCH}
      OBJECT_LIBS RTAsan_static
      CFLAGS ${ASAN_CFLAGS}
      DEFS ${ASAN_COMMON_DEFINITIONS}
      PARENT_TARGET asan
    )

    add_compiler_rt_runtime(clang_rt.asan-preinit
      STATIC
      ARCHS ${TASAN_SUPPORTED_ARCH}
      OBJECT_LIBS RTAsan_preinit
      CFLAGS ${ASAN_CFLAGS}
      DEFS ${ASAN_COMMON_DEFINITIONS}
      PARENT_TARGET asan
    )
  endif()

  # 动态库配置
  if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "AIX")
    foreach(arch ${TASAN_SUPPORTED_ARCH})
      # 版本脚本处理
      if (COMPILER_RT_HAS_VERSION_SCRIPT)
        if(WIN32)
          set(SANITIZER_RT_VERSION_LIST_LIBS clang_rt.asan-${arch})
        else()
          set(SANITIZER_RT_VERSION_LIST_LIBS clang_rt.asan-${arch} clang_rt.asan_cxx-${arch})
        endif()
        add_sanitizer_rt_version_list(clang_rt.asan-dynamic-${arch}
                                      LIBS ${SANITIZER_RT_VERSION_LIST_LIBS}
                                      EXTRA asan.syms.extra)
        set(VERSION_SCRIPT_FLAG
             -Wl,--version-script,${CMAKE_CURRENT_BINARY_DIR}/clang_rt.asan-dynamic-${arch}.vers)
        if (COMPILER_RT_HAS_GNU_VERSION_SCRIPT_COMPAT)
            list(APPEND VERSION_SCRIPT_FLAG -Wl,-z,gnu-version-script-compat)
        endif()
      else()
        set(VERSION_SCRIPT_FLAG)
      endif()

      # 创建动态运行时库
      add_compiler_rt_runtime(clang_rt.asan
        SHARED
        ARCHS ${arch}
        OBJECT_LIBS ${ASAN_COMMON_RUNTIME_OBJECT_LIBS}
                RTAsan_dynamic
                RTUbsan_cxx
        CFLAGS ${ASAN_DYNAMIC_CFLAGS}
        LINK_FLAGS ${ASAN_DYNAMIC_LINK_FLAGS} ${VERSION_SCRIPT_FLAG}
        LINK_LIBS ${ASAN_DYNAMIC_LIBS}
        DEFS ${ASAN_DYNAMIC_DEFINITIONS}
        PARENT_TARGET asan
      )

      # 符号处理
      if (SANITIZER_USE_SYMBOLS AND NOT ${arch} STREQUAL "i386")
        add_sanitizer_rt_symbols(clang_rt.asan_cxx
          ARCHS ${arch})
        add_dependencies(asan clang_rt.asan_cxx-${arch}-symbols)
        add_sanitizer_rt_symbols(clang_rt.asan
          ARCHS ${arch}
          EXTRA asan.syms.extra)
        add_dependencies(asan clang_rt.asan-${arch}-symbols)
      endif()

      # Windows特定配置
      if (WIN32)
        set(DYNAMIC_RUNTIME_THUNK_CFLAGS "-DSANITIZER_DYNAMIC_RUNTIME_THUNK")
        
        add_compiler_rt_object_libraries(AsanDynamicRuntimeThunk
          ${SANITIZER_COMMON_SUPPORTED_OS}
          ARCHS ${arch}
          SOURCES ${ASAN_DYNAMIC_RUNTIME_THUNK_SOURCES}
          CFLAGS ${ASAN_CFLAGS} ${DYNAMIC_RUNTIME_THUNK_CFLAGS}
          DEFS ${ASAN_COMMON_DEFINITIONS}
        )

        add_compiler_rt_runtime(clang_rt.asan_dynamic_runtime_thunk
          STATIC
          ARCHS ${arch}
          OBJECT_LIBS AsanDynamicRuntimeThunk
                      UbsanRuntimeThunk
                      SancovRuntimeThunk
                      SanitizerRuntimeThunk
          CFLAGS ${ASAN_CFLAGS} ${DYNAMIC_RUNTIME_THUNK_CFLAGS}
          DEFS ${ASAN_COMMON_DEFINITIONS}
          PARENT_TARGET asan
        )

        if(NOT MINGW)
          set(STATIC_RUNTIME_THUNK_CFLAGS "-DSANITIZER_STATIC_RUNTIME_THUNK")
          
          add_compiler_rt_object_libraries(AsanStaticRuntimeThunk
            ${SANITIZER_COMMON_SUPPORTED_OS}
            ARCHS ${arch}
            SOURCES ${ASAN_STATIC_RUNTIME_THUNK_SOURCES}
            CFLAGS ${ASAN_DYNAMIC_CFLAGS} ${STATIC_RUNTIME_THUNK_CFLAGS}
            DEFS ${ASAN_DYNAMIC_DEFINITIONS}
          )

          add_compiler_rt_runtime(clang_rt.asan_static_runtime_thunk
            STATIC
            ARCHS ${arch}
            OBJECT_LIBS AsanStaticRuntimeThunk
                        UbsanRuntimeThunk
                        SancovRuntimeThunk
                        SanitizerRuntimeThunk
            CFLAGS ${ASAN_DYNAMIC_CFLAGS} ${STATIC_RUNTIME_THUNK_CFLAGS}
            DEFS ${ASAN_DYNAMIC_DEFINITIONS}
            PARENT_TARGET asan
          )
        endif()
      endif()
    endforeach()
  endif()
endif()

# 添加资源文件
add_compiler_rt_resource_file(asan_ignorelist asan_ignorelist.txt asan)

# AIX平台特定配置
if (${CMAKE_SYSTEM_NAME} MATCHES "AIX")
  foreach(arch ${TASAN_SUPPORTED_ARCH})
    add_compiler_rt_cfg(asan_symbols_${arch} asan.link_with_main_exec.txt asan ${arch})
    add_compiler_rt_cfg(asan_cxx_symbols_${arch} asan_cxx.link_with_main_exec.txt asan ${arch})
  endforeach()
endif()
```

## 需要复制的文件清单

### 1. CMake基础设施文件

#### 1.1 核心配置文件
- **cmake/base-config-ix.cmake**: 基础配置
- **cmake/config-ix.cmake**: 平台和架构检测配置

#### 1.2 关键模块文件
- **cmake/Modules/AddCompilerRT.cmake**: 添加编译器运行时的核心函数
- **cmake/Modules/CompilerRTUtils.cmake**: 编译器运行时工具函数
- **cmake/Modules/HandleCompilerRT.cmake**: 处理编译器运行时的配置
- **cmake/Modules/CompilerRTCompile.cmake**: 编译相关工具
- **cmake/Modules/CompilerRTLink.cmake**: 链接相关工具
- **cmake/Modules/SanitizerUtils.cmake**: Sanitizer工具函数

#### 1.3 平台特定工具
- **cmake/Modules/CompilerRTDarwinUtils.cmake**: macOS平台工具
- **cmake/Modules/CompilerRTAIXUtils.cmake**: AIX平台工具
- **cmake/Modules/BuiltinTests.cmake**: 内置测试工具
- **cmake/Modules/AllSupportedArchDefs.cmake**: 支持的架构定义
- **cmake/Modules/CheckSectionExists.cmake**: 段检查工具
- **cmake/Modules/UseLibtool.cmake**: Libtool使用工具

#### 1.4 构建缓存配置
- **cmake/caches/Apple.cmake**: Apple平台缓存配置
- **cmake/caches/GPU.cmake**: GPU平台缓存配置
- **cmake/caches/hexagon-linux-builtins.cmake**: Hexagon Linux内置配置
- **cmake/caches/hexagon-linux-clangrt.cmake**: Hexagon Linux clangrt配置

### 2. ASan核心源文件

#### 2.1 ASan库源文件（从compiler-rt/lib/asan复制）
- **核心实现文件**（约30个.cpp文件）:
  - asan_allocator.cpp, asan_activation.cpp, asan_debugging.cpp
  - asan_descriptions.cpp, asan_errors.cpp, asan_fake_stack.cpp
  - asan_flags.cpp, asan_globals.cpp, asan_interceptors.cpp
  - asan_linux.cpp, asan_mac.cpp, asan_win.cpp
  - asan_malloc_linux.cpp, asan_malloc_mac.cpp, asan_malloc_win.cpp
  - asan_memory_profile.cpp, asan_poisoning.cpp, asan_posix.cpp
  - asan_premap_shadow.cpp, asan_report.cpp, asan_rtl.cpp
  - asan_shadow_setup.cpp, asan_stack.cpp, asan_stats.cpp
  - asan_suppressions.cpp, asan_thread.cpp, asan_new_delete.cpp
  - asan_rtl_static.cpp, asan_preinit.cpp

- **头文件**（约25个.h和.inc文件）:
  - asan_activation.h, asan_allocator.h, asan_descriptions.h
  - asan_errors.h, asan_fake_stack.h, asan_flags.h
  - asan_init_version.h, asan_interceptors.h, asan_internal.h
  - asan_mapping.h, asan_poisoning.h, asan_report.h
  - asan_scariness_score.h, asan_stack.h, asan_stats.h
  - asan_suppressions.h, asan_thread.h, 以及各种.inc文件

- **平台特定文件**:
  - asan_globals_win.cpp, asan_fuchsia.cpp
  - asan_interceptors_vfork.S, asan_rtl_x86_64.S
  - asan_mapping_sparc64.h

- **配置和数据文件**:
  - asan_ignorelist.txt, asan.syms.extra, weak_symbols.txt
  - CMakeLists.txt, README.txt

#### 2.2 Sanitizer Common源文件（从compiler-rt/lib/sanitizer_common复制）
- **通用组件**（约40个.cpp文件）:
  - sanitizer_allocator.cpp, sanitizer_common.cpp
  - sanitizer_deadlock_detector.cpp, sanitizer_flags.cpp
  - sanitizer_file.cpp, sanitizer_linux.cpp, sanitizer_mac.cpp
  - sanitizer_mutex.cpp, sanitizer_posix.cpp, sanitizer_printf.cpp
  - sanitizer_procmaps_*.cpp, sanitizer_stacktrace.cpp
  - sanitizer_symbolizer.cpp, sanitizer_thread_registry.cpp
  - sanitizer_tls_get_addr.cpp, sanitizer_win.cpp

- **头文件**（约30个.h文件）:
  - sanitizer_common.h, sanitizer_internal_defs.h
  - sanitizer_allocator.h, sanitizer_flags.h, sanitizer_mutex.h
  - sanitizer_platform.h, sanitizer_stacktrace.h, sanitizer_symbolizer.h

#### 2.3 Interception源文件（从compiler-rt/lib/interception复制）
- **拦截器实现**（约5个.cpp文件）:
  - interception_linux.cpp, interception_mac.cpp, interception_win.cpp
  - interception.h, interception_type_test.cpp

#### 2.4 公共头文件（从compiler-rt/include/sanitizer复制）
- **接口定义**:
  - asan_interface.h, common_interface_defs.h
  - sanitizer_internal_defs.h

### 3. 测试文件（从compiler-rt/test/asan复制）

#### 3.1 测试配置文件
- **tests/CMakeLists.txt**: 测试主配置文件
- **tests/lit.cfg.py**: LLVM测试运行配置
- **tests/lit.site.cfg.py.in**: 测试站点配置模板

#### 3.2 测试用例（523个文件）
- **tests/TestCases/**: 主要测试用例目录
  - **通用测试用例**（约400个文件）:
    - 内存错误检测: heap_overflow.cpp, stack_overflow.cpp, global_overflow.cpp
    - 释放后使用: use_after_free.cpp, use_after_return.cpp, use_after_scope.cpp
    - 双重释放: double_free.cpp
    - 分配释放不匹配: alloc_dealloc_mismatch.cpp, mismatched_delete.cpp
    - 栈相关: alloca_overflow.cpp, alloca_big_alignment.cpp
    - 字符串操作: str_test_*.cpp
    - 线程安全: thread_test.cpp
    - 接口测试: interface_test.cpp, asan_options.cpp
    - 自定义分配器: custom_malloc_test.cpp
    - 覆盖率: asan_and_llvm_coverage_test.cpp
    - 大内存操作: big_malloc_delete.cpp, large_func_test.cpp

  - **平台特定测试**:
    - **Linux/**: Linux平台特定测试（约50个文件）
    - **Darwin/**: macOS平台特定测试（约30个文件）
    - **Android/**: Android平台特定测试（约20个文件）
    - **Windows/**: Windows平台特定测试（约15个文件）
    - **Fuchsia/**: Fuchsia平台特定测试（约8个文件）

#### 3.3 单元测试
- **tests/Unit/**: 单元测试目录
  - lit.site.cfg.py.in: 单元测试配置

### 4. 示例代码（从测试用例提取和创建）

#### 4.1 基础示例
- **examples/basic_usage.cpp**: ASan基本使用方法
- **examples/custom_allocator.cpp**: 自定义内存分配器
- **examples/interface_usage_example.cpp**: ASan接口使用示例

#### 4.2 检测示例
- **examples/heap_overflow_detection.cpp**: 堆溢出检测示例
- **examples/stack_overflow_detection.cpp**: 栈溢出检测示例
- **examples/use_after_free_detection.cpp**: 释放后使用检测示例
- **examples/global_overflow_detection.cpp**: 全局变量溢出检测示例

#### 4.3 高级示例
- **examples/thread_sanitizer_example.cpp**: 线程安全示例
- **examples/asan_options_example.cpp**: ASan选项配置示例
- **examples/custom_malloc_example.cpp**: 自定义malloc示例
- **examples/signal_safe_example.cpp**: 信号安全示例
- **examples/coverage_example.cpp**: 覆盖率示例

#### 4.4 示例文档
- **examples/README.md**: 示例说明文档

## 关键本地化函数

### 1. 核心构建函数
- **add_compiler_rt_object_libraries()**: 创建对象库
- **add_compiler_rt_runtime()**: 创建运行时库
- **filter_available_targets()**: 过滤可用的架构目标
- **append_list_if()**: 条件性添加列表项
- **append_rtti_flag()**: 添加RTTI标志
- **add_compiler_rt_component()**: 添加编译器运行时组件

### 2. 平台检测能力
- 自动检测Linux、macOS、Windows等平台
- 支持x86_64、AArch64、ARM、MIPS等多种架构
- 兼容Clang、GCC、MSVC等编译器
- 支持Debug、Release、RelWithDebInfo等配置

## 构建目标

### 1. 库目标（保持与LLVM兼容）
- **clang_rt.asan**: ASan动态运行时库
- **clang_rt.asan_static**: ASan静态运行时库
- **clang_rt.asan_cxx**: ASan C++运行时库
- **clang_rt.asan-preinit**: ASan预初始化库
- **RTSanitizerCommon**: 通用sanitizer组件
- **RTSanitizerCommonSymbolizer**: 符号化组件

### 2. 平台特定目标
- **macOS**: 支持弱符号和框架集成
- **Linux**: 支持静态和动态链接
- **Windows**: 支持运行时thunk和DLL
- **AIX**: 支持特定的链接配置

## 使用方式

### 1. 构建ASan库
```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8
```

### 2. 使用ASan库
```cmake
find_package(TASan REQUIRED)
target_link_libraries(my_app clang_rt.asan)
```

### 3. 编译时启用ASan
```bash
clang++ -fsanitize=address -L/path/to/tasan/lib -lclang_rt.asan my_app.cpp
```

## 本地化优势

### 1. 完全独立
- 不依赖任何外部LLVM项目
- 所有构建工具都在本地
- 可以完全自主维护和修改

### 2. 保持兼容性
- 使用经过验证的LLVM CMake构建逻辑
- 维持与原有LLVM项目的API兼容性
- 继承完整的跨平台支持能力

### 3. 易于维护
- 本地化的构建基础设施
- 可以独立进行bug修复和改进
- 降低对外部项目的依赖风险

## 实施计划

### 第一阶段：CMake基础设施本地化
1. 从LLVM项目复制核心CMake配置文件到`cmake/`目录
2. 复制Modules目录下的所有关键工具函数
3. 复制平台特定的工具和缓存配置文件
4. 验证CMake基础设施的完整性

### 第二阶段：ASan核心源文件复制
1. 从`compiler-rt/lib/asan/`复制所有核心实现文件
2. 从`compiler-rt/lib/sanitizer_common/`复制通用组件
3. 从`compiler-rt/lib/interception/`复制拦截器模块
4. 从`compiler-rt/include/sanitizer/`复制公共头文件
5. 确保所有源文件的依赖关系正确

### 第三阶段：测试集复制
1. 从`compiler-rt/test/asan/`复制测试配置文件
2. 复制所有523个测试用例到`tests/TestCases/`目录
3. 复制平台特定的测试子目录
4. 复制单元测试配置文件
5. 适配测试配置以支持独立构建

### 第四阶段：示例代码创建
1. 从测试用例中提取和创建基础示例
2. 创建各种内存错误检测示例
3. 创建高级功能使用示例
4. 编写示例说明文档
5. 验证所有示例的正确性

### 第五阶段：构建系统适配
1. 适配主CMakeLists.txt以支持独立构建
2. 适配各子模块的CMakeLists.txt
3. 配置测试和示例的构建选项
4. 设置安装规则和导出配置
5. 验证跨平台构建能力

### 第六阶段：测试和验证
1. 运行所有523个测试用例验证功能正确性
2. 测试跨平台构建（Linux、macOS、Windows）
3. 验证动态库和静态库的构建
4. 测试示例代码的正确性
5. 进行性能和兼容性测试

### 第七阶段：文档和发布
1. 完善API文档和使用说明
2. 创建构建脚本和安装指南
3. 编写开发者文档
4. 准备发布版本
5. 建立维护和更新流程

此方案通过将必要的LLVM CMake基础设施本地化，确保ASan独立模块能够获得与原LLVM项目相同的跨平台构建能力和功能完整性，同时完全避免对外部项目的依赖。