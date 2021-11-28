#ifdef CHANGED

// procedures for managing process lists

#include "copyright.h"
#include "slist.h"
#include "processlist.h"
#include "thread.h"

//---------------------------------------------------------------------------
// Child constructor
//---------------------------------------------------------------------------

Child::Child(void)
{
  // null body
}

//---------------------------------------------------------------------------
// Child destructor
//---------------------------------------------------------------------------

Child::~Child(void)
{
  // null body
}

//---------------------------------------------------------------------------
// File constructor
// Initializes openFile
//---------------------------------------------------------------------------

File::File(OpenFile *openFileArg)
{
  openFile=openFileArg;
  isMmap=FALSE;
}

//---------------------------------------------------------------------------
// File destructor
// deletes openFile
//---------------------------------------------------------------------------

File::~File(void)
{
  delete openFile;
}

//---------------------------------------------------------------------------
// Process constructor
// Inits status to 0, inits children and files SLists, and inits a sema-
// phore for synchronization between Exit() and Join().
//---------------------------------------------------------------------------

Process::Process(void)
{
  status=0;
  children=new SList;
  done=new Semaphore("done", 0);
  files=new SList;
}

//---------------------------------------------------------------------------
// Process destructor
// deletes the lists and semaphore.
//---------------------------------------------------------------------------

Process::~Process(void)
{
  delete children;
  delete done;
  delete files;
}

#endif
