cmake_minimum_required(VERSION 3.12)
project(cpp_project)

# Set C++ standard to C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add executable
add_executable(${PROJECT_NAME} main.cpp)
