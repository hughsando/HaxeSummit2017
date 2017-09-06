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
