boost-biicode [![Build Status](https://travis-ci.org/Manu343726/boost-biicode.svg?branch=master)](https://travis-ci.org/Manu343726/boost-biicode)
=============

Experimental support for the Boost libraries on biicode 2.0

Contents
--------

This project contains a set of blocks to test different boost libraries. These are blocks of the form `examples/boost-[BOOST_LIB]` containing examples extracted from Boost docs or other web resources available.

Each example depends on the `boost/install` block, a CMake-only block with a hook which configures the required version of Boost. To use Boost in a block, just include `boost/install/install` and run `BII_BOOST_INSTALL()` function:

``` cmake
include(boost/install/install)

BII_CONFIGURE_BLOCK()
BII_BLOCK_TARGETS()

#Install biicode Boost
BII_BOOST_INSTALL()

#Use Boost as usual with CMake's FindBoost.cmake, don't care about biicode
find_package(Boost COMPONENTS a_boost_component)
target_link_libraries(${BII_BLOCK_TARGET} INTERFACE ${Boost_LIBRARIES})
```

`BII_BOOST_INSTALL()`
---------------------

The `BII_BOOST_INSTALL()` sets up a Boost installation in the biicode environment. Multiple Boost versions are supported, with different compilers and toolsets.

### Configuration variables

`BII_BOOST_INSTALL()` reads from a couple of variables to configure the Boost setup requested by the user:

- `BII_BOOST_VERSION`: Specifies the required Boost version, using dot syntax. If not specified, `1.57.0` is used by default.
- `BII_BOOST_TOOLSET`: Toolset which Boost libraries are compiled to. Inferred from `CMAKE_CXX_COMPILER` by default.
- `BII_BOOST_BUILD_J`: Nunber of threads used for Boost compilation. 1 (no parallel build) by default.

### Boost setup pipeline

1. **Setup**: The internal variables of the hook are configured, and all the directories required for installation are created.
2. **Download and extract**: Boost is downloaded on a temporary directory inside the biicode environment directory, only if the Boost package was not downloaded previously. The package is extracted to `.biicode/boost/BOOST_VERSION/`.
3. **Bootstrap**: Boost bootstrap is done to configure the `b2` file for build. If `b2` already exists, this step is skipped except `BII_BOOST_BOOTSTRAP_FORCE` variable is enabled.
4. **Build**: Boost is built. Note that this step may take minutes/hours depending on your machine and the value of `BII_BOOST_BUILD_J`, and during that time there will be no output at all.
5. **Configure**: FindBoost is configured to track the biicode Boost installation. This step prints some info like the `BOOST_ROOT`, `BOOST_INCLUDEDIR`, and `BOOST_LIBRARYDIR`.

Steps 2 to 4 are performed only if the required setup Boost-version + toolset (compiler) was not configured and built previously. You can force them deleting the control file located at `.biicode/boost` or enabling `BOOST_BUILD_FORCE` variable.

Running a Boost-related block, minimal example
----------------------------------------------

The idea is to hide all this complexity to the user. Using Boost was never this easy!

```
$ bii cpp:configure -G "Visual Studio 12"
  -- Setting up biicode boost...
  -- Boost version: 1.57.0
  -- Toolset: msvc-12.0
  -- Parallel build disabled
  ...
  -- Downloading Boost 1.57.0...
  -- Extracting Boost...
  -- Bootstrapping Boost...
  -- Building Boost 1.57.0 with toolset msvc-12.0...
  ... (Go for a coffee) ...
  -- BOOST_ROOT: /home/manu343726/.biicode/boost/1.57.0
  -- BOOST_INCLUDEDIR: /home/manu343726/.biicode/boost/1.57.0
  -- BOOST_LIBRARYDIR: /home/manu343726/.biicode/boost/1.57.0/stage/lib
                   BLOCK manu343726/boost_example
  =====================================================================
  ... (The usual biicode configuration output) ...
```

Testing with this repo
----------------------

 - Clone this repo
 - Do `bii init` on it.
 - Run `bii cpp:build`
 - Go for churros
 - Come back and see if the blocks were built successfully
 
Issues
------

### MinGW

To compile `Boost.Context`, MinGW depends on the Microsoft assembler. Be sure you have `ml` or `ml64` (Depending on your platform) in your `PATH`. Those executables are usually shipped within Visual Studio, check the `Visual Studio Directory/VC/bin/` folder.

### GCC toolset, linux

b2 call may fail when passing the gcc toolset automatically computed from the C++ compiler version. Just rerun `bii cpp:configure`.
