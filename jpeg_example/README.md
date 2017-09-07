Worked Example
--------------

### Creating wrapper for libjpeg

1. Download the source. I have downloaded and extracted source from http://ijg.org/files/jpegsr9b.zip


2. Start a new file in this directory called "BuildJPeg.xml", with an empty target and filelist:

```xml
<xml>
   <echo value="Jpeg!" />

   <files id="jpegfiles" >

   </files>

   <target id="default" >
   </target>
 </xml>
```

```
haxelib run hxcpp BuildJPeg.xml
```

3. Find the source files 
```
ls -c1 jpeg-9b/*.c
```

 Paste these into the 'jpegfiles' section, and use your mad skillz to convert this to a file list.

```
 :'<,'>s/^/      <file name="/
 :'<,'>s/$" \/>/
```

 Add the files to the target:
 ```xml
 <files id="jpegfiles" />
 ```

 Results are in "BuildJPeg-3.xml" if you want to skip this step

 We are ready to compile again, but now get errors:
 ```
 Cannot open include file: 'jconfig.h': No such file or directory
 ```

4.
 This is pretty typical of libaries that use some kind of autoconf to configure a config.

 Hxcpp is big on cross-compiling, and running autoconf many times is tedious, so we seek a solution with a single config - probably with #ifdef conditions.

 To this end I have created a separate directory here, "config" and added the missing "jconfig.h" file (I cheated and copied some earlier work).

 Now, we need to add this as an include path to the jpenfiles section.  While we are at it, we will add the "jpeg-9b" as an include path, since the files are going to relative to this directory.

```xml
<compilerflag value="-Iconfig" />
<compilerflag value="-Ijpeg-9b" />
```

```
haxelib run hxcpp BuildJPeg.xml
```

5.
This got further!  But now we have issues with "jmemdos".  This is where you need to do some cross-platform work.  Easier just to delete files that do not work for now.  We will delete the 'mem' files except jmemmgr.c and jmemnobs.c.  Sometimes, you would use `if="windows"` to select certain files.

Now things compile, but to a library, so we need to add a toolid and output details to the target.

```xml
  <target id="default" tool="linker" toolid="${haxelink}" output="jpeg9b" >
```

6. This now tries to make an executable, but there are multiple "main" routines here because the source is not split nicely into library and application directories.  However, there is a convention here.
   - jpegtran.c is an app
   - jxxx.c files are the library
   - wrxxxx, transupp.c and rdxxxx are app utiity functions
   - the rest are apps.

So, we will delete the app files, except for cjpeg.c which we will put in a "main" group, along with the app utility files.  We then add this main group to the target, and set the 'outdir' while we are at it.  At this point, we will also change the if for the target group to 'cjpeg'

```xml
   <target id="cjpeg"  tool="linker" toolid="${haxelink}" output="jpeg9b" >
       <files id="jpegfiles" />
       <files id="main" />
       <outdir name="out" />
   </target>
```


Note that we must provide the taget on the command-line now.
```
haxelib run hxcpp BuildJPeg.xml cjpeg
```

so now this builds, and we are the proud owner of:
```
out/jpeg9b.exe
```

And, if you have the android NDK installed

```
haxelib run hxcpp BuildJPeg.xml  cjpeg -Dandroid -Dexe_link
```

Will build an executable that can be run on android.

7. If you run the hxcpp tool with the '-v' flag, you will see the warning:
`Ignoring compiler cache for jpegfiles because of possible missing dependencies`.  To fix this, we should add dependencies.

Using a similar technique for the '.c' files, we can create a files group for the '.h' files - call it "jpeg_headers" in the id.  The, add
```xml
   <depend files='jpeg_headers' />
```
to both the "jpegfiles" and "cjpeg" groups.  You can be more accurate than this, but this is a good start.  Then add a cache node to each group.

```xml
   <cache value="true" />
```

Now there is no warning, and when we run:
```
haxelib run hxcpp cache list
```
You can see there are "jpegfiles" and "main" projects.

Finally, we will add the 'asLibrary' attribute the the jpegfiles node, which can skip linking some files if they are not used.
```xml
   <cache value="true" asLibrary="true" />
```


8. We will copy this BuildJPeg.xml to JPegLib.xml and use:
```
haxelib dev testjpeglib .
```
to allow us to use this in the next part of the workshop.
