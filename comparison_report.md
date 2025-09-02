# ASan Library Comparison Report

## Executive Summary

**ERROR STATE ISSUED**: Significant differences found between the official LLVM ASan library and the standalone TASan implementation.

**Critical Finding**: 90 out of 114 object files differ between the two builds, indicating substantial discrepancies in the generated libraries.

## Build Configuration

Both builds were configured with identical settings:
- **Build Type**: Debug
- **C Compiler**: `/usr/bin/clang-19`
- **CXX Compiler**: `/usr/bin/clang++-19`
- **ASM Compiler**: `/usr/bin/clang-19`
- **Target Architecture**: x86_64
- **Build System**: Ninja

## Library Size Comparison

| Library | Size (bytes) | Difference |
|---------|-------------|-----------|
| Official ASan | 6,441,668 | Baseline |
| Standalone TASan | 3,448,708 | -2,992,960 bytes (-46.5%) |

**Major Issue**: The standalone library is 46.5% smaller than the official version, indicating significant missing functionality.

## Missing Components in Standalone Build

### Missing Object Files (9 files):
1. `lsan_common.cpp.o` - LeakSanitizer common functionality
2. `lsan_common_fuchsia.cpp.o` - LeakSanitizer Fuchsia support
3. `lsan_common_linux.cpp.o` - LeakSanitizer Linux support
4. `lsan_common_mac.cpp.o` - LeakSanitizer macOS support
5. `ubsan_diag.cpp.o` - UndefinedBehaviorSanitizer diagnostics
6. `ubsan_flags.cpp.o` - UndefinedBehaviorSanitizer flags
7. `ubsan_handlers.cpp.o` - UndefinedBehaviorSanitizer handlers
8. `ubsan_init.cpp.o` - UndefinedBehaviorSanitizer initialization
9. `ubsan_monitor.cpp.o` - UndefinedBehaviorSanitizer monitoring
10. `ubsan_value.cpp.o` - UndefinedBehaviorSanitizer value tracking

### Analysis of Missing Components:
- **LeakSanitizer (LSan)**: Completely missing from standalone build
- **UndefinedBehaviorSanitizer (UBSan)**: Completely missing from standalone build

## Differing Object Files (81 files):

### ASan Core Files (all differ):
- `asan_allocator.cpp.o`
- `asan_activation.cpp.o`
- `asan_debugging.cpp.o`
- `asan_descriptions.cpp.o`
- `asan_errors.cpp.o`
- `asan_fake_stack.cpp.o`
- `asan_flags.cpp.o`
- `asan_globals.cpp.o`
- `asan_interceptors.cpp.o`
- `asan_malloc_linux.cpp.o`
- `asan_poisoning.cpp.o`
- `asan_report.cpp.o`
- `asan_rtl.cpp.o`
- `asan_shadow_setup.cpp.o`
- `asan_stack.cpp.o`
- `asan_suppressions.cpp.o`
- `asan_thread.cpp.o`

### Sanitizer Common Files (all differ):
- `sanitizer_allocator.cpp.o`
- `sanitizer_common.cpp.o`
- `sanitizer_common_libcdep.cpp.o`
- `sanitizer_coverage_libcdep_new.cpp.o`
- `sanitizer_deadlock_detector1.cpp.o`
- `sanitizer_deadlock_detector2.cpp.o`
- `sanitizer_dl.cpp.o`
- `sanitizer_errno.cpp.o`
- `sanitizer_file.cpp.o`
- `sanitizer_flag_parser.cpp.o`
- `sanitizer_flags.cpp.o`
- `sanitizer_libc.cpp.o`
- `sanitizer_libignore.cpp.o`
- `sanitizer_linux.cpp.o`
- `sanitizer_linux_libcdep.cpp.o`
- `sanitizer_mutex.cpp.o`
- `sanitizer_platform_limits_linux.cpp.o`
- `sanitizer_platform_limits_posix.cpp.o`
- `sanitizer_posix.cpp.o`
- `sanitizer_posix_libcdep.cpp.o`
- `sanitizer_printf.cpp.o`
- `sanitizer_procmaps_common.cpp.o`
- `sanitizer_procmaps_linux.cpp.o`
- `sanitizer_range.cpp.o`
- `sanitizer_stackdepot.cpp.o`
- `sanitizer_stack_store.cpp.o`
- `sanitizer_stacktrace.cpp.o`
- `sanitizer_stacktrace_libcdep.cpp.o`
- `sanitizer_stacktrace_printer.cpp.o`
- `sanitizer_stoptheworld_linux_libcdep.cpp.o`
- `sanitizer_suppressions.cpp.o`
- `sanitizer_symbolizer.cpp.o`
- `sanitizer_symbolizer_libbacktrace.cpp.o`
- `sanitizer_symbolizer_libcdep.cpp.o`
- `sanitizer_symbolizer_markup.cpp.o`
- `sanitizer_symbolizer_posix_libcdep.cpp.o`
- `sanitizer_symbolizer_report.cpp.o`
- `sanitizer_termination.cpp.o`
- `sanitizer_thread_arg_retval.cpp.o`
- `sanitizer_thread_history.cpp.o`
- `sanitizer_thread_registry.cpp.o`
- `sanitizer_tls_get_addr.cpp.o`
- `sanitizer_type_traits.cpp.o`
- `sanitizer_unwind_linux_libcdep.cpp.o`

