boost-biicode [![Build Status](https://travis-ci.org/Manu343726/boost-biicode.svg?branch=master)](https://travis-ci.org/Manu343726/boost-biicode) [![Build Status](https://webapi.biicode.com/v1/badges/biicode/biicode/boost/master)](https://www.biicode.com/biicode/boost) 
=============

Experimental support for the Boost libraries on biicode 2.0

Running a Boost-related block, minimal example
----------------------------------------------

The idea is to hide all the complexity to the user. Using Boost was never this easy!


    $ bii cpp:configure -G "Visual Studio 12"
      INFO: Processing changes...

                                BLOCK biicode/boost
      =====================================================================
      ...
                          BLOCK manu343726/boost_example
      =====================================================================
      -- Setting up biicode Boost...
      -- Downloading Boost 1.57.0...
      ... (Trust your ADSL vendor...) ...
      -- Extracting Boost...
      -- Bootstrapping Boost...
      -- Building Boost 1.57.0 with toolset msvc-12.0...
      -- Building lib library...
      ... (Go for churros) ...
      -- BOOST_ROOT: /home/manu343726/.biicode/boost/1.57.0
      -- BOOST_INCLUDEDIR: /home/manu343726/.biicode/boost/1.57.0
      -- BOOST_LIBRARYDIR: /home/manu343726/.biicode/boost/1.57.0/stage/lib
      -- Boost 1.57.0
      -- Found the following Boost libraries
             lib

To use Boost in a block, just include `biicode/boost/setup.cmake` in the block `CMakeLists.txt` and run `bii_find_boost()` function:

``` cmake
INIT_BIICODE_BLOCK()
ADD_BIICODE_TARGETS()

#Include biicode Boost setup
include(biicode/boost/setup)

set(Boost_USE_STATIC_LIBS OFF) #Link with dynamic version of Boost (Just an example, use whatever you need)
    
#Use `bii_find_boost()`, our wrapper of `find_package(Boost)`:
bii_find_boost(COMPONENTS boost_lib another_boost_lib REQUIRED)

target_include_directories(${BII_BLOCK_TARGET} INTERFACE ${Boost_INCLUDE_DIRS})
target_link_libraries(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
```

`bii_find_boost()`
------------------

The `bii_find_boost()` function is a wrapper of CMake's `find_package()` to be used to find and configure Boost components automatically.  

It's designed with an interface very similar to the usual call to `find_package(Boost)`. The idea is to write almost exactly the same CMake code as usually to use Boost, with all the setup done under the hood. 

    bii_find_boost([COMPONENTS components...] [REQUIRED])

 - `COMPONENTS`: Boost components to find, separated with spaces.
 - `REQUIRED`: If specified, fail if one or more of that components is not found.

*Note there's no version parameter. To set the required Boost version, go to the `biicode.conf` of your block and select the proper `biicode/boost` track.*

`bii_find_boost()` will download and build the required Boost libraries if needed (Not set up previously). Then calls `find_package(Boost COMPONENTS ...)` after setup.

Note even if the whole Boost distribution will be downloaded if it's not currently available in the biicode environment, `bii_find_boost()` will build only the Boost components passed, and only if those were not built previously with the current toolset. That means header only Boost libraries, which are configured via a simple call like `bii_find_boost()`, do not build any component, but only download and set up the Boost distro inside the biicode environment.

Issues
------

### MinGW

To compile `Boost.Context`, MinGW depends on the Microsoft assembler. Be sure you have `ml` or `ml64` (Depending on your platform) in your `PATH`. Those executables are usually shipped within Visual Studio, check the `Visual Studio Directory/VC/bin/` folder.

### CMake configure

Seems that CMake has problems with long-running configures. In some cases, even if the libraries were built successfully, `find_package()` is not able to find the Boost components. Just rerun `bii cpp:configure`.