# TASan - Standalone AddressSanitizer Library

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/your-username/tasan)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](https://github.com/your-username/tasan/blob/main/LICENSE)
[![C++](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/)
[![CMake](https://img.shields.io/badge/CMake-3.20%2B-blue.svg)](https://cmake.org/)

**TASan** is a completely standalone AddressSanitizer (ASan) runtime library extracted from the LLVM project. It provides state-of-the-art memory error detection capabilities without any external LLVM dependencies, making it easy to integrate into any C/C++ project.

## 🌟 Features

### 🛡️ Memory Error Detection
- **Heap Buffer Overflow**: Detects overflows and underflows in heap-allocated memory
- **Stack Buffer Overflow**: Catches stack-based buffer overflows
- **Use-After-Free**: Identifies accesses to freed memory
- **Global Variable Overflow**: Detects overflows in global variables
- **Double Free**: Catches multiple deallocations of the same memory
- **Invalid Free**: Detects attempts to free invalid pointers

### 🔧 Technical Capabilities
- **Shadow Memory**: Uses 1:8 shadow mapping for efficient memory error detection
- **Function Interception**: Cross-platform function wrapping for comprehensive coverage
- **Thread Safety**: Full support for multi-threaded applications
- **Cross-Platform**: Supports Linux, macOS, Windows, Android, Fuchsia, and AIX
- **Multi-Architecture**: Compatible with x86_64, i386, AArch64, ARM, MIPS, RISC-V

### 📦 Standalone Design
- **No LLVM Dependencies**: Completely independent build system
- **Localized CMake**: All necessary CMake infrastructure included
- **Easy Integration**: Simple to add to existing projects
- **Flexible Linking**: Supports both static and dynamic linking

## 🚀 Quick Start

### Prerequisites

- **CMake**: 3.20.0 or higher
- **C++ Compiler**: Clang, GCC, or MSVC with C++17 support
- **Build Tools**: Make or Ninja
- **System Libraries**: Standard C library and pthread support

### Building the Library

```bash
# Clone the repository
git clone https://github.com/your-username/tasan.git
cd tasan

# Create build directory
mkdir build && cd build

# Configure with CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build all targets
make -j$(nproc)

# Build specific library
make clang_rt.asan
```

### Using TASan in Your Project

#### Method 1: Link with TASan Library

```bash
# Compile your program with TASan
g++ -fsanitize=address -o your_program your_source.cpp
```

#### Method 2: Manual Linking

```bash
# Compile your source files
g++ -c your_source.cpp -o your_source.o

# Link with TASan library
g++ your_source.o -o your_program -L/path/to/tasan/lib -lclang_rt.asan-x86_64
```

#### Method 3: CMake Integration

```cmake
cmake_minimum_required(VERSION 3.20)
project(YourProject)

# Add TASan library
add_subdirectory(path/to/tasan)

# Link your target with TASan
add_executable(your_program your_source.cpp)
target_link_libraries(your_program clang_rt.asan-x86_64)
```

## 📚 Examples

The project includes several example programs to demonstrate TASan capabilities:

### Basic Usage Example
```cpp
#include <iostream>

int main() {
    int* array = new int[10];
    
    // Initialize array
    for (int i = 0; i < 10; i++) {
        array[i] = i;
    }
    
    // Use array safely
    std::cout << "Array values: ";
    for (int i = 0; i < 10; i++) {
        std::cout << array[i] << " ";
    }
    std::cout << std::endl;
    
    delete[] array;
    std::cout << "Basic ASan example completed successfully!" << std::endl;
    return 0;
}
```

### Heap Overflow Detection
```cpp
#include <iostream>

int main() {
    int* array = new int[10];
    
    // Initialize array
    for (int i = 0; i < 10; i++) {
        array[i] = i;
    }
    
    std::cout << "Array initialized with values 0-9" << std::endl;
    
    // This would trigger ASan error (commented for safe execution)
    // array[10] = 42;  // Heap buffer overflow
    // array[-1] = 24;  // Heap buffer underflow
    
    delete[] array;
    std::cout << "Heap overflow detection example completed!" << std::endl;
    return 0;
}
```

### Use-After-Free Detection
```cpp
#include <iostream>

int main() {
    int* ptr = new int(42);
    
    std::cout << "Value: " << *ptr << std::endl;
    
    delete ptr;
    std::cout << "Memory freed" << std::endl;
    
    // This would trigger ASan error (commented for safe execution)
    // std::cout << "After free: " << *ptr << std::endl;  // Use-after-free
    
    std::cout << "Use-after-free detection example completed!" << std::endl;
    return 0;
}
```

## 🔧 Build Configuration

### CMake Options

```bash
# Basic configuration
cmake .. -DCMAKE_BUILD_TYPE=Release

# With tests enabled
cmake .. -DCMAKE_BUILD_TYPE=Release -DTASAN_BUILD_TESTS=ON

# With examples only
cmake .. -DCMAKE_BUILD_TYPE=Release -DTASAN_BUILD_EXAMPLES=ON

# Custom install prefix
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
```

### Build Targets

```bash
# Build all libraries and examples
make all

# Build specific runtime libraries
make clang_rt.asan              # Main ASan runtime
make clang_rt.asan_static       # Static version
make clang_rt.asan_cxx          # C++ components
make clang_rt.asan-preinit      # Preinit components

# Build examples
make examples

# Run tests (if enabled)
make check-asan

# Install libraries
make install
```

## 📁 Project Structure

```
tasan/
├── CMakeLists.txt              # Main project configuration
├── README.md                   # This file
├── cmake/                      # Localized LLVM CMake infrastructure
│   ├── Modules/               # CMake modules
│   └── caches/                # Build cache configurations
├── src/                        # Source code
│   ├── asan/                  # ASan core implementation
│   ├── lsan/                  # LeakSanitizer components
│   ├── ubsan/                 # UndefinedBehaviorSanitizer components
│   ├── sanitizer_common/      # Shared sanitizer utilities
│   └── interception/          # Function interception module
├── include/sanitizer/         # Public headers
├── tests/                     # Test cases (453 from LLVM)
├── examples/                  # Example programs
└── lib/                       # Built libraries (output)
```

## 🧪 Testing

The project includes 453 test cases from the LLVM project to ensure comprehensive coverage:

```bash
# Run all tests
make check-asan

# Run specific test categories
cd build && lit tests/TestCases/heap_overflow.cpp
cd build && lit tests/TestCases/Linux/
cd build && lit tests/TestCases/Darwin/
```

### Test Categories

- **Heap Memory Tests**: Heap buffer overflow/underflow detection
- **Stack Memory Tests**: Stack-based buffer overflow detection
- **Use-After-Free Tests**: Use-after-free detection
- **Global Variable Tests**: Global variable overflow detection
- **Thread Safety Tests**: Multi-threaded application testing
- **Platform-Specific Tests**: OS-specific functionality tests

## 🔍 Advanced Configuration

### Custom Build Settings

```cmake
# In your CMakeLists.txt
set(TASAN_SUPPORTED_ARCH x86_64)  # Limit to specific architecture
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
```

### Environment Variables

```bash
# ASan runtime options
export ASAN_OPTIONS=detect_stack_use_after_return=1
export ASAN_OPTIONS=abort_on_error=1
export ASAN_OPTIONS=verbosity=1
```

### Integration with Build Systems

#### Makefile Integration
```makefile
CXX = g++
CXXFLAGS = -fsanitize=address -g
LDFLAGS = -fsanitize=address

your_program: your_source.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^
```

#### Autotools Integration
```configure.ac
AX_CHECK_COMPILE_FLAG([-fsanitize=address], [CXXFLAGS="$CXXFLAGS -fsanitize=address"])
AX_CHECK_LINK_FLAG([-fsanitize=address], [LDFLAGS="$LDFLAGS -fsanitize=address"])
```

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   ```bash
   # Ensure CMake version is 3.20 or higher
   cmake --version
   
   # Clean build directory
   rm -rf build && mkdir build && cd build
   ```

2. **Link Errors**
   ```bash
   # Check library path
   ls -la lib/
   
   # Verify library exists
   find . -name "libclang_rt.asan*"
   ```

3. **Runtime Errors**
   ```bash
   # Check ASan environment
   env | grep ASAN
   
   # Enable verbose output
   export ASAN_OPTIONS=verbosity=1
   ```

### Getting Help

- **Documentation**: Check the [CLAUDE.md](CLAUDE.md) file for development guidelines
- **Issues**: Report bugs on [GitHub Issues](https://github.com/your-username/tasan/issues)
- **Discussions**: Join our [GitHub Discussions](https://github.com/your-username/tasan/discussions)

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone with development dependencies
git clone --recurse-submodules https://github.com/your-username/tasan.git

# Setup development environment
cd tasan
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DTASAN_BUILD_TESTS=ON
make -j$(nproc)
make check-asan
```

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **LLVM Project**: TASan is based on the AddressSanitizer runtime from LLVM
- **Compiler-RT Team**: For the original implementation and ongoing maintenance
- **Contributors**: All the developers who have helped improve ASan over the years

## 📈 Performance

TASan provides memory error detection with reasonable performance overhead:

- **Slowdown**: Typically 2x-4x slowdown compared to native execution
- **Memory Overhead**: Approximately 3x memory usage due to shadow memory
- **Detection Rate**: Catches most common memory errors with low false positive rate

### Optimization Tips

```bash
# Reduce overhead with options
export ASAN_OPTIONS=quarantine_size_mb=16
export ASAN_OPTIONS=malloc_context_size=2

# Use in production with care
export ASAN_OPTIONS=handle_segv=0
```

## 🗺️ Roadmap

- [ ] **Performance Optimizations**: Reduce runtime overhead
- [ ] **Additional Platforms**: Add support for more embedded systems
- [ ] **Enhanced Documentation**: More examples and tutorials
- [ ] **Integration Tools**: Easy integration scripts for popular build systems
- [ ] **GUI Tools**: Visual memory error analysis tools

---

**Built with ❤️ using modern CMake and LLVM technologies**

For more information, visit our [GitHub Repository](https://github.com/your-username/tasan) or join our community discussions.