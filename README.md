boost-biicode [![Build Status](https://travis-ci.org/Manu343726/boost-biicode.svg?branch=master)](https://travis-ci.org/Manu343726/boost-biicode) [![Build Status](https://webapi.biicode.com/v1/badges/biicode/biicode/boost/master)](https://www.biicode.com/biicode/boost) 
=============

Experimental support for the Boost libraries on biicode 2.0

Contents
--------

This project contains a set of blocks to test different boost libraries. These are blocks of the form `examples/boost-[BOOST_LIB]` containing examples extracted from Boost docs or other web resources available, along with some other blocks using my biicode account to test more use cases of Boost (Depending on multiple Boost-related blocks, checking global linking setup, etc).

Each example depends on the `biicode/boost` block, a CMake-only block with a hook which configures the required version of Boost. 

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

Testing with this repo
----------------------

 1. Clone this repo
 2. Do `bii init` on it.
 3. Run `generate.py` (See "*Block generation*" bellow)
 3. Run `bii cpp:build`
 4. Go for churros
 5. Come back and see if the blocks were built successfully

Contributing
------------

Please never forget to update the docs here at this readme file, the readme file of the `biicode/boost` block (Edit the one from the template of course), and the biicode docs [here](https://github.com/biicode/docs/blob/master/c%2B%2B/examples/boost.rst). 

Note the block which really does the work is `boost/install`, `biicode/boost` just *"inherits"* from it. All the scripts are located in that block, which is not part of block generation and is always located at `blocks/` directory of this project.

The examples are always of the form `examples/boost-[LIBRARY]` and you are not allowed to publish changes to the biicode cloud (Actually, you don't have the passwords, only the biicode team).
The idea is to test all changes locally using this project, send us your changes via git pull-request/whatever, and then we will update the blocks on the cloud. This policy is just to minimize possible broken publications, 
remember there are devs relying on the blocks on the cloud.

Block generation
----------------

This repo maintains the biicode Boost blocks and some example blocks as templates inside the `blocktemplates/` folder. Then a `generate.py` script takes the configuration written on `settings.py` generating the final blocks located at `blocks/`.

### Templates

The templates are just usual files with `<VARIABLE>` tags on it's content. `generate.py` takes the blocks and variables specified in `settings.py` substituting that tags with the variables value.

Take for example the `biicode.conf` of `biicode/boost` template:

```
[parent]
  <BIICODE_BOOST_BLOCK>:<LATEST_BLOCK_VERSION>
```

after block generation, that entry will be expanded to something like:

```
[parent]
  biicode/boost(1.57.0):4
```

### `settings.py`

There is a `settings()` function supposed to return a `BiiBoostSettings` instance. `BiiBoostSettings` constructor takes three parameters:

 - **varaibles**: Dictionary `variable -> value`. Note variable values are not strings directly but functions that return the final value. This allows some template-dependent customization of these values.  
   The signature of that value functions is: `value(block, track, file)`, where `block` is the block name. `track`is the block track, and `file` is the file where the variable will be applied.

 - **blocks**: A dictionary `block -> block settings` with the publish setup and templates specifications:

    ``` python
    block : ("publish tag", [template_specification, ...])
    ```
   
   Where `template_specification` is a tuple taking a block file name and an
   array with the variables applied there:

    ``` python
    ("filename (relative to block)", ["variable", ...])
    ```

   To not publicate the generated block automatically, set the publish tag to "disabled".

 - **passwords**: A simple dictionary `biicode account -> password` with the biicode credentials of the blocks that will be published by the script. Passed from the CLI by default. **PLEASE ALWAYS ENCRYPT THE PASSWORDS!!!** See `.travis.yml` for an example.


*I know, the settings are a bit cumbersome to write and read. I will be using some form of YAML in the future.*

Currently the `settings()` function parses arguments from command line using Python's `argsparse`. So the call to `generate.py` should be:

```
generate.py track [--no-publish] [--publish-examples] [--tag tag] [--ci-build] [--passwords passwords] [--exclude "blocks"]
```

 - `track`: Block tracks. `master`, `1.57.0`, `1.56.0`, `1.55.0`.
 - `--no-publish`: Disables publication of all blocks.
 - `--publish-examples`: Enables examples publication.
 - `--tag tag`: Tag to publish the blocks with.
 - `--ci-build`: Specifies if the script is being run as part of a continuous integration build.
 - `--passwords`: Python map with the biicode credentials needed.
 - `--exclude "blocks"`: Excludes the specified blocks from generation, separated with spaces.

### Generation example:

`biicode/boost` `biicode.conf` file:

```
[parent]
  biicode/boost(<TRACK>): <LATEST_BLOCK_VERSION>
```

`biicode/boost/setup.cmake`:

``` cmake
include(boost/install/install)

set(BII_BOOST_GLOBAL_OVERRIDE_VERSION <BOOST_VERSION>)
```

`settings.py`:

``` python
def settings():
    # cli args parsing omitted...

    boost_version = args.track if args.track != "master" else "1.57.0"

    variables = {"BOOST_VERSION":
                 lambda block, block_track, file: boost_version,
                 "TRACK":
                 lambda block, block_track, file: args.track,
                 "LATEST_BLOCK_VERSION":
                 lambda block, block_track, file: latest_block_version(block, block_track)}

    packages = {"biicode/boost": (version, [("biicode.conf", ["TRACK", "LATEST_BLOCK_VERSION"]), ("setup.cmake", ["BOOST_VERSION"])])}

    passwords = ast.literal_eval(args.passwords.replace('->', ':'))

    return BiiBoostSettings(packages, variables, passwords)
```

`generate.py` call:

``` shell
$ python generate.py 1.57.0 --publish-examples --ci-build --passwords "{'biicode': 'what's my password?'}"
```

This will generate the `biicode/boost(1.57.0)` block and publish it to biicode cloud automatically.

Continuous integration
----------------------

Here at biicode [we love Travis CI](http://blog.travis-ci.com/2015-01-29-my-c-c-dev-environment-github-travisci-biicode/), I'm using that CI service to test all the `biicode/boost` tracks with 48 different build jobs.

The build matrix includes:

 - **`biicode/boost` track**: `master`, `1.57.0`, `1.56.0`, `1.55.0`. Master is the default track, with the latest Boost version available. Currently contains Boost 1.57.0.
 - **C++ Compiler**: GCC 4.9.1 and Clang 3.4.
 - **Build type**: Release or Debug build.
 - **Boost linking**: Static or dynamic linking to Boost.
 - **LLVM libc++**: Build with LLVM libc++ or GNU stdlibc++. *Of course GCC builds are done with stdlibc++ only*.

**Current status**: [![Build Status](https://travis-ci.org/Manu343726/boost-biicode.svg?branch=master)](https://travis-ci.org/Manu343726/boost-biicode)

Internal setup
--------------

The scripts inside `biicode/booost` block set up a Boost installation in the biicode environment. Multiple Boost versions are supported, with different compilers and toolsets.

### Configuration variables

`biicode/boost/setup.cmake` reads gets the configuration of variables to configure the Boost setup requested by the user:

- `BII_BOOST_VERSION`: Specifies the required Boost version, using dot syntax. **Inferred automatically from block track**.
- `BII_BOOST_TOOLSET`: Toolset which Boost libraries are compiled to. **Inferred from `CMAKE_CXX_COMPILER` by default**.
- `BII_BOOST_BUILD_J`: Number of threads used for Boost compilation. **1 (no parallel build) by default**.
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
