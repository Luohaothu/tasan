# TASan Examples

This directory contains example programs demonstrating how to use TASan (AddressSanitizer).

## Examples

### basic_usage.cpp
Demonstrates basic memory allocation and deallocation with ASan enabled.

### heap_overflow_detection.cpp
Shows how ASan detects heap buffer overflow and underflow errors.

### use_after_free_detection.cpp
Demonstrates ASan's use-after-free detection capabilities.

## Building and Running

To build the examples:
```bash
mkdir build && cd build
cmake .. -DTASAN_BUILD_EXAMPLES=ON
make examples
```

To run an example:
```bash
./examples/basic_usage
```

## Detecting Memory Errors

To see ASan in action, uncomment the error-inducing lines in the example files and rebuild. ASan will detect and report the memory errors with detailed information.

## For More Information

See the main project documentation for detailed usage instructions and API reference.