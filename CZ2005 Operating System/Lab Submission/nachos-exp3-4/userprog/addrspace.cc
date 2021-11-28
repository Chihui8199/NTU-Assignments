// addrspace.cc 
//	Routines to manage address spaces (executing user programs).
//
//	In order to run a user program, you must:
//
//	1. link with the -N -T 0 option 
//	2. run coff2noff to convert the object file to Nachos format
//		(Nachos object code format is essentially just a simpler
//		version of the UNIX executable object code format)
//	3. load the NOFF file into the Nachos file system
//		(if you haven't implemented the file system yet, you
//		don't need to do this last step)
//
// Copyright (c) 1992-1993 The Regents of the University of California.
// All rights reserved.  See copyright.h for copyright notice and limitation 
// of liability and disclaimer of warranty provisions.

#include "copyright.h"
#include "system.h"
#include "addrspace.h"
#include "noff.h"
#include "tlb.h"

#include <strings.h>

//----------------------------------------------------------------------
// SwapHeader
// 	Do little endian to big endian conversion on the bytes in the 
//	object file header, in case the file was generated on a little
//	endian machine, and we're now running on a big endian machine.
//----------------------------------------------------------------------

static void 
SwapHeader (NoffHeader *noffH)
{
	noffH->noffMagic = WordToHost(noffH->noffMagic);
	noffH->code.size = WordToHost(noffH->code.size);
	noffH->code.virtualAddr = WordToHost(noffH->code.virtualAddr);
	noffH->code.inFileAddr = WordToHost(noffH->code.inFileAddr);
	noffH->initData.size = WordToHost(noffH->initData.size);
	noffH->initData.virtualAddr = WordToHost(noffH->initData.virtualAddr);
	noffH->initData.inFileAddr = WordToHost(noffH->initData.inFileAddr);
	noffH->uninitData.size = WordToHost(noffH->uninitData.size);
	noffH->uninitData.virtualAddr = WordToHost(noffH->uninitData.virtualAddr);
	noffH->uninitData.inFileAddr = WordToHost(noffH->uninitData.inFileAddr);
}

//----------------------------------------------------------------------
// AddrSpace::AddrSpace
// 	Create an address space to run a user program.
//	Load the program from a file "executable", and set everything
//	up so that we can start executing user instructions.
//
//	Assumes that the object code file is in NOFF format.
//
//      Virtual Memory Implemented!
//
//	"executable" is the file containing the object code to load into memory
//----------------------------------------------------------------------

AddrSpace::AddrSpace(OpenFile *executable, SpaceId id)
{
    NoffHeader noffH; 
    unsigned int size;

    executable->ReadAt((char *)&noffH, sizeof(noffH), 0);
    if ((noffH.noffMagic != NOFFMAGIC) && 
		(WordToHost(noffH.noffMagic) == NOFFMAGIC))
    	SwapHeader(&noffH);
    ASSERT(noffH.noffMagic == NOFFMAGIC);

// how big is address space?
    size = noffH.code.size + noffH.initData.size + noffH.uninitData.size 
			+ UserStackSize;	// we need to increase the size
						// to leave room for the stack
    numPages = divRoundUp(size, PageSize);
    size = numPages * PageSize;

    DEBUG('a', "Initializing address space, num pages %d, size %d\n", 
					numPages, size);

#ifdef CHANGED 

// create filename for the swapfile
    sprintf(swapfilename, "swapfile.%d", id);  

    fileSystem->Create(swapfilename, 0);
 
// create a media to read the data into it, then break them
// up to pages and put it into the swapfile
    char *buffer;      

    outOfMem=FALSE;
    if(!(buffer = new char[size])){
      outOfMem=TRUE;
      return;
    }

// zero out the entire address space, to zero the unitialized data segment 
// and the stack segment
    bzero(buffer, size);

    if (noffH.code.size > 0)
      executable->ReadAt(buffer, noffH.code.size, noffH.code.inFileAddr);
    if (noffH.initData.size > 0)
      executable->ReadAt(buffer+noffH.code.size, noffH.initData.size,
			 noffH.initData.inFileAddr);

// We now have the stuff in buffer, so we have to break them up to
// pages and write them to swapfile
    swapPtr = fileSystem->Open (swapfilename);
    int byteswritten;

    for (int j=0; j < numPages; j++) {
      byteswritten=swapPtr->WriteAt(buffer+j*PageSize, PageSize, j*PageSize);
      if(byteswritten!=PageSize){
	printf("Out of swap space.\n");
	outOfMem=TRUE;
	delete buffer;
	return;
      }
    }

// delete temporary storage
    delete buffer;

// make sentinel for mmap entries
    mmapEntries=new MmapEntry(0, 0, 0, 0, 0, 0);
}

