Writing Hxcpp Externs
----------------------

### Overview

  - Mechanics of getting code to stick together
    - Linking options
    - Yet another make system
  - Playing nice with mixed memory models
    - Memory referneces
    - Thread considerations
    - Libs, mains and boots
  - Advanced
    - Custom toolchains






## Mechanics of getting code to stick together


###  Combining haxe + native code


> Come on, come on, let's stick together
> You know we made a vow not to leave it on the build server




#### Source
Native code can come in many forms:
  - source
  - static library / framework
  - dynamic library / framework
     - assumed installed or not
  - And: you want to expose this to haxe developers - "user"
    - using interally has a few more options, but ignore


#### Haxelib
Expose via haxelib(s)
  - Possibly with thirdparty SDK download instructions
  - If it contains source component,
     - a way to get additonal dependencies
     - haxelib easiest for users, but git also popular
     - important to consider, since every dependence will lose % of users

  eg: haxelib install nme-toolkit
      nme contains a copy of some headers that might not be installed with windows SDK.



#### Static libraries
Shipping custom c++ static libraries is problematic
 - Its nice for users when it works
 - Ok for single target "stable" thirdparty sdks or proprietary code
 - dependence of STL on version of runtime code, not just headers
 - more of a problem with windows now it is revving on the mobile-like cycle
    - lost its stability
 - mobile has many many architectures simulator/x86/32/64/v7/bitcode
 - static libraries can get BIG
 - hxcpp no longer ships static libraries
 - hxcpp compile cache mitigates this problem
   - See [Compile Cache](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/CompileCache.md)


#### Dynamic libraries
Shipping dynamic libraries is a good user experience
 - Largely immune to the versioning problems of static libraries
 - Do not need to install dependencies - much nicer for users
 - May need to cover lots of architectures
   - not so bad, because you can't use it for iOS anyhow
   - win64, linux64, mac64, android armv7 - and maybe win32 for neko
 - Probably need a static-link fallback for iOS and other architectures
   - good news - not much extra work
 - aesthetically not a "single exe" solution - so offer static link as option too
 

#### Executable
Shipping your framework as an exe is possible
  - exe loads the haxe code as a dll
    - generally limited to desktop
  - exposes internal functions via prearranged protocol - push or pull
    - similar to android target
  - for internernal systems, haxe builds to a static library and then
    internal build system links it all together.
  - More of an advanced mode



#### Source
Shipping your framework as source is easiest for framework developer
  - combine with dlls and haxelib dependencies if possible
  - merge your libraries build file with the haxe generated one
    - consistent architecture support
    - build 'on demand' only
  - hxcpp now does this for pcre, sqlite, mysql, sys
  - the native-toolkit git libraries provide some common libs, such as freetype and jpeg in this format


### Integration
A library will generally consist of some native code and some haxe code.
The user will generally call haxe code, which will then call the native code.
This interaction can happen in differnt ways, depending on how tied you are to hxcpp
  - Use extern @:native for strongly-typed access to external classes
  - inline cpp
  - cffi (cffi-prime)
  - Tightly bound with #including Generated.h/hxcpp.h
  - hx::Native  (experimental)


#### extern @:native
  - Describe class Api using haxe types + cpp extensions
  - Use @:include("./....") meta to allow c++ code to "see" the class definition
  - Hold members as `cpp.Star<Class>`
  - Expose global functions as static class functions, with @:native("function_name")
  - Best way to call into extenal code - use in combination with other code
    - hxcpp only - not cppia
    - mostly 1-way (but can use callbacks)
  - @:sourceFile("./impl.cpp") - add to build file


#### inline cpp
  - Prefer extern @:native functions, because they are stronly typed, to:
    - untyped `__cpp__(  )`
    - @:cppFunctionCode


#### Code injection
  - Injecting code into generated output allows external code and generated code
     to "see" each other and share compiler flags and therfore avoids versioning conflicts.
  - Can be inlined or included.
    - Inline is good for one-liners converting types, or single file bug reports
      - Awkward since it is a meta-string and needs appropriate quoting
    - Included is generally better, since it allows syntax highlighting and avoids quoting
      - Use relative path @:cppInclude("./myCode.cpp") to use power of haxelib search path

