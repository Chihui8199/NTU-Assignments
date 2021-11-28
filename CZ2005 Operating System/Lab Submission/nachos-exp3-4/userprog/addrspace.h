// addrspace.h 
//	Data structures to keep track of executing user programs 
//	(address spaces).
//
//	For now, we don't keep any information about address spaces.
//	The user level CPU state is saved and restored in the thread
//	executing the user program (see thread.h).
//
// Copyright (c) 1992-1993 The Regents of the University of California.
// All rights reserved.  See copyright.h for copyright notice and limitation 
// of liability and disclaimer of warranty provisions.

#ifndef ADDRSPACE_H
#define ADDRSPACE_H

#include "copyright.h"
#include "filesys.h"

#ifdef CHANGED
#include "syscall.h"
#endif

#ifdef CHANGED 
#define UserStackSize		2048 	// was 1024

//----------------------------------------------------------------------
// MmapEntry
//      Data structure for handling mmap'ed files.
//----------------------------------------------------------------------

class MmapEntry {
 public:
  MmapEntry(OpenFileId fileIdArg, OpenFile *openFileArg, int beginPageArg,
            int endPageArg, int lastPageLengthArg, MmapEntry *prevArg);
  ~MmapEntry(void);

  OpenFileId fileId;			// fileId
  OpenFile *openFile;			// openFile pointer
  int beginPage;			// page mmap starts on
  int endPage;				// page mmap ends on
  int lastPageLength;			// length of last page
  MmapEntry *prev;			// previous pointer
  MmapEntry *next;			// next pointer
};

class AddrSpace {
 public:
  AddrSpace(OpenFile *executable, SpaceId id);
                                        // Create an address space,
					// initializing it with the program
					// stored in the file "executable"
  ~AddrSpace();			        // De-allocate an address space
  void InitRegisters();		        // Initialize user-level CPU registers,
					// before jumping to user code
  void SaveState();			// Save/restore address space-specific
  void RestoreState();		        // info on a context switch 

#ifdef CHANGED                          // project 2, #2
  void ReleaseMem();                    // Free up memory
  char *kernelArgs;			// arguments to program
  bool outOfMem;                        // flag if out of swap
    
// Project 3
  char swapfilename[20];                // name of swap file
  OpenFile *swapPtr;                    // file pointer to swapfile
  unsigned int numPages;	        // Number of pages in the virtual 
                                        // address space
  MmapEntry *mmapEntries;               // sentinel to mmap entries
#endif
};

#endif // changed

#endif // ADDRSPACE_H





