cmake_minimum_required(VERSION 3.16)
project(ldlidar_ros2)

# Default to C99
if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif()

# Default to C++17
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 17)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic -O3)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # uncomment the line when a copyright and license is not present in all source files
  #set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # uncomment the line when this package is not in a git repo
  #set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

# user add
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/sdk/include/
)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/sdk)


# Create executable for ldlidar_ros2_node
add_executable(${PROJECT_NAME}_node
  ${CMAKE_CURRENT_SOURCE_DIR}/src/demo.cpp
)

# Modern CMake: Link dependencies directly
target_link_libraries(${PROJECT_NAME}_node PUBLIC
  rclcpp::rclcpp
  sensor_msgs::sensor_msgs_library
  geometry_msgs::geometry_msgs_library
  pthread
  ldlidar_driver
)

# Install 
install(TARGETS ${PROJECT_NAME}_node
 DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY launch rviz2 scripts
  DESTINATION share/${PROJECT_NAME}/
)


ament_package()

