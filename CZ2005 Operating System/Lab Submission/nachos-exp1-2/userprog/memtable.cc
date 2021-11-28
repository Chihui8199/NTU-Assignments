
#include "synch.h"
#include "system.h"
#include "memtable.h"


MemTable :: MemTable()
{
  bmap = new BitMap(NumPhysPages);       // create the global bitmap for memory management
}

MemTable :: ~MemTable()
{
  delete bmap ;
}

int MemTable ::  StartSegment(int numPages)
{
  int size = 0;
  int StartAdd = -1;
  int i;
    
  if (numPages > NumPhysPages)
  {
    return -1;                            // if requested size is too big, it is impossible
                                          // to allocate, then return -1
  }
 
  for (i=0; i < NumPhysPages; i++)
  {
    if (!bmap->Test(i))            
    {  
      size ++;                            // increment the size when a available page is
      if (size == numPages)               // find, break until the size is equal to the
	break;                            // requested size
    }
    else
    {
      size = 0;                           // otherwise, resume the size to zero and start
      StartAdd = i;                       // to look for another chunk of memory
    }
  }

  if (size != numPages)              // no space found, return -1
  {
    return -1;
  }

  for (i=StartAdd+1; i < StartAdd + 1 + numPages; i++)
    bmap->Mark(i);                       // Mark the pages as used

  return (StartAdd+1);
}


void MemTable :: releaseSegment(int begin, int size)
{
  int i;
  
  ASSERT((begin+size) <= NumPhysPages);
  for (i=begin; i<size+begin; i++)       // free up the pages
    bmap->Clear(i);
  

}



















