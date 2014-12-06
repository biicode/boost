biicode-boost
=============

Experimental support for the Boost libraries on biicode 2.0


Notes
-----

 - Static linking only (Check `boost/install` hook).
 - Boost 1.57.0 only.
 - Default toolset (GCC on linux, Clang on Mac, MSVC on Windows).
 - Running on develop version of biicode until 2.0 release.

State of the circus
-------------------

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
