# Examples CMakeLists.txt
set(EXAMPLE_SOURCES
  basic_usage.cpp
  heap_overflow_detection.cpp
  use_after_free_detection.cpp
)

# Create example executables
foreach(source ${EXAMPLE_SOURCES})
  get_filename_component(target_name ${source} NAME_WE)
  add_executable(${target_name} ${source})
  target_link_libraries(${target_name} clang_rt.asan-x86_64)
  set_target_properties(${target_name} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/examples
  )
endforeach()

# Install examples
foreach(source ${EXAMPLE_SOURCES})
  get_filename_component(target_name ${source} NAME_WE)
  install(TARGETS ${target_name}
    RUNTIME DESTINATION bin/examples
  )
endforeach()