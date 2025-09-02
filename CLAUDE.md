# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains TASan - a standalone AddressSanitizer (ASan) library extracted from LLVM project. The goal is to create a completely independent module that can be built and used without any external LLVM dependencies.

### Key Architecture

- **Standalone Build**: All necessary LLVM CMake infrastructure is localized in `cmake/` directory
- **Multi-component**: Consists of ASan runtime, sanitizer_common utilities, and interception modules
- **Cross-platform**: Supports Linux, macOS, Windows, Android, Fuchsia, and AIX
- **Multi-architecture**: Supports x86_64, i386, AArch64, ARM, MIPS, RISC-V, and more

### Directory Structure

```
tasan/
├── CMakeLists.txt           # Main CMake configuration
├── cmake/                   # Localized LLVM CMake infrastructure
│   ├── Modules/            # CMake modules (AddCompilerRT.cmake, etc.)
│   └── caches/             # Build cache configurations
├── src/
│   ├── asan/               # ASan core implementation
│   ├── sanitizer_common/   # Shared sanitizer utilities
│   └── interception/       # Function interception module
├── include/sanitizer/      # Public headers
├── tests/                  # 453 test cases from LLVM
└── examples/               # Usage examples
```

## Common Development Commands

### Building the Project

```bash
# Create build directory
mkdir build && cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release -DTASAN_BUILD_TESTS=ON

# Build all targets
make -j$(nproc)

# Build specific target
make clang_rt.asan
```

### Running Tests

```bash
# Run all tests
make check-asan

# Run specific test category
cd build && lit tests/TestCases/heap_overflow.cpp

# Run platform-specific tests
cd build && lit tests/TestCases/Linux/
```

### Building Examples

```bash
# Build examples
make examples

# Run specific example
./examples/basic_usage_example
```

### Installation

```bash
# Install to system
make install

# Install to custom prefix
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
make install
```

## Key Build System Components

### Localized CMake Infrastructure

The project uses localized LLVM CMake modules to maintain independence:

- **AddCompilerRT.cmake**: Core functions for creating runtime libraries
- **CompilerRTUtils.cmake**: Utility functions for build configuration
- **HandleCompilerRT.cmake**: Platform and compiler detection logic
- **SanitizerUtils.cmake**: Sanitizer-specific build utilities

### Build Targets

- **Runtime Libraries**: `clang_rt.asan`, `clang_rt.asan_static`, `clang_rt.asan_cxx`
- **Component Libraries**: `RTSanitizerCommon`, `RTInterception`, `RTSanitizerCommonSymbolizer`
- **Test Targets**: `check-asan`, `asan-tests`
- **Example Targets**: `examples`, `basic_usage_example`

## Development Workflow

### Adding New Tests

1. Place test files in `tests/TestCases/` directory
2. Follow LLVM lit test format (`.cpp` files with `// RUN:` directives)
3. Test will be automatically discovered by CMake

### Modifying Build Configuration

1. Edit `CMakeLists.txt` for high-level configuration
2. Modify localized CMake modules in `cmake/Modules/` for build system changes
3. Maintain compatibility with original LLVM build patterns

### Platform-Specific Development

- **Linux**: Focus on static/dynamic linking and glibc compatibility
- **macOS**: Handle weak symbols and framework integration
- **Windows**: Support runtime thunk and DLL configurations
- **Mobile**: Android and Fuchsia require special handling

## Important Technical Details

### Shadow Memory Architecture

ASan uses shadow memory to detect memory errors:
- 1:8 shadow mapping (1 byte shadow for 8 bytes of application memory)
- Platform-specific shadow base address calculation
- Handles different memory layouts across platforms

### Function Interception

The `interception/` module provides:
- Cross-platform function wrapping
- Support for dynamic and static linking
- Platform-specific interception mechanisms

### Build System Integration

- Uses localized versions of LLVM's CMake infrastructure
- Maintains compatibility with original ASan build patterns
- Supports both standalone and integrated builds

## Testing Strategy

The project includes 453 test cases covering:
- Heap overflow/underflow detection
- Stack overflow detection
- Use-after-free detection
- Global variable overflow
- Thread safety issues
- Platform-specific scenarios

## Dependencies

External dependencies are minimal:
- CMake 3.20.0 or higher
- C++17 compatible compiler (Clang, GCC, MSVC)
- Platform-specific system libraries (dl, pthread, etc.)

## Configuration Options

Key CMake options:
- `DTASAN_BUILD_RUNTIME`: Build runtime libraries (default: ON)
- `DTASAN_BUILD_TESTS`: Build test suite (default: ON)
- `DTASAN_BUILD_EXAMPLES`: Build example programs (default: ON)
- `DCMAKE_BUILD_TYPE`: Release, Debug, RelWithDebInfo

## User Instructions
- DO NOT MODIFY ANY FILE UNDER `llvm-project`. IT'S ONLY MEANT TO BE COPIED CODE FROM.
- AFTER EACH CODE MODIFICATION TASK, RUN CMAKE & MAKE TO CHECK FOR CORRECT COMPILING. FIX ANY ERROR IMMEDIATELY BEFORE YOU MOVE ON.
- YOU SHOULD KEEP TRACK OF YOUR PROCESS WITH A `.claude/context.md` FILE. LIST WHAT HAS BEEN DONE. ALL SUB-AGENT YOU CALLED SHOULD PROVIDE A SEPARATE `task-X.md` TO RECORD THEIR PROCEDURE.
- ON EACH NEW STEP OR INVOCATION OF SUB-AGENTS, ALWAYS REFER TO THE `context.md`, THE `task-X.md` (if any), AND THE `plan.md` TO KNOW THE CONTEXT OF YOUR TASK