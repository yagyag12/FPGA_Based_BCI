cmake_minimum_required(VERSION 3.30)
project(svm C)

set(CMAKE_C_STANDARD 99)

add_executable(svm main.c
        param.h
        inputs_data.h)
