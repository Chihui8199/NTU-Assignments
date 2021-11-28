#include "bitmap.h"
#include "machine.h"

class MemTable
{
  public :
  
  MemTable();
  ~MemTable();

  int StartSegment(int numPages);              // member function to find a continous
                                               // chunk of memory

  void releaseSegment(int begin, int size);    // to free up memory, clear the page entry
                                               // in the bitmap

   
  private :
    
  BitMap* bmap;
};
