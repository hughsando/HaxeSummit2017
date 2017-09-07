Writing Your Own Compiler Toolchain
-----------------------------------

Hxcpp ships with a number of toolchains, but you can add your own from outside.
 - Usually for cross-compiling
 - To include additional include and lib files, which would be too big for hxcpp
 - To include code that might be covered under NDA.
   - Will accept pull-request that offer hooks for NDA code, but not NDA code itself

### Case study: winrpi

[toolchain/WinRPi-toolchain.xml](https://github.com/hughsando/winrpi/blob/master/toolchain/WinRPi-toolchain.xml)

Compiling for raspberry pi on windows.

 - Based on public SDK
   - http://sysprogs.com/files/gnutoolchains/raspberry/raspberry-gcc4.6.3.exe
   - Install in defult location, but do not add to path
```xml
   <set name="RPISDK" value="c:/SysGCC/Raspberry/" unless="RPISDK" />
```

 - Provided by haxelib
   - You can use "-Ipath" to add a seach path for .xml files, but haxelib does this too
   - Easy to locate from within xml files: `${haxelib:winrpi}`
   - Adds 'winrpi' define to haxe build, which can be useful

 - Directory structure:
   - Create toolchain file with naming convention: toolchain/WinRPi-toolchain.xml

 - Set the 'toolchain' define to the 'WinRPi' part.
   - easy to do from 'extraParams.xml', `-D toolchain=WinRPi`

 - Inside the toolchain, set:
```xml
   <path name="${RPISDK}/bin" />
   <compiler id="winrpi" exe="${EXEPREFIX}-g++.exe" >
   <linker id="static_link" exe="ar" replace="true" >
   <linker id="exe" exe="${EXEPREFIX}-g++.exe">
   <linker id="dll" exe="${EXEPREFIX}-g++.exe">
```




