cmake_minimum_required(VERSION 3.22.1)
project(adpcm)

add_library(adpcm SHARED adpcm.cpp)

# Link required libraries
target_link_libraries(adpcm log)
