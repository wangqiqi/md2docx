cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(MSVC)
  add_compile_options(/W4 /permissive-)
else()
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_library(app_core src/greet.cpp)
target_include_directories(app_core PUBLIC include)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE app_core)

enable_testing()

add_executable(app_tests tests/greet_test.cpp)
target_link_libraries(app_tests PRIVATE app_core GTest::gtest_main)
target_include_directories(app_tests PRIVATE include)

include(GoogleTest)
gtest_discover_tests(app_tests)
