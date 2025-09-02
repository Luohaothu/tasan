# Include directory CMakeLists.txt
# Install public headers
install(DIRECTORY sanitizer/
  DESTINATION include/sanitizer
  FILES_MATCHING
  PATTERN "*.h"
  PATTERN "*.inc"
)