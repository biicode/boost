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
      ... (Go for a coffee) ...
      -- BOOST_ROOT: /home/manu343726/.biicode/boost/1.57.0
      -- BOOST_INCLUDEDIR: /home/manu343726/.biicode/boost/1.57.0
      -- BOOST_LIBRARYDIR: /home/manu343726/.biicode/boost/1.57.0/stage/lib
      -- Boost 1.57.0
      -- Found the following Boost libraries
             lib

To use Boost in a block, just include `biicode/boost/setup.cmake` in the block `CMakeLists.txt` and run `bii_find_boost()` function:

``` cmake
#Include biicode Boost setup
include(biicode/boost/setup)
    
BII_CONFIGURE_BLOCK()
BII_BLOCK_TARGETS()

set(Boost_USE_STATIC_LIBS OFF) #Link with dynamic version of Boost (Just an example, use whatever you need)
    
#Use `bii_find_boost()`, our wrapper of `find_package(Boost)`:
bii_find_boost(COMPONENTS boost_lib another_boost_lib REQUIRED)
target_link_libraries(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
```

`bii_find_boost()`
------------------

The `bii_find_boost()` function is a wrapper of CMake's `find_package()` to be used to find and configure Boost components automatically.  

It's designed with an interface very similar to the usual call to `find_package(Boost)`. The idea is to write almost exactly the same CMake code as usually to use Boost, with all the setup done under the hood. 

    bii_find_boost([COMPONENTS components...] [REQUIRED])

 - `COMPONENTS`: Boost components to find, separated with spaces.
 - `REQUIRED`: If specified, fail if one of more of that components is not found.

 *Note there's no version parameter. To set the required Boost version, go to the `biicode.conf` of your block and select the proper `biicode/boost` track.*

`bii_find_boost()` will download and build the required Boost libraries if needed (Not set up previously). Then calls `find_package(Boost COMPONENTS ...)` after setup.

Note even if the whole Boost distribution will be downloaded if it's not currently available in the biicode environment, `bii_find_boost()` will build only the Boost components passed, and only if those were not built previously with the current toolset. That means header only Boost libraries, which are configured via a simple call like `bii_find_boost()`, do not build any component, but only download and set up the Boost distro inside the biicode environment.

Internal setup
--------------

The scripts inside `biicode/booost` block set up a Boost installation in the biicode environment. Multiple Boost versions are supported, with different compilers and toolsets.

### Configuration variables

`biicode/boost/setup.cmake` reads gets the configuration of variables to configure the Boost setup requested by the user:

- `BII_BOOST_VERSION`: Specifies the required Boost version, using dot syntax. **Inferred automatically from block track**.
- `BII_BOOST_TOOLSET`: Toolset which Boost libraries are compiled to. Inferred from `CMAKE_CXX_COMPILER` by default.
- `BII_BOOST_BUILD_J`: Number of threads used for Boost compilation. 1 (no parallel build) by default.
- `BII_BOOST_LIBS`: Set of Boost components to be built. For each component, all variants all built *Boost `b2` recognizes targets already built, so a component will be built only if it was not built with the current toolset before*. If `BII_BOOST_LIBS`  is not specified, no libraries are built. **Inferred from `bii_find_boost()` `COMPONENTS` parameter by default**.

### Extra variables

- `BII_BOOST_VERBOSE`: Enable/disable verbose Boost setup.
- `BII_BOOST_GLOBAL_USE_STATIC_LIBS`: Sets Boost linking configuration globally, overriding any configuration set in your dependencies `CMakeLists.txt`. Helpful when you depend on many Boost-related blocks and need an specific unique way to link against Boost. By default each dependency has it's own way to link with Boost, and then those blocks are linked within yours. This may generate problems in some cases, use this variable to take more control.

### Boost setup pipeline

1. **Setup**: The internal variables of the hook are configured, and all the directories required for installation are created.
2. **Download and extract**: Boost is downloaded on a temporary directory inside the biicode environment directory, only if the Boost package was not downloaded previously. The package is extracted to `.biicode/boost/BOOST_VERSION/`.
3. **Bootstrap**: Boost bootstrap is done to configure the `b2` file for build. If `b2` already exists, this step is skipped except `BII_BOOST_BOOTSTRAP_FORCE` variable is enabled.
4. **Build**: Boost components specified with `BII_BOOST_LIBS` are built. You can set up `BII_BOOST_BUILD_J` for parallel build. If no component was specified, this step is skipped (The default behavior for header-only Boost libraries).
5. **Configure**: FindBoost is configured to track the biicode Boost installation. This step prints some info like the `BOOST_ROOT`, `BOOST_INCLUDEDIR`, and `BOOST_LIBRARYDIR`.

Steps 2 to 4 are performed only if the required setup Boost-version + toolset (compiler) was not configured and built previously. *The call to Boost's b2 is still done, but that tool is smart enough to skip the already-compiled targets*.
 
Issues
------

### MinGW

To compile `Boost.Context`, MinGW depends on the Microsoft assembler. Be sure you have `ml` or `ml64` (Depending on your platform) in your `PATH`. Those executables are usually shipped within Visual Studio, check the `Visual Studio Directory/VC/bin/` folder.

### CMake configure

Seems that CMake has problems with long-running configures. In some cases, even if the libraries were built successfully, `find_package()` is not able to find the Boost components. Just rerun `bii cpp:configure`.