Meta
   - @:cppFileCode / @:cppInclude   : into top of cpp file (not in namespace)
   - @:headerCode / @:headerInclude : into top of header file
   - @:headerClassCode              : inject class members

printx code example:

```haxe
extern class Native
{
   @:native("TPrintX")
   public static function printX<T>(t:T) : Void;
}

@:cppFileCode('
#include <stdio.h>
template<typename T>
void TPrintX(T owner) { printf("x:%f\\n", owner->x); }
')
class Test
{
   var x:Float;

   public function new()
   {
      x = 1.2;
   }
   public static function main()
   {
      Native.printX( new Test() );
   }
}
```



#### Cffi
  - Isolate library code from hxcpp code via function pointers and opaque types
  - Can link statically or dynamically to hxcpp code
  - Can link to other targets (neko,js,hl?) since the object type is not specified.
    - Js in browser does not support finalizers/weak references, so limiting
  - Isolation forms a clean Api.
  - Robust against changes to implementation
    - Must still consider gc references and threading issues.
  - A little more work

  - [Example](https://github.com/HaxeFoundation/hxcpp/blob/master/test/cffi/project/Project.cpp)


#### Generated.h/hxcpp.h
  - Library code "#includes" generated headers directly, or `#include<hxcpp.h>` directly
    - Must use 'haxe' code tag to ensure correct defines are actiave (eg api version)
      - or add to 'haxe' file group
    - Should `#include<hxcpp.h>` exactly once at top to allow for pre-compiled-headers
  - Can use normal c++ syntax for accessing and calling functions, which is nice
  - Depend on some things that may change, not so nice.
    - Hxcpp details are pretty stable, although no promises
      - eg, HXCPP_GC_GENERATIONAL requires write-barrier
    - You would want to control your versions of haxe/hxcpp


####  @:nativeGen
  - Experimental
  - Aims for compromise between CFFI and hxcpp.h
  - Interfaces are declared with meta @:nativeGen
  - They are implenented with multiple inheritence
  - Results in abstract base class that does not depend in hxcpp.h
    - can be #included without concern
  - nativeGen interfaces can only refer to other nativeGen or basic types.
  - Some helpers for threads and gc referencing





###   Yet another build system


> We built this city, we built this city on X M L


#### Build.xml
  - Custom format
  - Really?
  - Yes
  - Zero (additional) dependency system that works on windows
  - Mainly looks like a list of files and lists of compiler flags
  - Not general purpose
    - very specific to compiling an linking code
    - implemented in haxe

  - [See build docs in hxcpp](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/build_xml/README.md)


### Cache


  - The hxcpp compile cache allows obj files to be shared between projects
  - This relieves the need for precompiled-static libraries, since user only needs to do this once
  - However, hxcpp wont assume library is cache-safe unless some dependencies or 'cache' are specified
  - Easiest to have all .cpp files depend on all .h files - unless developing
  - [See cache docs in hxcpp](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/CompileCache.md)

### Tags

  [See tags docs in hxcpp](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/build_xml/Tags.md)

### Xml Injection

  [See xml injection docs in hxcpp](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/build_xml/XmlInjection.md)

  [Example injection](https://github.com/haxenme/nme/blob/master/src/nme/StaticNme.hx)

   - Old code:
     - possibly adds a "lib" to the haxe target
     - includes the NmeLink.xml - easier than inlining eveything
   - New code (toolkit)
     - uses macro to find relative path
     - adds an "import" of the absolute filename
     - uses "merge" to add libraries etc from nme-target group into haxe target
       - allows nme-target to be compiled to dll separately if not run from haxe





Playing nice with mixed memory models
-------------------------------------

>  All alone with my memory
>  Of my days in the sun
>  If you touch me
>  You'll understand what happiness is
>  Look a new GC collection cycle has begun


### Memory Model

 - c++ has explicit allocation/deallocation memory model
 - haxe semantics requires implicit collection
   - reference counting + cycle detection
   - garbage collection (GC)
 - can be tricky when the two (or three in the case of java) meet


For hxcpp GC to work, it needs to know which objects are still live
and when it can release external objects
 - internal references are ok
 - storing references form haxe to c++ - explicit/Finalizers
 - storing referneces from c++ to haxe - stack/GCRoots

#### Holding External References
Given a c++ resource, say "Buffer".  A c++ program would do
 - new Buffer();
 - delete Buffer;
Hxpp integration:
 - declare an exten @:native("Buffer") class, with "static create" and "destroy" functions
 - the create function returns a `cpp.Star<Buffer>` pointer
 - this is enough for explicit allocation/deallocation
 - [Example](code/buffer)

[Next Level](code/buffer/BufferWrapper.hx)
 - create a wrapper class, with a single member `var handle:cpp.Star<Buffer>`
 - extend cpp.Finalizable, overwrite finalize to call destory
 - add explicit 'release'/'dispose'/'close' method to avoid waiting for GC to free
   - also set pointer to null
 - chain Api functions - possibly "haxify" them - eg, Strings, Arrays - or "get" function
 - correct when used in arrays/maps/dynamic etc
 - can be used with cppia too
 - alternatively, you can add finalizers to classes that store members, and handle stack explicitly

### Stack storage
Storing references without 'new'
 - Some classes may not usually be used with 'new'
   - eg, std::string
 - Storing on stack (local variables, function args) will still work normally
 - Storing in members is tricker because no move and no destructor are called, and memset(0) is used for initialization
 - You might be able to get away with it with an explict "release" or (&handle)->~Buffer()
 - Arrays / Maps will not work
 - HXCPP_GC_MOVING will not work
 - Better just to use pointer


### CFFI 'abstract'
 - overloaded use of the term 'abstract'
 - allocates or references native c++ storage and adds a finalizer callback
 - usually it is used as a 'handle' in other cffi calls
   - but you can get at data with cpp.Pointer.nativeFromHandle
 - Works on neko
 - Sadly, not Js in the browser
 - Nme extends an 'Object' type with virtual destructor to centralize code


### Finalizers - what you can and can not do.

Some cases, finalizer does not delete
 - Might dec-ref (nme, objc)
 - Wx - clears client data, which points (weakly) to haxe object
      - deleting the wx object will zero-out the reference from haxe back to object
 - Hxcpp refers to java objects
   Haxe hold gc refererence to JNIObject abstract.  This holds strong reference to java,
    when haxe refernce goes (hxcpp finalizer), it releases the java reference.
 - Java refers to haxe object.  Stores a handle on java side, which refers to a hxcpp GCRoot.
    The java finalizer removes the GCRoot
 - You can't call any GC functions - eg 'trace'. Do minimum amount possible
 - May be called from foreign thread
   - be careful with opengl
   - be careful with calling java
   - check thread and push on "jobs" list to do next refresh


### Referecing Hxcpp Object

Storing references to hxcpp objects from outside
 - 'Pushed' via opaque id(int)
   - Objects are stored in haxe in an array
   - Index into array is passed to external function
   - External function passed index back and haxe looks up the array
 - Via Cffi.h
   - 'value's are stored in GC roots via AutoGCRoot
 - Via hx/Native.h
   - store NativeInterface in hx::Ref<NativeInterface>
 - Via hxcpp.h
   - `GCAddRoot(hx::Object **inRoot)`
   - `GCRemoveRoot(hx::Object **inRoot)`
   - Or use static array declared somewhere in haxe


Theads And Stacks
-----------------

Playing nice with mixed memory models

   Threads & Stacks

> Walk on, walk on
> With hope in your heart
> And you'll never walk the stack alone
> You'll never walk the stack alone



- See [Threads and Stacks](https://github.com/HaxeFoundation/hxcpp/blob/master/docs/ThreadsAndStacks.md)




