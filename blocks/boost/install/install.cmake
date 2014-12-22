
macro(BII_BOOST)
    message("Setting up biicode boost...")

    if(${ARGC} EQUAL 0)
        set(BII_BOOST_VERSION 1.57.0)
    else()
        set(BII_BOOST_VERSION ${ARGV0}) #For the future
    endif()

    set(BOOST_ROOT       "${BIICODE_ENV_DIR}/boost/${BII_BOOST_VERSION}/sources")
    set(BOOST_INCLUDEDIR "${BOOST_ROOT}")
    set(BOOST_LIBRARYDIR "${BOOST_ROOT}/stage/lib/")

    find_package(Boost)
    if (Boost_FOUND)
        include_directories(${Boost_INCLUDE_DIR})
        add_definitions( "-DHAS_BOOST" )

        set(Boost_USE_STATIC_LIBS ON)

        message(" - BOOST_ROOT       ${BOOST_ROOT}")
        message(" - BOOST_INCLUDEDIR ${BOOST_INCLUDEDIR}")
        message(" - BOOST_LIBRARYDIR ${BOOST_LIBRARYDIR}")
    else()
        message(ERROR "Boost not found!")
    endif()
endmacro()