//----------------------------------------------------------------------
// AddrSpace::~AddrSpace
// 	Dealloate an address space.
//      Involves closing mmapped files, freeing memory tables, and
//      removing the swap file.
//----------------------------------------------------------------------

AddrSpace::~AddrSpace()
{
  int i;

  while(mmapEntries->next)
    SyscallClose(mmapEntries->next->fileId);
  delete mmapEntries;

  for(i=0; i<NumPhysPages; i++)
    if(memoryTable[i].valid)
      if(memoryTable[i].pid==currentThread->pid){
        memoryTable[i].valid=FALSE;
      }
  fileSystem->Remove(swapfilename);      // Remove the swapfile
  delete swapPtr;
}

#endif // changed

//----------------------------------------------------------------------
// AddrSpace::InitRegisters
// 	Set the initial values for the user-level register set.
//
// 	We write these directly into the "machine" registers, so
//	that we can immediately jump to user code.  Note that these
//	will be saved/restored into the currentThread->userRegisters
//	when this thread is context switched out.
//----------------------------------------------------------------------

void
AddrSpace::InitRegisters()
{
    int i;

    for (i = 0; i < NumTotalRegs; i++)
      machine->WriteRegister(i, 0);

    // Initial program counter -- must be location of "Start"
    machine->WriteRegister(PCReg, 0);

    // Need to also tell MIPS where next instruction is, because
    // of branch delay possibility
    machine->WriteRegister(NextPCReg, 4);

   // Set the stack register to the end of the address space, where we
   // allocated the stack; but subtract off a bit, to make sure we don't
   // accidentally reference off the end!
    machine->WriteRegister(StackReg, numPages * PageSize - 16);
    DEBUG('a', "Initializing stack register to %d\n", numPages * PageSize - 16);
}

//----------------------------------------------------------------------
// AddrSpace::SaveState
// 	On a context switch, save any machine state, specific
//	to this address space, that needs saving.
//----------------------------------------------------------------------

void AddrSpace::SaveState()
{
// null body
}

#ifdef CHANGED 

//----------------------------------------------------------------------
// AddrSpace::RestoreState
// 	On a context switch, restore the machine state so that
//	this address space can run.
//----------------------------------------------------------------------

void AddrSpace::RestoreState() 
{
  int i;

// invalidate TLB...
  for(i=0; i<TLBSize; i++){
    memoryTable[machine->tlb[i].physicalPage].dirty=machine->tlb[i].dirty;
    memoryTable[machine->tlb[i].physicalPage].TLBentry=-1;
    machine->tlb[i].valid=FALSE;
  }
}

//----------------------------------------------------------------------
// MmapEntry::MmapEntry
// 	Init values for the MmapEntry
//----------------------------------------------------------------------

MmapEntry::MmapEntry(OpenFileId fileIdArg, OpenFile *openFileArg,
		     int beginPageArg, int endPageArg, int lastPageLengthArg,
		     MmapEntry *prevArg)
{
  fileId=fileIdArg;
  openFile=openFileArg;
  beginPage=beginPageArg;
  endPage=endPageArg;
  lastPageLength=lastPageLengthArg;
  prev=prevArg;
  next=0;
}

//----------------------------------------------------------------------
// MmapEntry::~MmapEntry
// 	Swap out contents of closing mmap, remove self from list.
//----------------------------------------------------------------------

MmapEntry::~MmapEntry(void)
{
  if(prev){
    PageOutMmapSpace(beginPage, endPage);
    prev->next=next;
  }
  if(next)
    next->prev=prev;
}

#endif // changed
