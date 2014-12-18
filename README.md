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

*The list bellow contains tests done before 2.0 release using development version of biicode. Those are outdated since the 2.0 release. Check the Travis CI build for the current status.*

### Linux:

 - **Install hook**: Working
 - **examples/boost-flyweight**: Working
 - **examples/boost-multiindex**: Working
 - **examples/boost-phoenix**: Working 
 - **examples/boost-coroutine**: Working
 - **examples/boost-filesystem**: Working   
 - **examples/boost-log**: **Not Working**. Does not link.       

### Mac OSX:

 - **Install hook**: Working
 - **examples/boost-flyweight**: Working
 - **examples/boost-multiindex**: Working
 - **examples/boost-phoenix**: Working 
 - **examples/boost-coroutine**: Working
 - **examples/boost-filesystem**: Not tested   
 - **examples/boost-log**: **Not Working**. Does not link.        

### Windows:

 - **Install hook**: Working
 - **examples/boost-flyweight**: Not tested
 - **examples/boost-multiindex**: Not tested
 - **examples/boost-phoenix**: Not tested 
 - **examples/boost-coroutine**: Not tested
 - **examples/boost-filesystem**: Not tested   
 - **examples/boost-log**: **Not Working**. Does not link.    