### Interception Files (all differ):
- `interception_linux.cpp.o`
- `interception_mac.cpp.o`
- `interception_type_test.cpp.o`
- `interception_win.cpp.o`
- `interception_aix.cpp.o`

## Root Cause Analysis

### 1. Missing Sanitizer Components
The standalone build is missing entire sanitizer components:
- **LeakSanitizer (LSan)**: Critical for memory leak detection
- **UndefinedBehaviorSanitizer (UBSan)**: Essential for undefined behavior detection

### 2. Incomplete Source Code
The standalone project appears to be missing source files for:
- All LSan implementation files
- All UBSan implementation files
- Potentially modified/trimmed versions of existing files

### 3. Build Configuration Differences
Despite using the same CMake flags, the standalone project has:
- Different CMake configuration structure
- Missing build targets and components
- Altered dependency relationships

## Impact Assessment

### High Impact Issues:
1. **Missing Leak Detection**: No LSan means memory leaks won't be detected
2. **Missing UB Detection**: No UBSan means undefined behaviors won't be caught
3. **Reduced Functionality**: Many core ASan features may be impaired
4. **Compatibility Issues**: May not work correctly with existing ASan toolchains

### Medium Impact Issues:
1. **Size Discrepancy**: 46.5% smaller library suggests missing features
2. **Object File Differences**: Even shared files have differences, potential bugs or missing optimizations

### Low Impact Issues:
1. **Platform Support**: Some platform-specific files may be intentionally excluded

## Recommendations

### Immediate Actions Required:
1. **Add Missing Source Files**: Include all LSan and UBSan source files
2. **Verify Build Configuration**: Ensure all CMake options match official build
3. **Check Source Code Patches**: Verify no modifications were made to core files
4. **Test Functionality**: Comprehensive testing to ensure all ASan features work

### Investigation Steps:
1. Compare source file lists between official and standalone projects
2. Examine build logs for skipped components
3. Check for conditional compilation differences
4. Verify symbol table completeness

### Quality Assurance:
1. Run full ASan test suite
2. Compare runtime behavior between libraries
3. Validate memory error detection capabilities
4. Ensure compatibility with existing toolchains

## Conclusion

The standalone TASan implementation is **NOT functionally equivalent** to the official LLVM ASan library. The missing components and differences in object files indicate a substantially incomplete implementation that would fail to provide the full memory safety guarantees expected from ASan.

**ERROR STATE CONFIRMED**: The standalone build produces a library that is missing critical functionality and differs significantly from the official implementation.

## Build Directories Preserved

For further investigation:
- Official build: `/home/leo/projects/tasan/build_official`
- Standalone build: `/home/leo/projects/tasan/build`

## Next Steps

1. **Immediate**: Halt use of standalone TASan for production
2. **Investigation**: Determine why critical components are missing
3. **Rectification**: Add missing components and retest
4. **Validation**: Ensure functional equivalence before deployment

---
*Generated by: /home/leo/projects/tasan/scripts/build_and_compare.sh*
*Date: $(date)*