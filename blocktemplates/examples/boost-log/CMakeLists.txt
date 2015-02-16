INIT_BIICODE_BLOCK()

include(biicode/boost/setup)

ADD_BIICODE_TARGETS()

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)

bii_setup_boost(COMPONENTS system thread filesystem log REQUIRED)
find_package(Boost COMPONENTS system thread filesystem date_time log log_setup REQUIRED)
find_package(Threads)

target_include_directories(${BII_BLOCK_TARGET} INTERFACE ${Boost_INCLUDE_DIRS})
target_link_libraries(${BII_BLOCK_TARGET} INTERFACE  ${CMAKE_THREAD_LIBS_INIT} ${Boost_LIBRARIES})
