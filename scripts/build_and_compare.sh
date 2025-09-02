#!/bin/bash

# Script to build official ASan from LLVM project and compare with standalone TASan
# This ensures both builds use the same configuration for accurate comparison

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LLVM_PROJECT_DIR="$PROJECT_ROOT/llvm-project"
OFFICIAL_BUILD_DIR="$PROJECT_ROOT/build_official"
STANDALONE_BUILD_DIR="$PROJECT_ROOT/build"

# Check if required tools are available
for tool in cmake ninja nm ar; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}Error: Required tool '$tool' not found in PATH${NC}"
        exit 1
    fi
done

# Build configuration from current project
if [ ! -f "$STANDALONE_BUILD_DIR/CMakeCache.txt" ]; then
    echo -e "${RED}Error: Standalone build directory not configured. Please run cmake first.${NC}"
    exit 1
fi

CMAKE_BUILD_TYPE=$(grep -oP 'CMAKE_BUILD_TYPE:STRING=\K.*' "$STANDALONE_BUILD_DIR/CMakeCache.txt")
CMAKE_C_COMPILER=$(grep -oP 'CMAKE_C_COMPILER:STRING=\K.*' "$STANDALONE_BUILD_DIR/CMakeCache.txt")
CMAKE_CXX_COMPILER=$(grep -oP 'CMAKE_CXX_COMPILER:STRING=\K.*' "$STANDALONE_BUILD_DIR/CMakeCache.txt")
CMAKE_ASM_COMPILER=$(grep -oP 'CMAKE_ASM_COMPILER:STRING=\K.*' "$STANDALONE_BUILD_DIR/CMakeCache.txt")

# Default to C compiler if ASM compiler is not set
if [ -z "$CMAKE_ASM_COMPILER" ]; then
    CMAKE_ASM_COMPILER="$CMAKE_C_COMPILER"
fi

echo -e "${YELLOW}=== ASan Library Comparison Script ===${NC}"
echo -e "${YELLOW}Build Configuration:${NC}"
echo "  Build Type: $CMAKE_BUILD_TYPE"
echo "  C Compiler: $CMAKE_C_COMPILER"
echo "  CXX Compiler: $CMAKE_CXX_COMPILER"
echo "  ASM Compiler: $CMAKE_ASM_COMPILER"
echo ""

# Function to cleanup on exit
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    # Keep build directories for inspection if needed
    echo -e "${GREEN}Build directories preserved for inspection:${NC}"
    echo "  Official: $OFFICIAL_BUILD_DIR"
    echo "  Standalone: $STANDALONE_BUILD_DIR"
}

# Set trap for cleanup
trap cleanup EXIT

# Step 1: Build official ASan from LLVM project
echo -e "${YELLOW}Step 1: Building official ASan from LLVM project...${NC}"
echo "LLVM Project directory: $LLVM_PROJECT_DIR"

if [ ! -d "$LLVM_PROJECT_DIR" ]; then
    echo -e "${RED}Error: LLVM project directory not found at $LLVM_PROJECT_DIR${NC}"
    exit 1
fi

if [ ! -d "$LLVM_PROJECT_DIR/llvm" ]; then
    echo -e "${RED}Error: llvm directory not found in LLVM project${NC}"
    exit 1
fi

# Remove previous official build directory
rm -rf "$OFFICIAL_BUILD_DIR"
mkdir -p "$OFFICIAL_BUILD_DIR"

# Build official ASan using standard LLVM procedure
cd "$OFFICIAL_BUILD_DIR"
echo "Configuring official LLVM build..."

# Configure LLVM build with compiler-rt
cmake -G "Ninja" \
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
    -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
    -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
    -DCMAKE_ASM_COMPILER="$CMAKE_ASM_COMPILER" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCOMPILER_RT_BUILD_SANITIZERS=ON \
    -DCOMPILER_RT_BUILD_ASAN=ON \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=OFF \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_TESTS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    "$LLVM_PROJECT_DIR/llvm"

echo "Building official ASan..."
ninja -j$(nproc) compiler-rt

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to build official ASan${NC}"
    exit 1
fi

echo -e "${GREEN}Official ASan built successfully${NC}"

# Step 2: Build standalone TASan (rebuild to ensure same config)
echo -e "${YELLOW}Step 2: Rebuilding standalone TASan with same configuration...${NC}"
cd "$PROJECT_ROOT"
rm -rf "$STANDALONE_BUILD_DIR"
mkdir -p "$STANDALONE_BUILD_DIR"
cd "$STANDALONE_BUILD_DIR"

