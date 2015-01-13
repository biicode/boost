function(BII_BOOST_INSTALL_SETUP)
    #Tools
    string(REGEX REPLACE  "\." "_" __BII_BOOST_VERSION_LABEL ${BII_BOOST_VERSION})

    #Download and install 
    set(BII_BOOST_INSTALL_DIR ${BIICODE_ENV_DIR}/boost/${BII_BOOST_VERSION})
    set(BII_BOOST_DIR ${BII_BOOST_INSTALL_DIR})
    set(BII_BOOST_EXTRACT_DIR ${BIICODE_ENV_DIR}/tmp/boost/${BII_BOOST_VERSION}/sources)

    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__BII_BOOST_PACKAGE_TYPE zip)
    else()
        set(__BII_BOOST_PACKAGE_TYPE tar)
    endif()

    set(BII_BOOST_PACKAGE boost_${__BII_BOOST_VERSION_LABEL}.${__BII_BOOST_PACKAGE_TYPE})
    set(BII_BOOST_PACKAGE_PATH ${BII_BOOST_INSTALL_DIR}/${BII_BOOST_PACKAGE})

    set(BII_BOOST_DOWNLOAD_URL "http://sourceforge.net/projects/boost/files/boost/${BII_BOOST_VERSION}/${BII_BOOST_PACKAGE}")

    #Bootstrap
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.bat)
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2.exe)
        set(__BII_BOOST_DEFAULT_TOOLSET msvc)
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh)
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2)
        set(__BII_BOOST_DEFAULT_TOOLSET clang)
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh)
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2)
        set(__BII_BOOST_DEFAULT_TOOLSET gcc)
    else()
        message(FATAL_ERROR "Unknown platform. Stopping Boost installation")
    endif()
endfunction()


function(BII_BOOST_DOWNLOAD)
    if(NOT (EXISTS ${BII_BOOST_PACKAGE_PATH}))
        message(INFO "Downloading Boost ${BII_BOOST_VERSION}...") 

        file(DOWNLOAD ${BII_BOOST_DOWNLOAD_URL} ${BII_BOOST_INSTALL_DIR}/${BII_BOOST_PACKAGE} SHOW_PROGRESS)
    endif()

    if(NOT (EXISTS ${BII_BOOST_DIR}))
        message(STATUS "Extracting Boost ${BII_BOOST_VERSION}...")

        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${BII_BOOST_PACKAGE_PATH} ${BII_BOOST_EXTRACT_DIR})
    
        file(RENAME ${BII_BOOST_EXTRACT_DIR} ${BII_BOOST_INSTALL_DIR})
    endif()
endfunction()

function(BII_BOOST_BOOTSTRAP)
    message(STATUS "Bootstrapping Boost ${BII_BOOST_VERSION}...")

    if((NOT (EXISTS ${__BII_BOOST_B2})) OR (${BII_BOOST_BUILD_FORCE}))
        execute_process(COMMAND "${__BII_BOOST_BOOSTRAPER} --prefix=${BII_BOOST_DIR}" 
                        WORKING_DIRECTORY ${BII_BOOST_DIR})
    else()
        message(WARNING "Boost boostrapping aborted! b2 file already exists. Set BII_BOOST_BUILD_FORCE to override")
    endif()
endfunction()

function(BII_BOOST_BUILD)
    message(STATUS "Building Boost ${BII_BOOST_VERSION} with toolset ${BII_BOOST_TOOLSET}...")

    if((NOT (EXISTS ${BII_BOOST_DIR}/stage)))
        execute_process(COMMAND "${__BII_BOOST_B2} --includedir=${BII_BOOST_DIR} --toolset=${BII_BOOST_TOOLSET} -j${BII_BOOST_BUILD_J} --layout=versioned --build-type=complate" 
                        WORKING_DIRECTORY ${BII_BOOST_DIR})
    else()
        message(WARNING "Boost build aborted! Build output folder (${BII_BOOST_DIR}/stage) already exists. Set BII_BOOST_BUILD_FORCE to override")
    endif()
endfunction()

function(BII_BOOST_INSTALL)
    BII_BOOST_INSTALL_SETUP()
    BII_BOOST_DOWNLOAD()
    BII_BOOST_BOOTSTRAP()
    BII_BOOST_BUILD()
endfunction()

macro(BII_BOOST)
    message("Setting up biicode boost...")

    if(${ARGC} EQUAL 0)
        set(BII_BOOST_VERSION 1.57.0)
    else()
        set(BII_BOOST_VERSION ${ARGV0}) #For the future
    endif()

    set(BOOST_ROOT       "${BII_BOOST_DIR}")
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
        message(FATAL_ERROR "Boost not found!")
    endif()
endmacro()
