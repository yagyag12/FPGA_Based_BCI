cmake_minimum_required(VERSION 3.30)
project(decisionTreeImp C)

set(CMAKE_C_STANDARD 11)

add_executable(decisionTreeImp main.c
        treeSplits.h)
