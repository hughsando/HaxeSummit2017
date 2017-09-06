class Test
{
   public static function main()
   {
      var buffer = BufferNative.create();
      buffer.print();
      buffer.destroy();

      runWrapper();
   }

   public static function runWrapper()
   {
      var wrapper : BufferWrapper = null;
      for(i in 0...100000)
         wrapper = new BufferWrapper();
      wrapper.print();
   }
}
