biicode-boost [![Build Status](https://travis-ci.org/Manu343726/boost-biicode.svg?branch=master)](https://travis-ci.org/Manu343726/boost-biicode)
=============

Experimental support for the Boost libraries on biicode 2.0


Notes
-----

 - Static linking only (Check `boost/install` hook). *Not really, boost bootstrapping can be configured to build both static and dynamic binaries, then configuring via cmake variables.*
 - Boost 1.57.0 only.
 - Default toolset (GCC on linux, Clang on Mac, MSVC on Windows).
 - Running on develop version of biicode until 2.0 release. *Nope. Check notes bellow.*

State of the circus
-------------------

### Linux (GCC/Clang):

*Check travis build.*

 - **Install hook**: Working
 - **examples/boost-flyweight**: Working
 - **examples/boost-multiindex**: Working
 - **examples/boost-phoenix**: Working 
 - **examples/boost-coroutine**: Working
 - **examples/boost-filesystem**: Working   
 - **examples/boost-log**: **Not Working**. Does not link.       

### Mac OSX (Clang):

 - **Install hook**: Working
 - **examples/boost-flyweight**: Working
 - **examples/boost-multiindex**: Working
 - **examples/boost-phoenix**: Working 
 - **examples/boost-coroutine**: Working
 - **examples/boost-filesystem**: Not tested   
 - **examples/boost-log**: **Not Working**. Does not link.        

### Windows:

  1. Visual Studio 12
	- **Install hook**: Working
	- **examples/boost-flyweight**: Working
	- **examples/boost-multiindex**: Working
	- **examples/boost-phoenix**: Working
	- **examples/boost-coroutine**: Working. *Linker error "LNK1104: 'libboost_context-vc120-mt-gd-1_57.lib' cannop be openned". Boost binaries location (`BOOST_ROOT/stage/lib`) should be added explicitly to linker directories. Also, linking issues with shafe exception handling. Pass the `/SAFESEH:NO` option to disble it.*
	- **examples/boost-filesystem**: Working 
	- **examples/boost-log**: **Not Working**. Not tested  
 
  2. MinGW GCC 4.9.1
	- **Install hook**: Working
	- **examples/boost-flyweight**: Working
	- **examples/boost-multiindex**: Working
	- **examples/boost-phoenix**: Working
	- **examples/boost-coroutine**: Not working. Undefined references to symbols inside libboost_context. On GCC build there is no libboost_context.lib at `BOOST_ROOT/stage/lib/`?
	- **examples/boost-filesystem**: Working 
	- **examples/boost-log**: **Not Working**. Not tested  
