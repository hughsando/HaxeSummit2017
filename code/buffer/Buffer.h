#ifndef BUFFER_INC
#define BUFFER_INC

struct Buffer
{
   char *data;

   Buffer()
   {
      data = new char[100];
      data[0] = '!';
      data[1] = '\0';
   }
   ~Buffer()
   {
      delete data;
   }
   void print()
   {
      printf("Buffer %s\n", data);
   }
};

#endif
