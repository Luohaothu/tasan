# TASan Project Context

## Project Overview
This project creates a standalone AddressSanitizer (ASan) library extracted from LLVM project. The goal is to create a completely independent module that can be built and used without any external LLVM dependencies.

## Current Status
- **Date**: 2025-09-02
- **Phase**: Initial setup and refactoring according to plan.md
- **Progress**: Just started - examining project structure and planning implementation

## Key Requirements from CLAUDE.md
- DO NOT MODIFY ANY FILE UNDER `llvm-project`. IT'S ONLY MEANT TO BE COPIED CODE FROM.
- AFTER EACH CODE MODIFICATION TASK, RUN CMAKE & MAKE TO CHECK FOR CORRECT COMPILING. FIX ANY ERROR IMMEDIATELY BEFORE YOU MOVE ON.
- YOU SHOULD KEEP TRACK OF YOUR PROCESS WITH A `.claude/context.md` FILE. LIST WHAT HAS BEEN DONE.
- ON EACH NEW STEP OR INVOCATION OF SUB-AGENTS, ALWAYS REFER TO THE `context.md`, THE `task-X.md` (if any), AND THE `plan.md` TO KNOW THE CONTEXT OF YOUR TASK

## Implementation Plan (from plan.md)
1. **Phase 1**: CMake infrastructure localization
2. **Phase 2**: ASan core source files copying
3. **Phase 3**: Test set copying
4. **Phase 4**: Example code creation
5. **Phase 5**: Build system adaptation
6. **Phase 6**: Testing and validation
7. **Phase 7**: Documentation and release

## Current Task Status
- [x] Read and understand plan.md
- [x] Examine current project structure
- [ ] Create .claude directory and context tracking files
- [ ] Set up TASan project directory structure
- [ ] Copy CMake infrastructure files from llvm-project
- [ ] Copy ASan source files from compiler-rt
- [ ] Copy test files from compiler-rt
- [ ] Create example files
- [ ] Configure CMakeLists.txt files
- [ ] Test build and fix compilation errors

## Important Notes
- All files must be copied from llvm-project, not modified in place
- Build must be tested after each modification
- Maintain compatibility with original LLVM build patterns
- Follow the directory structure specified in plan.md