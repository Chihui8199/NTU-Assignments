#ifdef CHANGED

//      Data structures for processes

#ifndef PROCESSLIST_H
#define PROCESSLIST_H

#include "copyright.h"
#include "thread.h"
#include "synch.h"
#include "openfile.h"

/* Child is a linked list of children a process can have.  Each process
   entry (see structure below) has a pointer to this list.  When a process
   exec()'s a child, the child's SpaceId gets added to the processes child
   list.  When the process join()'s, the list is checked to ensure the
   process is joining on one of it's own children.  If the process exits and
   has children in it's child list, it will release it's address space and
   wait on each of it's children to release the process information (exit
   value, etc...) of it's children. */

class Child {
 public:
  Child(void);
  ~Child(void);
  // no variables
};

/* File is a linked list of files that a process has open.  Each process
   entry (see structure below) has a pointer to this list.  When a process
   opens a file, a File entry gets added to the files SList.  Since it's
   entered in the list with an id, this provides a mapping from id to
   OpenFile structure.  These entries are deleted when closing files. */

class File {
 public:
  File(OpenFile *openFileArg);
  ~File(void);
  OpenFile *openFile;			// file entry
  bool isMmap;
};

/* Process is a linked list of all the user processes in the system.
   It contains a unique SpaceId which is used by user programs to refer to
   the process (for instance, to join).  There is a pointer to the thread
   block which is used when something needs to search for a process by thread
   block (like currentThread) as a key, in addition to searching by SpaceId.
   Status is the variable the holds the return value of the process after it
   does an exit.  It's set to 0 initially, but it won't be accessed by a join
   unless the exiting process explicitly sets the semaphore to indicate it's
   done. */

class Process {
 public:
  Process(void);
  ~Process(void);
  int status;				// return value (0 if still running)
  SList *children;			// list of children
  Semaphore *done;			// for syncing with child exit
  SList *files;	       	                // open files
};

#endif // PROCESSLIST_H

#endif // CHANGED
