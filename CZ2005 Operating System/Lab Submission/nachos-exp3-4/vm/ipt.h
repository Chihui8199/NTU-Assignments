// ipt.h
//      Template for what an inverted page table (ipt) entry will consist of.

#ifndef IPT_H
#define IPT_H

#include "copyright.h"
#include "openfile.h"
#include "syscall.h"
#include "machine.h"

//----------------------------------------------------------------------
// MemoryTable
//      Used by the clock algorithm to choose physical pages when things
// need to be swapped in.  Lots of fields are used for efficiency.
// One class per page frame.
//----------------------------------------------------------------------

class MemoryTable {
 public:
  MemoryTable(void);
  ~MemoryTable(void);

  bool valid;				// if frame is valid (being used)
  SpaceId pid;				// pid of frame owner
  int vPage;				// corresponding virtual page
  bool dirty;				// if needs to be saved
  int TLBentry;				// corresponding TLB entry
  int lastUsed;			// used to see record last used tick
  OpenFile *swapPtr;			// file to swap to
};

#endif // IPT_H
