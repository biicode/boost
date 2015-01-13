function(BII_BOOST_PRINT_SETUP)
    message(STATUS "Boost version: ${BII_BOOST_VERSION}")
    message(STATUS "Upstream URL: ${BII_BOOST_DOWNLOAD_URL}")
    message(STATUS "Package: ${BII_BOOST_PACKAGE}")
    message(STATUS "Path to package: ${BII_BOOST_PACKAGE_PATH}")
    message(STATUS "Boost directory: ${BII_BOOST_DIR}")
    message(STATUS "Toolset: ${BII_BOOST_TOOLSET}")
    message(STATUS "Bootstrapper: ${__BII_BOOST_BOOSTRAPER}")
endfunction()

function(BII_BOOST_INSTALL_SETUP)
    #Misc
    set(__BII_BOOST_VERSION_DEFAULT 1.57.0)

    #Lets go!
    message(STATUS "Setting up biicode Boost configuration...")

    if(NOT (BII_BOOST_VERSION))
        message(STATUS "BII_BOOST_VERSION not specified. Using Boost ${__BII_BOOST_VERSION_DEFAULT}")

        set(BII_BOOST_VERSION ${__BII_BOOST_VERSION_DEFAULT} CACHE INTERNAL "Biicode boost version")
    endif()

    string(REGEX REPLACE  "[.]" "_" __BII_BOOST_VERSION_LABEL ${BII_BOOST_VERSION})

    #Download and install 
    set(BII_BOOST_INSTALL_DIR ${BIICODE_ENV_DIR}/boost/${BII_BOOST_VERSION}            CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} install directory")
    set(BII_BOOST_DIR ${BII_BOOST_INSTALL_DIR}                                         CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} base directory")
    set(__BII_BOOST_TMPDIR ${BIICODE_ENV_DIR}/tmp/boost/${BII_BOOST_VERSION}           CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} temporal directory used during install")
    set(BII_BOOST_EXTRACT_DIR ${__BII_BOOST_TMPDIR}/boost_${__BII_BOOST_VERSION_LABEL} CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} package extraction directory")

    if(NOT (EXISTS __BII_BOOST_TMPDIR))
        file(MAKE_DIRECTORY "${__BII_BOOST_TMPDIR}")
    endif()

    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__BII_BOOST_PACKAGE_TYPE zip)
    else()
        set(__BII_BOOST_PACKAGE_TYPE tar.gz)
    endif()

    set(BII_BOOST_PACKAGE boost_${__BII_BOOST_VERSION_LABEL}.${__BII_BOOST_PACKAGE_TYPE}                                     CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} package")
    set(BII_BOOST_PACKAGE_PATH ${__BII_BOOST_TMPDIR}/${BII_BOOST_PACKAGE}                                                    CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} package download destination")
    set(BII_BOOST_DOWNLOAD_URL "http://sourceforge.net/projects/boost/files/boost/${BII_BOOST_VERSION}/${BII_BOOST_PACKAGE}" CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} package upstream URL")

    #Bootstrap
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.bat CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap file")
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2.exe        CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build file")
        set(__BII_BOOST_DEFAULT_TOOLSET msvc                      CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} default build toolset")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap file")
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2           CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build file")
        set(__BII_BOOST_DEFAULT_TOOLSET clang                    CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} default build toolset")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap file")
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2           CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build file")
        set(__BII_BOOST_DEFAULT_TOOLSET gcc                      CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} default build toolset")
    else()
        message(FATAL_ERROR "Unknown platform. Stopping Boost installation")
    endif()

    if(NOT (BII_BOOST_TOOLSET))
        message(STATUS "BII_BOOST_TOOLSET not specified. Using ${__BII_BOOST_TOOLSET_DEFAULT}")

        set(BII_BOOST_TOOLSET ${__BII_BOOST_TOOLSET_DEFAULT} CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build toolset")
    endif()

    #Build
    if(NOT (BII_BOOST_BUILD_J))
        message(STATUS "BII_BOOST_BUILD_J not specified. Parallel build disabled")

        set(BII_BOOST_BUILD_J 1 CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build threads count")
    endif()


    #Print final setup
    BII_BOOST_PRINT_SETUP()
endfunction()


function(BII_BOOST_DOWNLOAD)
    if(NOT (EXISTS ${BII_BOOST_PACKAGE_PATH}))
        message(STATUS "Downloading Boost ${BII_BOOST_VERSION} from ${BII_BOOST_DOWNLOAD_URL}...") 

        file(DOWNLOAD "${BII_BOOST_DOWNLOAD_URL}" "${BII_BOOST_PACKAGE_PATH}" SHOW_PROGRESS STATUS RESULT)

        message(STATUS ${RESULT})
    else()
        message(STATUS "Download aborted. ${BII_BOOST_PACKAGE} was downloaded previously")   
    endif()


    if(NOT (EXISTS ${BII_BOOST_EXTRACT_DIR}))
        message(STATUS "Extracting Boost ${BII_BOOST_VERSION} (${BII_BOOST_PACKAGE} in ${BII_BOOST_PACKAGE_PATH})...")

        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzvf "${BII_BOOST_PACKAGE_PATH}" WORKING_DIRECTORY ${__BII_BOOST_TMPDIR})
    
        file(RENAME "${BII_BOOST_EXTRACT_DIR}" "${BII_BOOST_INSTALL_DIR}")
    endif()
endfunction()

function(BII_BOOST_BOOTSTRAP)
    message(STATUS "Bootstrapping Boost ${BII_BOOST_VERSION}...")

    if((NOT (EXISTS ${__BII_BOOST_B2})) OR (${BII_BOOST_BUILD_FORCE}))
        execute_process(COMMAND "${__BII_BOOST_BOOSTRAPER} --prefix=${BII_BOOST_DIR}" 
                        WORKING_DIRECTORY ${BII_BOOST_DIR} OUTPUT_VARIABLE OUTPUT RESULT_VARIABLE RESULT)

        message(STATUS ${OUTPUT})
        message(STATUS ${RESULT})
    else()
        message(STATUS "Boost boostrapping aborted! b2 file already exists. Set BII_BOOST_BUILD_FORCE to override")
    endif()
endfunction()

function(BII_BOOST_BUILD)
    message(STATUS "Building Boost ${BII_BOOST_VERSION} with toolset ${BII_BOOST_TOOLSET}...")

    if((NOT (EXISTS ${BII_BOOST_DIR}/stage)))
        execute_process(COMMAND "bash -c cd ${BII_BOOST_DIR} && ${__BII_BOOST_B2} --includedir=${BII_BOOST_DIR} --toolset=${BII_BOOST_TOOLSET} -j${BII_BOOST_BUILD_J} --layout=versioned --build-type=complate" 
                        WORKING_DIRECTORY ${BII_BOOST_DIR})
    else()
        message(STATUS "Boost build aborted! Build output folder (${BII_BOOST_DIR}/stage) already exists. Set BII_BOOST_BUILD_FORCE to override")
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
