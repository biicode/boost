
macro(BII_BOOST)
    message("Setting up biicode boost...")

    if(${ARGC} EQUAL 0)
        set(BII_BOOST_VERSION 1.57.0)
    else()
        set(BII_BOOST_VERSION ${ARGV0}) #For the future
    endif()

    set(BOOST_ROOT       "${BIICODE_ENV_DIR}/boost/${BII_BOOST_VERSION}/")
    set(BOOST_INCLUDEDIR "${BOOST_ROOT}sources/")
    set(BOOST_LIBRARYDIR "${BOOST_ROOT}sources/stage/lib/")

    message(" - BOOST_ROOT       ${BOOST_ROOT}")
    message(" - BOOST_INCLUDEDIR ${BOOST_INCLUDEDIR}")
    message(" - BOOST_LIBRARYDIR ${BOOST_LIBRARYDIR}")

    include_directories(${BOOST_INCLUDEDIR})
endmacro()
