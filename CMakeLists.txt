cmake_minimum_required(VERSION 3.10.0)
project(tontopiler)

# C++ standard 
set(CMAKE_BUILD_TYPE Release)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Source files handling
file(GLOB_RECURSE PROJECT_SOURCES "src/*.cpp")

# Flex configuration
find_package(FLEX REQUIRED)
FLEX_TARGET(Lexer lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.cc COMPILE_FLAGS "-+")

# Bison configuration
find_package(BISON REQUIRED)
BISON_TARGET(Parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.tab.cc COMPILE_FLAGS "-d")

# Ncurses configuration
find_package(Curses REQUIRED)

# Executable creation
add_executable(tontopiler 
    ${FLEX_Lexer_OUTPUTS} 
    ${BISON_Parser_OUTPUTS}
    ${PROJECT_SOURCES}
)

# Include directories
target_include_directories(tontopiler PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CURSES_INCLUDE_DIR}
)

# Linking libraries
target_link_libraries(tontopiler PRIVATE
    ${CURSES_LIBRARIES}
)