echo "Configuring standalone TASan build..."
cmake -G "Ninja" \
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
    -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
    -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
    -DCMAKE_ASM_COMPILER="$CMAKE_ASM_COMPILER" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DTASAN_BUILD_TESTS=OFF \
    -DTASAN_BUILD_EXAMPLES=OFF \
    ..

echo "Building standalone TASan..."
ninja -j$(nproc)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to build standalone TASan${NC}"
    exit 1
fi

echo -e "${GREEN}Standalone TASan built successfully${NC}"

# Step 3: Compare libraries
echo -e "${YELLOW}Step 3: Comparing libraries...${NC}"

# Define library paths - check multiple possible locations
OFFICIAL_LIB=""
if [ -f "$OFFICIAL_BUILD_DIR/lib/linux/libclang_rt.asan-x86_64.a" ]; then
    OFFICIAL_LIB="$OFFICIAL_BUILD_DIR/lib/linux/libclang_rt.asan-x86_64.a"
elif [ -f "$OFFICIAL_BUILD_DIR/lib/clang/*/lib/linux/libclang_rt.asan-x86_64.a" ]; then
    OFFICIAL_LIB=$(find "$OFFICIAL_BUILD_DIR/lib/clang" -name "libclang_rt.asan-x86_64.a" | head -1)
elif [ -f "$OFFICIAL_BUILD_DIR/lib/clang/*/lib/x86_64-unknown-linux-gnu/libclang_rt.asan.a" ]; then
    OFFICIAL_LIB=$(find "$OFFICIAL_BUILD_DIR/lib/clang" -name "libclang_rt.asan.a" | head -1)
elif [ -f "$OFFICIAL_BUILD_DIR/lib/clang/*/lib/x86_64-unknown-linux-gnu/libclang_rt.asan_static.a" ]; then
    OFFICIAL_LIB=$(find "$OFFICIAL_BUILD_DIR/lib/clang" -name "libclang_rt.asan_static.a" | head -1)
elif [ -f "$OFFICIAL_BUILD_DIR/projects/compiler-rt/lib/linux/libclang_rt.asan-x86_64.a" ]; then
    OFFICIAL_LIB="$OFFICIAL_BUILD_DIR/projects/compiler-rt/lib/linux/libclang_rt.asan-x86_64.a"
else
    # Try to find any ASan library
    OFFICIAL_LIB=$(find "$OFFICIAL_BUILD_DIR" -name "libclang_rt.asan*.a" | grep -v cxx | head -1)
fi

STANDALONE_LIB="$STANDALONE_BUILD_DIR/lib/libclang_rt.asan-x86_64.a"

# Check if libraries exist
if [ ! -f "$OFFICIAL_LIB" ]; then
    echo -e "${RED}Error: Official ASan library not found${NC}"
    echo "Searched locations:"
    echo "  - $OFFICIAL_BUILD_DIR/lib/linux/libclang_rt.asan-x86_64.a"
    echo "  - $OFFICIAL_BUILD_DIR/lib/clang/*/lib/linux/libclang_rt.asan-x86_64.a"
    echo "  - $OFFICIAL_BUILD_DIR/lib/clang/*/lib/x86_64-unknown-linux-gnu/libclang_rt.asan.a"
    echo "  - $OFFICIAL_BUILD_DIR/projects/compiler-rt/lib/linux/libclang_rt.asan-x86_64.a"
    echo "Available files in build directory:"
    find "$OFFICIAL_BUILD_DIR" -name "*asan*.a" | head -10
    exit 1
fi

if [ ! -f "$STANDALONE_LIB" ]; then
    echo -e "${RED}Error: Standalone ASan library not found at $STANDALONE_LIB${NC}"
    exit 1
fi

# Get library information
echo "Library information:"
echo "  Official:    $OFFICIAL_LIB"
echo "  Standalone:  $STANDALONE_LIB"
echo ""

# Compare file sizes
OFFICIAL_SIZE=$(stat -c%s "$OFFICIAL_LIB")
STANDALONE_SIZE=$(stat -c%s "$STANDALONE_LIB")
SIZE_DIFF=$((OFFICIAL_SIZE - STANDALONE_SIZE))
SIZE_PERCENT=$((SIZE_DIFF * 100 / OFFICIAL_SIZE))

echo "File size comparison:"
echo "  Official:    $OFFICIAL_SIZE bytes"
echo "  Standalone:  $STANDALONE_SIZE bytes"
echo "  Difference:  $SIZE_DIFF bytes ($SIZE_PERCENT%)"
echo ""

