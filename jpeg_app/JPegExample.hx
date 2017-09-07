// Add include flags to the haxe files (and therefore this file)
// Add jpegfiles library files to project
@:buildXml("
  <import name='${haxelib:testjpeglib}/JPegLib.xml' />
  <files id='haxe'>
     <compilerflag value='-I${haxelib:testjpeglib}/config' />
     <compilerflag value='-I${haxelib:testjpeglib}/jpeg-9b' />
  </files>
  <target id='haxe'>
     <files id='jpegfiles' />
  </target>
")
// Paste code in so cpp file can see the "read_JPEG_file" function, and example.c can
//  "see" JPegExample_obj::put_scanline_someplace
@:cppInclude("./example.c")
class JPegExample
{
   static var rowId:Int;
   static var colSkip:Int;
   static var rowSkip:Int;

   @:native("read_JPEG_file")
   @:extern static function readJPeg(filename:cpp.ConstCharStar):Int return 0;

   static function put_scanline_someplace(data:cpp.Pointer<cpp.UInt8>, len:Int)
   {
      rowId++;
      if ((rowId % rowSkip) > 0)
         return;

      var x = 1;
      var line = [];
      while(x<len)
      {
         var val = data.at(x);
         if (val < 10)
            line.push(" ");
         else if (val < 60)
            line.push(".");
         else if (val < 100)
            line.push("-");
         else if (val < 128)
            line.push("+");
         else if (val < 160)
            line.push("x");
         else if (val < 220)
            line.push("X");
         else
            line.push("#");
         x+=3*colSkip;
      }
      Sys.println( line.join("") );
   }

   public static function print(filename:String, skip:Int = 1):Int
   {
      rowId = 0;
      colSkip = skip;
      if (colSkip<1)
         colSkip = 1;
      rowSkip = (colSkip*2);
      return readJPeg(filename);
   }
}

