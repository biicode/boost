include(boost/install/utils)


function(BII_BOOST_PRINT_SETUP)
    message(STATUS "Boost version: ${BII_BOOST_VERSION}")
    message(STATUS "Libraries: ${BII_BOOST_LIBS}")
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

    if(NOT (EXISTS ${BIICODE_ENV_DIR}/boost/))
        file(MAKE_DIRECTORY "${BIICODE_ENV_DIR}/boost/")
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
    elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap file")
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2           CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build file")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(__BII_BOOST_BOOSTRAPER ${BII_BOOST_DIR}/bootstrap.sh CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap file")
        set(__BII_BOOST_B2         ${BII_BOOST_DIR}/b2           CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build file")
    else()
        message(FATAL_ERROR "Unknown platform. Stopping Boost installation")
    endif()

    if(NOT (BII_BOOST_TOOLSET))
        message(STATUS "BII_BOOST_TOOLSET not specified. Using ${CMAKE_CXX_COMPILER_ID} compiler")

        BII_BOOST_COMPUTE_TOOLSET(__BII_BOOST_DEFAULT_TOOLSET)

        set(BII_BOOST_TOOLSET ${__BII_BOOST_DEFAULT_TOOLSET} CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build toolset")
    endif()

    if(NOT (BII_BOOST_VARIANT))
        if(NOT CMAKE_BUILD_TYPE)
            set(CMAKE_BUILD_TYPE Release)
        endif()

        message(STATUS "BII_BOOST_VARIANT not specified. Using ${CMAKE_BUILD_TYPE} variant")

        string(TOLOWER ${CMAKE_BUILD_TYPE} BII_BOOST_VARIANT)
    endif()

    #Build
    if(NOT (BII_BOOST_BUILD_J))
        message(STATUS "BII_BOOST_BUILD_J not specified. Parallel build disabled")

        set(BII_BOOST_BUILD_J 1 CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} build threads count")
    endif()

    set(__BII_BOOST_BOOTSTRAP_CALL "${__BII_BOOST_BOOSTRAPER} --prefix=${BII_BOOST_DIR}"
                                   CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} boostrap call")

    set(__BII_BOOST_B2_CALL        ${__BII_BOOST_B2} --includedir=${BII_BOOST_DIR} 
                                                     --toolset=${BII_BOOST_TOOLSET} 
                                                     -j${BII_BOOST_BUILD_J} 
                                                     --layout=versioned 
                                                     --build-type=complete
                                   CACHE INTERNAL "Biicode boost ${BII_BOOST_VERSION} b2 call")
endfunction()


function(BII_BOOST_DOWNLOAD)
    if(NOT (EXISTS ${BII_BOOST_PACKAGE_PATH}))
        message(STATUS "Downloading Boost ${BII_BOOST_VERSION} from ${BII_BOOST_DOWNLOAD_URL}...") 

        file(DOWNLOAD "${BII_BOOST_DOWNLOAD_URL}" "${BII_BOOST_PACKAGE_PATH}" SHOW_PROGRESS STATUS RESULT)

        message(STATUS ${RESULT})
    else()
        message(STATUS "Download aborted. ${BII_BOOST_PACKAGE} was downloaded previously")   
    endif()


    if(NOT (EXISTS ${BII_BOOST_DIR}))
        message(STATUS "Extracting Boost ${BII_BOOST_VERSION} (${BII_BOOST_PACKAGE} in ${BII_BOOST_PACKAGE_PATH})...")

        execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf "${BII_BOOST_PACKAGE_PATH}" WORKING_DIRECTORY ${__BII_BOOST_TMPDIR})
    
        file(RENAME "${BII_BOOST_EXTRACT_DIR}" "${BII_BOOST_INSTALL_DIR}")
    endif()
endfunction()

function(BII_BOOST_BOOTSTRAP)
    message(STATUS "Bootstrapping Boost ${BII_BOOST_VERSION}...")

    if((NOT (EXISTS ${__BII_BOOST_B2})) OR (${BII_BOOST_BOOTSTRAP_FORCE}))
        execute_process(COMMAND ${__BII_BOOST_BOOTSTRAP_CALL} WORKING_DIRECTORY ${BII_BOOST_DIR}
                        RESULT_VARIABLE Result OUTPUT_VARIABLE Output ERROR_VARIABLE Error)
        if(NOT Result EQUAL 0)
            message(FATAL_ERROR "Failed running ${__BII_BOOST_BOOTSTRAP_CALL}:\n${Output}\n${Error}\n")
        endif()
    else()
        message(STATUS "Boost boostrapping aborted! b2 file already exists. Set BII_BOOST_BOOTSTRAP_FORCE to override")
    endif()
endfunction()

function(BII_BOOST_BUILD)
    include(ExternalProject)

    message(STATUS "Building Boost ${BII_BOOST_VERSION} with toolset ${BII_BOOST_TOOLSET}...")

    if(TRUE)
        if(BII_BOOST_LIBS)
            string(REGEX REPLACE "[,]" ";" __BII_BOOST_LIBS ${BII_BOOST_LIBS})

            foreach(lib ${__BII_BOOST_LIBS})
                message(STATUS "Building ${lib} library...")

                set(__BII_BOOST_B2_CALL_EX ${__BII_BOOST_B2_CALL} --with-${lib})
                
                execute_process(COMMAND ${__BII_BOOST_B2_CALL_EX} WORKING_DIRECTORY ${BII_BOOST_DIR}
                                RESULT_VARIABLE Result OUTPUT_VARIABLE Output ERROR_VARIABLE Error)
                if(NOT Result EQUAL 0)
                    message(FATAL_ERROR "Failed running ${__BII_BOOST_B2_CALL}:\n${Output}\n${Error}\n")
                endif()
            endforeach()
        else()
            if(NOT (BII_BOOST_LIBS_EXCLUDED))
                set(BII_BOOST_LIBS_EXCLUDED python)
            endif()

            string(REGEX REPLACE "[,]" ";" __BII_BOOST_LIBS_EXCLUDED ${BII_BOOST_LIBS_EXCLUDED})

            foreach(lib ${__BII_BOOST_LIBS_EXCLUDED})
                set(__BII_BOOST_B2_CALL ${__BII_BOOST_B2_CALL} --without-${lib})
            endforeach()

            execute_process(COMMAND ${__BII_BOOST_B2_CALL} WORKING_DIRECTORY ${BII_BOOST_DIR}
                            RESULT_VARIABLE Result OUTPUT_VARIABLE Output ERROR_VARIABLE Error)
            if(NOT Result EQUAL 0)
                message(FATAL_ERROR "Failed running ${__BII_BOOST_B2_CALL}:\n${Output}\n${Error}\n")
            endif()
        endif()

        
    else()
        message(STATUS "Boost build aborted! Build output folder (${BII_BOOST_DIR}/stage) already exists. Set BII_BOOST_BUILD_FORCE to override")
    endif()
endfunction()

function(BII_BOOST_INSTALL)
    BII_BOOST_INSTALL_SETUP()

    if(TRUE OR (NOT (EXISTS ${BIICODE_ENV_DIR}/boost/__BII_BOOST_SETUP_${BII_BOOST_VERSION}_${BII_BOOST_TOOLSET}_READY)) OR (${BII_BOOST_BUILD_FORCE}))
        BII_BOOST_PRINT_SETUP()

        BII_BOOST_DOWNLOAD()
        BII_BOOST_BOOTSTRAP()
        BII_BOOST_BUILD()

        #Mark current setup (toolset + version) as built
        file(WRITE ${BIICODE_ENV_DIR}/boost/__BII_BOOST_SETUP_${BII_BOOST_VERSION}_${BII_BOOST_TOOLSET}_READY "Biicode boost ${BII_BOOST_VERSION} w/ ${BII_BOOST_TOOLSET} toolset setup ready to use")
    endif()

    set(BOOST_ROOT       "${BII_BOOST_DIR}"         CACHE INTERNAL "Boost root directory")
    set(BOOST_INCLUDEDIR "${BOOST_ROOT}"            CACHE INTERNAL "Boost include directory")
    set(BOOST_LIBRARYDIR "${BOOST_ROOT}/stage/lib/" CACHE INTERNAL "Boost library directory")


    # CMake 3.1 on windows does not search for Boost 1.57.0 by default, this is a workaround
    set(Boost_ADDITIONAL_VERSIONS ${BII_BOOST_VERSION} CACHE INTERNAL "")
    # Disable searching on system Boost
    set(Boost_NO_SYSTEM_PATHS TRUE CACHE INTERNAL "")

    # FindBoost auto-compute does not care about Clang?
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        COMPILER_VERSION(__clang_version)
        string(REGEX REPLACE "([0-9])\\.([0-9])" "\\1\\2" __clang_version ${__clang_version})

        set(Boost_COMPILER "-clang${__clang_version}" CACHE INTERNAL "Boost library suffix")

        message(STATUS ">>>> Setting Boost_COMPILER suffix manually for clang: ${Boost_COMPILER}")
    endif()

    find_package(Boost)
    if(Boost_FOUND)
        include_directories(${Boost_INCLUDE_DIR})

        if(MSVC)
            link_directories(${Boost_LIBRARYDIR})
        endif()

        add_definitions( "-DHAS_BOOST" )

        message(STATUS "BOOST_ROOT       ${BOOST_ROOT}")
        message(STATUS "BOOST_INCLUDEDIR ${BOOST_INCLUDEDIR}")
        message(STATUS "BOOST_LIBRARYDIR ${BOOST_LIBRARYDIR}")
    else()
        message(FATAL_ERROR "Boost not found after biicode setup!")
    endif()
endfunction()
