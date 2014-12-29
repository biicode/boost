# This CMakeLists.txt file helps defining your block building and compiling
# Include the main biicode macros and functions
# To learn more about the CMake use with biicode, visit http://docs.biicode.com/c++/building.html
# Or check the examples below


include(${CMAKE_HOME_DIRECTORY}/biicode.cmake)
include(manu343726/oo-cmake/oo-cmake)
# Initializes block variables
INIT_BIICODE_BLOCK()

set(Boost_INCLUDE_DIRS "${BIICODE_ENV_DIR}/boost/1.57.0/sources/")
set(Boost_LIBRARY_DIRS "${BIICODE_ENV_DIR}/boost/1.57.0/sources/lib/")

# Actually create targets: EXEcutables and libraries.
ADD_BIICODE_TARGETS()

target_include_directories(${BII_LIB_TARGET} PUBLIC ${Boost_INCLUDE_DIRS})



