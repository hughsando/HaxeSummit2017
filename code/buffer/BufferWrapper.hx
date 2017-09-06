
class BufferWrapper extends cpp.Finalizable
{
   var buffer:cpp.Star<BufferNative>;

   public function new()
   {
      super();
      buffer = BufferNative.create();
   }

   public function release()
   {
      if (buffer!=null)
      {
         buffer.destroy();
         buffer = null;
      }
   }

   public function print()
   {
      buffer.print();
   }

   override public function finalize()
   {
      if (buffer!=null)
         buffer.destroy();
   }

}
