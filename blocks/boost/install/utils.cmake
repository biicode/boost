function(__COMPUTE_COMPILER_VERSION_GNULIKE _ret)
	if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} --version OUTPUT_VARIABLE version_string_full )
		string (REGEX REPLACE ".*clang version ([0-9]+\\.[0-9]+).*" "\\1" version_string ${version_string_full})
	elseif(CMAKE_COMPILER_IS_GNUCXX)
		EXECUTE_PROCESS( COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE version_string)
		string (REGEX REPLACE "([0-9])\\.([0-9])\\.([0-9])" "\\1.\\2.\\3" version_string ${version_string})
    string(STRIP ${version_string} version_string) #Remove extra newline character
	endif()

	set(${_ret} ${version_string} PARENT_SCOPE)
endfunction()

function(COMPILER_VERSION _ret)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
      OR CMAKE_CXX_COMPILER MATCHES "icl"
      OR CMAKE_CXX_COMPILER MATCHES "icpc")
    set (__version "")
  elseif (MSVC14)
    set(__version "14.0")
  elseif (MSVC12)
    set(__version "12.0")
  elseif (MSVC11)
    set(__version "11.0")
  elseif (MSVC10)
    set(__version "10.0")
  elseif (MSVC90)
    set(__version "9.0")
  elseif (MSVC80)
    set(__version "8.0")
  elseif (MSVC71)
    set(__version "7.1")
  elseif (MSVC70) # Good luck! (That's from Kitware, but I'm not sure here at biicode we support VC6.0 and 7.0 too. So good luck from the hive too!)
    set(__version "7.0") # yes, this is correct
  elseif (MSVC60) # Good luck!
    set(__version "6.0") # yes, this is correct
  elseif (BORLAND)
    set(__version "")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
    set(__version "")
  else()
    __COMPUTE_COMPILER_VERSION_GNULIKE(__version)
  endif()
  set(${_ret} ${__version} PARENT_SCOPE)
endfunction()

function(BII_BOOST_COMPUTE_TOOLSET _ret)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
      OR CMAKE_CXX_COMPILER MATCHES "icl"
      OR CMAKE_CXX_COMPILER MATCHES "icpc")
		set(__toolset_name "intel")
	elseif(MSVC)
		set(__toolset_name "msvc")
	elseif(BORLAND)
		set(__toolset_name "borland")
	elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
		set(__toolset_name "clang")
	elseif(CMAKE_COMPILER_IS_GNUCXX)
		set(__toolset_name "gcc")
	else()
		message(FATAL_ERROR "Unknown compiler, unable to compute toolset")
	endif()

	COMPILER_VERSION(__version)

    if(__version AND (NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin")))
		set(${_ret} "${__toolset_name}-${__version}" PARENT_SCOPE)
	else()
		set(${_ret} "${__toolset_name}"              PARENT_SCOPE)
	endif()
endfunction()

function(BII_BOOST_SET_CLANG_COMPILER BII_BOOST_DIR BII_BOOST_VERBOSE RETURN)
  # FindBoost auto-compute does not care about Clang?
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      if(NOT (CMAKE_SYSTEM_NAME MATCHES "Darwin"))    
          COMPILER_VERSION(__clang_version)#In boost/install/utils.cmake

          #Some regex kung-fu
          string(REGEX REPLACE "([0-9])\\.([0-9])" "\\1\\2" __clang_version ${__clang_version})

          set(Boost_COMPILER "-clang${__clang_version}")
      else()
          #On Darwin (OSX) the suffix is extracted from library binary names. That's why this setup is
          #done after build

          file(GLOB __clang_libs RELATIVE "${BII_BOOST_DIR}/stage/lib/" "${BII_BOOST_DIR}/stage/lib/*clang*")

          if(__clang_libs)
              list(GET __clang_libs 0 __clang_lib)

              if(BII_BOOST_VERBOSE)
                  message(STATUS ">>> Suffix source: ${__clang_lib}")
              endif()

              #More kung-fu
              string(REGEX REPLACE ".*(-clang-darwin[0-9]+).*" "\\1" __suffix ${__clang_lib})

              if(BII_BOOST_VERBOSE)
                  message(STATUS ">>>> Suffix: ${__suffix}")
              endif()

              set(Boost_COMPILER ${__suffix})
          else()
              message(FATAL_ERROR "Unable to compute Boost compiler suffix from Clang libraries names")
          endif()
      endif()

      if(BII_BOOST_VERBOSE)
          message(STATUS ">>>> Setting Boost_COMPILER suffix manually for clang: ${Boost_COMPILER}")
      endif()

      set(${RETURN} ${Boost_COMPILER} PARENT_SCOPE)
  endif()
endfunction()
