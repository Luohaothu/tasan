# TASan - 独立式地址消毒器库

[![构建状态](https://img.shields.io/badge/构建-通过-brightgreen)](https://github.com/Luohaothu/tasan)
[![许可证](https://img.shields.io/badge/许可证-Apache%202.0-blue)](https://github.com/Luohaothu/tasan/blob/main/LICENSE)
[![C++](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/)
[![CMake](https://img.shields.io/badge/CMake-3.20%2B-blue.svg)](https://cmake.org/)

**TASan** 是一个完全独立的地址消毒器（ASan）运行时库，从LLVM项目中提取而来。它提供了最先进的内存错误检测功能，无需任何外部LLVM依赖，使其易于集成到任何C/C++项目中。

## 🌟 特性

### 🛡️ 内存错误检测
- **堆缓冲区溢出**：检测堆分配内存的溢出和下溢
- **栈缓冲区溢出**：捕获基于栈的缓冲区溢出
- **释放后使用**：识别对已释放内存的访问
- **全局变量溢出**：检测全局变量的溢出
- **双重释放**：捕获同一内存的多次释放
- **无效释放**：检测释放无效指针的尝试

### 🔧 技术能力
- **影子内存**：使用1:8的影子映射进行高效的内存错误检测
- **函数拦截**：跨平台函数包装，提供全面的覆盖
- **线程安全**：完全支持多线程应用程序
- **跨平台**：支持Linux、macOS、Windows、Android、Fuchsia和AIX
- **多架构**：兼容x86_64、i386、AArch64、ARM、MIPS、RISC-V

### 📦 独立设计
- **无LLVM依赖**：完全独立的构建系统
- **本地化CMake**：包含所有必需的CMake基础设施
- **易于集成**：简单添加到现有项目中
- **灵活链接**：支持静态和动态链接

## 🚀 快速开始

### 前置要求

- **CMake**：3.20.0或更高版本
- **C++编译器**：支持C++17的Clang、GCC或MSVC
- **构建工具**：Make或Ninja
- **系统库**：标准C库和pthread支持

### 构建库

```bash
# 克隆仓库
git clone https://github.com/Luohaothu/tasan.git
cd tasan

# 创建构建目录
mkdir build && cd build

# 使用CMake配置
cmake .. -DCMAKE_BUILD_TYPE=Release

# 构建所有目标
make -j$(nproc)

# 构建特定库
make clang_rt.asan
```

### 在项目中使用TASan

#### 方法1：使用编译器标志（推荐）

```bash
# 使用TASan运行时编译（推荐）
g++ -fsanitize=address -o your_program your_source.cpp

# 这会自动链接TASan并启用检测
```

#### 方法2：手动链接

```bash
# 编译源文件
g++ -c your_source.cpp -o your_source.o

# 链接TASan库
g++ your_source.o -o your_program -L/path/to/tasan/lib -lclang_rt.asan-x86_64
```

#### 方法3：CMake集成

```cmake
cmake_minimum_required(VERSION 3.20)
project(YourProject)

# 添加TASan库
add_subdirectory(path/to/tasan)

# 将目标与TASan链接
add_executable(your_program your_source.cpp)
target_link_libraries(your_program clang_rt.asan-x86_64)
```

## 📚 示例

项目包含几个示例程序来展示TASan的功能：

### 基本使用示例
```cpp
#include <iostream>
#include <cstdlib>

int main() {
    // 基本堆分配
    int* array = new int[10];
    
    // 初始化数组
    for (int i = 0; i < 10; ++i) {
        array[i] = i;
    }
    
    // 使用数组
    std::cout << "数组值: ";
    for (int i = 0; i < 10; ++i) {
        std::cout << array[i] << " ";
    }
    std::cout << std::endl;
    
    // 正确释放
    delete[] array;
    
    std::cout << "基本ASan示例成功完成！" << std::endl;
    return 0;
}
```

### 堆溢出检测
```cpp
#include <iostream>
#include <cstdlib>

int main() {
    // 分配大小为10的数组
    int* array = new int[10];
    
    // 在边界内初始化数组
    for (int i = 0; i < 10; ++i) {
        array[i] = i;
    }
    
    std::cout << "数组已初始化，值为0-9" << std::endl;
    
    // 这会导致堆溢出错误 - 正常运行时注释掉
    // array[10] = 42;  // 缓冲区溢出
    
    // 这会导致堆下溢错误 - 正常运行时注释掉
    // array[-1] = 42;  // 缓冲区下溢
    
    // 正确清理
    delete[] array;
    
    std::cout << "堆溢出检测示例完成！" << std::endl;
    std::cout << "取消注释溢出/下溢行以查看ASan的实际效果。" << std::endl;
    
    return 0;
}
```

### 释放后使用检测
```cpp
#include <iostream>
#include <cstdlib>

int main() {
    // 分配并初始化变量
    int* ptr = new int;
    *ptr = 42;
    std::cout << "值: " << *ptr << std::endl;
    
    // 释放内存
    delete ptr;
    std::cout << "内存已释放" << std::endl;
    
    // 这会导致释放后使用错误 - 正常运行时注释掉
    // std::cout << "释放后的值: " << *ptr << std::endl;  // 释放后使用
    
    std::cout << "释放后使用检测示例完成！" << std::endl;
    std::cout << "取消注释释放后使用行以查看ASan的实际效果。" << std::endl;
    
    return 0;
}
```

## 🔧 构建配置

### CMake选项

```bash
# 基本配置
cmake .. -DCMAKE_BUILD_TYPE=Release

# 启用测试
cmake .. -DCMAKE_BUILD_TYPE=Release -DTASAN_BUILD_TESTS=ON

# 仅构建示例
cmake .. -DCMAKE_BUILD_TYPE=Release -DTASAN_BUILD_EXAMPLES=ON

# 自定义安装前缀
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local

# 调试构建与测试
cmake .. -DCMAKE_BUILD_TYPE=Debug -DTASAN_BUILD_TESTS=ON -DTASAN_BUILD_EXAMPLES=ON
```

### 构建目标

```bash
# 构建所有库和示例
make all

# 构建特定运行时库
make clang_rt.asan              # 主要ASan运行时
make clang_rt.asan_static       # 静态版本
make clang_rt.asan_cxx          # C++组件
make clang_rt.asan-preinit      # 预初始化组件

# 构建组件库
make RTSanitizerCommon          # 共享消毒器工具
make RTInterception             # 函数拦截模块
make RTSanitizerCommonSymbolizer # 符号化工具

# 构建示例
make examples
make basic_usage_example        # 特定示例

# 运行测试（如果启用）
make check-asan

# 安装库
make install
```

## 📁 项目结构

```
tasan/
├── CMakeLists.txt              # 主项目配置
├── README.md                   # 英文文档
├── README_CN.md                # 中文文档
├── CLAUDE.md                   # 开发指南
├── .gitignore                  # Git忽略规则
├── cmake/                      # 本地化LLVM CMake基础设施
│   ├── Modules/               # CMake模块
│   └── caches/                # 构建缓存配置
├── src/                        # 源代码
│   ├── asan/                  # ASan核心实现
│   ├── lsan/                  # LeakSanitizer组件
│   ├── ubsan/                 # UndefinedBehaviorSanitizer组件
│   ├── sanitizer_common/      # 共享消毒器工具
│   └── interception/          # 函数拦截模块
├── include/sanitizer/         # 公共头文件
├── tests/                     # 测试用例（453个来自LLVM）
├── examples/                  # 示例程序
├── scripts/                   # 构建和比较脚本
├── docs/                      # 文档
├── claude-dialog/             # 开发对话日志
├── .claude/                   # Claude Code上下文
└── llvm-project/              # LLVM源代码（参考）
```

## 🧪 测试

项目包含来自LLVM项目的453个测试用例，确保全面覆盖：

```bash
# 运行所有测试
make check-asan

# 运行特定测试类别
cd build && lit tests/TestCases/heap_overflow.cpp
cd build && lit tests/TestCases/Linux/
cd build && lit tests/TestCases/Darwin/

# 运行平台特定测试
cd build && lit tests/TestCases/Android/
cd build && lit tests/TestCases/Windows/

# 运行特定测试文件
cd build && lit tests/TestCases/use_after_free.cpp
```

### 测试类别

- **堆内存测试**：堆缓冲区溢出/下溢检测
- **栈内存测试**：基于栈的缓冲区溢出检测
- **释放后使用测试**：释放后使用检测
- **全局变量测试**：全局变量溢出检测
- **线程安全测试**：多线程应用程序测试
- **平台特定测试**：操作系统特定功能测试

## 🔍 高级配置

### 自定义构建设置

```cmake
# 在你的CMakeLists.txt中
set(TASAN_SUPPORTED_ARCH x86_64)  # 限制到特定架构
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
```

### 环境变量

```bash
# ASan运行时选项
export ASAN_OPTIONS=detect_stack_use_after_return=1
export ASAN_OPTIONS=abort_on_error=1
export ASAN_OPTIONS=verbosity=1
```

### 构建系统集成

#### Makefile集成
```makefile
CXX = g++
CXXFLAGS = -fsanitize=address -g
LDFLAGS = -fsanitize=address

your_program: your_source.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^
```

#### Autotools集成
```configure.ac
AX_CHECK_COMPILE_FLAG([-fsanitize=address], [CXXFLAGS="$CXXFLAGS -fsanitize=address"])
AX_CHECK_LINK_FLAG([-fsanitize=address], [LDFLAGS="$LDFLAGS -fsanitize=address"])
```

## 🐛 故障排除

### 常见问题

1. **构建错误**
   ```bash
   # 确保CMake版本为3.20或更高
   cmake --version
   
   # 清理构建目录
   rm -rf build && mkdir build && cd build
   ```

2. **链接错误**
   ```bash
   # 检查库路径
   ls -la lib/
   
   # 验证库是否存在
   find . -name "libclang_rt.asan*"
   ```

3. **运行时错误**
   ```bash
   # 检查ASan环境
   env | grep ASAN
   
   # 启用详细输出
   export ASAN_OPTIONS=verbosity=1
   ```

### 获取帮助

- **文档**：查看[CLAUDE.md](CLAUDE.md)文件获取开发指南
- **问题**：在[GitHub Issues](https://github.com/Luohaothu/tasan/issues)上报告错误
- **讨论**：加入我们的[GitHub Discussions](https://github.com/Luohaothu/tasan/discussions)
- **示例**：查看`examples/`目录获取实际使用示例

## 🤝 贡献

我们欢迎贡献！请查看我们的贡献指南：

1. Fork仓库
2. 创建功能分支（`git checkout -b feature/amazing-feature`）
3. 提交更改（`git commit -m 'Add amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 打开Pull Request

### 开发设置

```bash
# 克隆开发依赖
git clone --recurse-submodules https://github.com/Luohaothu/tasan.git

# 设置开发环境
cd tasan
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DTASAN_BUILD_TESTS=ON
make -j$(nproc)
make check-asan
```

## 📄 许可证

本项目根据Apache许可证2.0授权 - 详情请查看[LICENSE](LICENSE)文件。

## 🙏 致谢

- **LLVM项目**：TASan基于LLVM的地址消毒器运行时
- **Compiler-RT团队**：感谢原始实现和持续维护
- **贡献者**：所有多年来帮助改进ASan的开发者

## 📈 性能

TASan提供内存错误检测，具有合理的性能开销：

- **减速**：与本地执行相比通常有2x-4x的减速
- **内存开销**：由于影子内存，内存使用量大约增加3倍
- **检测率**：以低误报率捕获大多数常见内存错误

### 优化技巧

```bash
# 使用选项减少开销
export ASAN_OPTIONS=quarantine_size_mb=16
export ASAN_OPTIONS=malloc_context_size=2

# 在生产中小心使用
export ASAN_OPTIONS=handle_segv=0
```

## 🗺️ 路线图

- [ ] **性能优化**：减少运行时开销
- [ ] **额外平台**：添加对更多嵌入式系统的支持
- [ ] **增强文档**：更多示例和教程
- [ ] **集成工具**：流行构建系统的简易集成脚本
- [ ] **GUI工具**：可视化内存错误分析工具

---

**使用现代CMake和LLVM技术构建 ❤️**

更多信息，请访问我们的[GitHub仓库](https://github.com/Luohaothu/tasan)或加入我们的社区讨论。

## 🌐 语言版本

- [English](README.md) | [中文](README_CN.md)