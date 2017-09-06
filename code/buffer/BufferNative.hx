@:include("./Buffer.h")
@:native("Buffer")
@:structAccess
extern class BufferNative
{
   @:native("new Buffer")
   public static function create() : cpp.Star<BufferNative>;

   @:native("~Buffer")
   public function destroy() : Void;

   public function print() : Void;

}
