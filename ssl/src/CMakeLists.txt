cmake_minimum_required(VERSION 2.8)
project(BayesianRobustNMF)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_CXX_COMPILER g++)


include_directories(/opt/eigen-3.2.8 ../include /usr/include/python2.7 /usr/include/eigen3)

add_definitions("-std=c++11 -O3 -march=native -mtune=native -msse4.2")

find_package(OpenMP)
if(OPENMP_FOUND)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif()

add_executable(dsbf dsbf.cpp)
target_link_libraries(dsbf asound fftw3f sndfile)