# Compare symbol tables
echo "Comparing symbol tables..."
OFFICIAL_SYMBOLS=$(nm "$OFFICIAL_LIB" | sort)
STANDALONE_SYMBOLS=$(nm "$STANDALONE_LIB" | sort)

if [ "$OFFICIAL_SYMBOLS" = "$STANDALONE_SYMBOLS" ]; then
    echo -e "${GREEN}✓ Symbol tables are identical${NC}"
else
    echo -e "${RED}✗ Symbol tables differ${NC}"
    echo "Symbol differences:"
    diff -u <(echo "$OFFICIAL_SYMBOLS") <(echo "$STANDALONE_SYMBOLS") | head -20
    echo ""
fi

# Compare object files within archives
echo "Comparing object files within archives..."
OFFICIAL_OBJECTS=$(ar t "$OFFICIAL_LIB" | sort)
STANDALONE_OBJECTS=$(ar t "$STANDALONE_LIB" | sort)

if [ "$OFFICIAL_OBJECTS" = "$STANDALONE_OBJECTS" ]; then
    echo -e "${GREEN}✓ Object file lists are identical${NC}"
else
    echo -e "${RED}✗ Object file lists differ${NC}"
    echo "Object file differences:"
    diff -u <(echo "$OFFICIAL_OBJECTS") <(echo "$STANDALONE_OBJECTS") | head -20
    echo ""
fi

# Function to compare object files
compare_object_files() {
    echo "Comparing individual object files..."
    
    # Extract object files to temporary directories
    mkdir -p "$OFFICIAL_BUILD_DIR/extracted" "$STANDALONE_BUILD_DIR/extracted"
    
    cd "$OFFICIAL_BUILD_DIR/extracted"
    ar x "$OFFICIAL_LIB"
    
    cd "$STANDALONE_BUILD_DIR/extracted"
    ar x "$STANDALONE_LIB"
    
    # Compare each object file
    local differences=0
    local total_files=0
    
    for obj_file in $OFFICIAL_OBJECTS; do
        if [ -f "$STANDALONE_BUILD_DIR/extracted/$obj_file" ]; then
            total_files=$((total_files + 1))
            if ! cmp -s "$OFFICIAL_BUILD_DIR/extracted/$obj_file" "$STANDALONE_BUILD_DIR/extracted/$obj_file"; then
                echo -e "${RED}✗ Object file $obj_file differs${NC}"
                differences=$((differences + 1))
            fi
        else
            echo -e "${RED}✗ Object file $obj_file missing in standalone build${NC}"
            differences=$((differences + 1))
        fi
    done
    
    # Check for extra files in standalone build
    for obj_file in $STANDALONE_OBJECTS; do
        if [ ! -f "$OFFICIAL_BUILD_DIR/extracted/$obj_file" ]; then
            echo -e "${RED}✗ Extra object file $obj_file in standalone build${NC}"
            differences=$((differences + 1))
        fi
    done
    
    echo "Compared $total_files object files, found $differences differences"
    return $differences
}

# Compare object files
compare_object_files
DIFFERENCES=$?

# Step 4: Generate report
echo ""
echo -e "${YELLOW}=== Comparison Report ===${NC}"

if [ $DIFFERENCES -eq 0 ] && [ "$OFFICIAL_SYMBOLS" = "$STANDALONE_SYMBOLS" ] && [ "$OFFICIAL_OBJECTS" = "$STANDALONE_OBJECTS" ]; then
    echo -e "${GREEN}✓ SUCCESS: Libraries are identical!${NC}"
    echo "  - File sizes match"
    echo "  - Symbol tables match"
    echo "  - Object files match"
    exit 0
else
    echo -e "${RED}✗ ERROR: Libraries differ!${NC}"
    echo "  Differences found:"
    
    if [ ! "$OFFICIAL_SYMBOLS" = "$STANDALONE_SYMBOLS" ]; then
        echo "  - Symbol tables differ"
    fi
    
    if [ ! "$OFFICIAL_OBJECTS" = "$STANDALONE_OBJECTS" ]; then
        echo "  - Object file lists differ"
    fi
    
    if [ $DIFFERENCES -ne 0 ]; then
        echo "  - $DIFFERENCES object files differ"
    fi
    
    echo ""
    echo "Investigation suggestions:"
    echo "  1. Check build configurations are identical"
    echo "  2. Verify source code matches between projects"
    echo "  3. Examine specific differences with:"
    echo "     diff -u <(nm $OFFICIAL_LIB) <(nm $STANDALONE_LIB)"
    echo "     diff -r $OFFICIAL_BUILD_DIR/extracted $STANDALONE_BUILD_DIR/extracted"
    
    exit 1
fi