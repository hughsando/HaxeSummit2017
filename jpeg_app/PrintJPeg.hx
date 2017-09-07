import cpp.NativeString;

class PrintJPeg
{
   public static function main()
   {
      var args = Sys.args();
      if (args.length != 1 && args.length!=2)
         Sys.println("Usage : PrintJPeg file.jpg [spacing]");
      else
         JPegExample.print(args[0], args.length==2 ? Std.parseInt(args[1]):1);
   }
}
