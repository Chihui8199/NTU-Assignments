// Exception.cc 
//	Entry point into the Nachos kernel from user programs.
//	There are two kinds of things that can cause control to
//	transfer back to here from user code:
//
//	syscall -- The user code explicitly requests to call a procedure
//	in the Nachos kernel.  Right now, the only function we support is
//	"Halt".
//
//	exceptions -- The user code does something that the CPU can't handle.
//	For instance, accessing memory that doesn't exist, arithmetic errors,
//	etc.  
//
//	Interrupts (which can also cause control to transfer from user
//	code into the Nachos kernel) are handled elsewhere.
//
// For now, this only handles the Halt() system call.
// Everything else core dumps.
//
// Copyright (c) 1992-1993 The Regents of the University of California.
// All rights reserved.  See copyright.h for copyright notice and limitation 
// of liability and disclaimer of warranty provisions.

#include "copyright.h"
#include "system.h"
#include "syscall.h"
#ifdef CHANGED
#include "tlb.h"
#endif
#ifdef CHANGED
#include "exception.h"
#include "processlist.h"
#include "synch.h"
#include "filesys.h"
#include "slist.h"

//----------------------------------------------------------------------
// ExceptionHandler
// 	Entry point into the Nachos kernel.  Called when a user program
//	is executing, and either does a syscall, or generates an addressing
//	or arithmetic exception.
//
// 	For system calls, the following is the calling convention:
//
// 	system call code -- r2
//		arg1 -- r4
//		arg2 -- r5
//		arg3 -- r6
//		arg4 -- r7
//
//	The result of the system call, if any, must be put back into r2. 
//
// And don't forget to increment the pc before returning. (Or else you'll
// loop making the same system call forever!
//
//	"which" is the kind of exception.  The list of possible exceptions 
//	are in machine.h.
//----------------------------------------------------------------------

void
ExceptionHandler(ExceptionType which)
{
  int type = machine->ReadRegister(2);	// get type of syscall
  int arg1 = machine->ReadRegister(4);	// get arg1
  int arg2 = machine->ReadRegister(5);	// get arg2
  int arg3 = machine->ReadRegister(6);	// get arg3
  int returnVal;			// return value of particular call
  bool returnValP=FALSE;		// true if call returns anything
  
  if(which!=SyscallException){
    switch(which){
    case AddressErrorException:
      printf("Address Error Exception\n");
      SyscallExit(-1);
      break;
    case PageFaultException:
      UpdateTLB(0);
      return;
      break;
    case ReadOnlyException:
      printf("Read Only Exception\n");
      SyscallExit(-1);
      break;
    case BusErrorException:
      printf("Bus Error Exception\n");
      SyscallExit(-1);
      break;
    case OverflowException:
      printf("Overflow Exception\n");
      SyscallExit(-1);
      break;
    case IllegalInstrException:
      printf("Illegal Instruction Exception\n");
      SyscallExit(-1);
      break;
    default:
      printf("Unknown Exception\n");
      SyscallExit(-1);
      break;
    }
  }
  switch(type){				// switch on syscall type
  case SC_Halt:
    SyscallHalt();
    break;
  case SC_Exit:
    SyscallExit(arg1);
    break;
  case SC_Exec:
    returnVal=SyscallExec((char *)arg1, (char *)arg2);
    returnValP=TRUE;
    break;
  case SC_Join:
    returnVal=SyscallJoin((SpaceId)arg1);
    returnValP=TRUE;
    break;
  case SC_Create:
    SyscallCreate((char *)arg1);
    break;
  case SC_Open:
    returnVal=SyscallOpen((char *)arg1);
    returnValP=TRUE;
    break;
#ifdef CHANGED
  case SC_Mmap:
    returnVal=SyscallMmap((OpenFileId)arg1, (char *)arg2);
    returnValP=TRUE;
    break;
#endif // changed
  case SC_Read:
    returnVal=SyscallRead((char *)arg1, arg2, (OpenFileId)arg3);
    returnValP=TRUE;
    break;
  case SC_Write:
    SyscallWrite((char *)arg1, arg2, (OpenFileId)arg3);
    break;
#ifdef CHANGED
  case SC_Length:
    returnVal=SyscallLength((OpenFileId)arg1);
    returnValP=TRUE;
    break;
#endif // changed
  case SC_Close:
    SyscallClose((OpenFileId)arg1);
    break;
    /*    case SC_Fork:			Commented out because it's not done
	  SyscallFork((void (*func)())arg1);
	  break;
	  case SC_Yield:
	  SyscallYield();
	  break;*/
  default:				// if user tried an invalid syscall
    printf("Unknown system call %d\n", type);
    ASSERT(FALSE);
    break;
  }
  if(returnValP)			  // if syscall returned something,
    machine->WriteRegister(2, returnVal); // send it back to user.

  machine->WriteRegister(PrevPCReg, machine->ReadRegister(PCReg));
  machine->WriteRegister(PCReg, machine->ReadRegister(NextPCReg));
  machine->WriteRegister(NextPCReg, machine->ReadRegister(NextPCReg)+4);
				// increment PC of user prog past syscall
}

//----------------------------------------------------------------------
// SyscallHalt
// 	Stops the "machine"
//
//----------------------------------------------------------------------

void SyscallHalt(void)
{
  DEBUG('a', "SyscallHalt(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  interrupt->Halt();
}

//----------------------------------------------------------------------
// SyscallExit
// 	This is what a user process calls to die.  The process gives this
//	function one int argument indicating it's return status.  This
//	function releases the address space of the process and joins on
//	any children of the process that were never joined on (thus
//	freeing up 'zombies').  Open files are closed.  Then the function
//      puts the exit status in a table for it's parent to receive.  A
//      semaphore is used to prevent the parent from joining before this
//      function is called.  And then the thread dies gracefully.
//
//----------------------------------------------------------------------

void SyscallExit(int processStatus)
{
  Process *processPtr;
  SList *processChildren;
  SList *processFiles;
  int id;

  DEBUG('a', "SyscallExit(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  if(currentThread->space){
    delete currentThread->space;
    currentThread->space=0;
  }
  processPtr=(Process *)processes->SearchByThread(currentThread);
  processFiles=processPtr->files;
  while(!processFiles->IsEmpty()){
    processFiles->First(&id);
    SyscallClose(id);
  }  
  processChildren=processPtr->children;
  while(!processChildren->IsEmpty()){
    processChildren->First(&id);
    SyscallJoin(id);
  }
  processPtr->status=processStatus;
  processPtr->done->V(); // Allow join to get status
  currentThread->Finish();
}

//----------------------------------------------------------------------
// SyscallExec
// 	This functions forks and executes a new program in a new address
//	space.  The program is 'name'.  It starts out by converting name
//	to a string in kernel memory if the threads that called exec is
//	in userspace.  Then it opens the file and copies it to a new
//	address space.  If either of these fail, for instance if the file
//	doesn't exist, or there is no memory, -1 is returned.  A unique
//	SpaceId is then obtained.  The new process is inserted into a list
//	of children for the parent (this is used later in SyscallJoin and
//	SyscallExit).  Then a new process entry is made in the linked list
//	of processes.  The data in this entry is initialized.  Finally a new
//	thread is made and the process can execute.  The SpaceId is re-
//	turned to the calling function.
//
//----------------------------------------------------------------------

SpaceId SyscallExec(char *name, char *args)
{
  char *kernelName;
  AddrSpace *newAddress;
  OpenFile *executable;
  Thread *childThread;
  Process *processPtr;
  SpaceId id;

  DEBUG('a', "SyscallExec(), initiated by user program %s #%i.\n",
    currentThread->getName(), currentThread->pid);
  if(currentThread->space){
    kernelName=UserToKernelString(name);
  } else {
    kernelName=name;
  }
  
  if(!kernelName) // null pointer
    return -1;
  
  executable = fileSystem->Open(kernelName);
  
  if (executable == NULL){  // can't open file
    return -1;
  }
  if(currentThread->space)
    delete kernelName;
  id=processes->FreeId(0);
  
  newAddress=new AddrSpace(executable, id);
  delete executable;
  if(newAddress->outOfMem){
    delete newAddress;
    return -1;
  }
  childThread=new Thread("userprogram");
  childThread->pid=id;
  processPtr=(Process *)processes->SearchByThread(currentThread);
  processPtr->children->Add(new Child, id, 0);
  processes->Add(new Process, id, childThread);
  newAddress->kernelArgs=UserToKernelString(args);
  childThread->Fork(ExecProcess, (int)newAddress, FALSE);
  return id;
}

//----------------------------------------------------------------------
// ExecProcess
// 	This is called by SyscallExec to actually run the new process.
//	It is a forked kernel thread which begins by setting up it's
//	address space and initializes things.  It then calls machine->Run
//	which causes it to execute.
//
//----------------------------------------------------------------------

void ExecProcess(int intSpace)
{
  currentThread->space=(AddrSpace *)intSpace;
  currentThread->space->InitRegisters();
  currentThread->space->RestoreState();	// load page table register
  InitArgs(currentThread->space->kernelArgs); // init args to pass
  machine->Run();		        // jump to the user progam
  ASSERT(FALSE);			// machine->Run never returns;
  					// the address space exits
					// by doing the syscall "exit"
}

//----------------------------------------------------------------------
// InitArgs
//	This function is called by ExecProcess(), which is called by
//	SyscalExec().
//	It initialize the arguments passed to the child process in the 
//	new user space.
//	
//	In the InitArgs(), the arguments string is break into strings of 
//	arguments (char **argv) and store to the user stack together with 
//	the pointer to those strings (int argc). At the end, the argc is 
//	passed to r4 and argv is passed to r5.
//	More detail in the file README.P3
//
//----------------------------------------------------------------------

void InitArgs(char *kernelArgs)
{
  char **argv=0;	// pointer to strings of arguments
  int argc=0;		// argument count
  int i=0;
  char *stackPtr;	// stack pointer to space used to store
  int bytesToAllocate=0;  // number of bytes needed to store the whole argv
  char *table[100];
  char *argvTable[100];
  char *s;		// temporary string pointer
  int len;		// length of argument

  if(!kernelArgs){
    argc=0;
    argv=0;
  } else {
 // get bytes to allocate to stack
    if((s=strtok(kernelArgs, " "))){
      table[argc]=s;
      argc++;
      len=strlen(s)+1;
      len+=(4-(len%4))%4; // next multiple of 4, if not a multiple of 4
      bytesToAllocate+=len;
      while((s=strtok(0, " "))){
	table[argc]=s;
	argc++;
	len=strlen(s)+1;
	len+=(4-(len%4))%4; // next multiple of 4, if not a multiple of 4
	bytesToAllocate+=len;
      }
    }
    bytesToAllocate+=(argc+1)*4; // +1 for final 0
    stackPtr=(char *)machine->ReadRegister(StackReg);
    stackPtr-=bytesToAllocate;
    argv=(char **)stackPtr;
    stackPtr+=(argc+1)*4;
// put strings in stack
    for(i=0; i<argc; i++){
      argvTable[i]=(char *)WordToHost((int)stackPtr);
      len=strlen(table[i])+1;
      KernelToUser(stackPtr, table[i], len);
      len+=(4-(len%4))%4;
      stackPtr+=len;
    }
    argvTable[i]=0;
// put argv table in stack
    KernelToUser((char *)argv, (char *)argvTable, argc*4);
    machine->WriteRegister(StackReg, (int)argv-16);
  }
// write registers
  machine->WriteRegister(4, argc);
  machine->WriteRegister(5, (int)argv);
  delete kernelArgs;
}

//----------------------------------------------------------------------
// SyscallJoin
//	This function is used to join and retrieve the exit value of a
//	processes child.  The first thing it does is go through the calling
//	process's child list to ensure that the child on which the calling
//	process wishes to join is indeed it's child.  If it isn't, -1 is
//	returned.  The child is then removed from the childlist.  The next
//	thing that occurs is the process entry of the child is found and
//	a semaphore is used to make sure that the status variable is set to
//	the child's exit value before using it.  In other words, the sema-
//	phore is used to make sure the child actually exited.  When this is
//	true, the value is taken from status.  Then the child's process
//	entry is deleted and this function returns the status.
//
//----------------------------------------------------------------------

int SyscallJoin(SpaceId id)
{
  Process *processPtr;
  int processStatus;
  SList *processChildren;
  Child *childPtr;

  DEBUG('a', "SyscallJoin(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  processPtr=(Process *)processes->SearchByThread(currentThread);
  processChildren=processPtr->children;
  if(!(childPtr=(Child *)processChildren->SearchById(id)))
    return -1;
  processChildren->Remove(childPtr);
  processPtr=(Process *)processes->SearchById(id);
  processPtr->done->P();
  processStatus=processPtr->status;
  processes->Remove(processPtr);
  return processStatus;
}

//---------------------------------------------------------------------------
// SyscallCreate
// 	Creates a new file.  Calls unix stubs for now.
//---------------------------------------------------------------------------

void SyscallCreate(char *name)
{
  char *kernelName;

  DEBUG('a', "SyscallCreate(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  if(currentThread->space)
    kernelName=UserToKernelString(name);
  else
    kernelName=name;
  if(!kernelName)
    return;
  fileSystem->Create(kernelName, INITIAL_SIZE);
  if(currentThread->space)
    delete kernelName;
}

//---------------------------------------------------------------------------
// SyscallOpen
// 	Opens a file.  Calls unix stubs for now.  Adds to the files SList
//	for the process.  Other file syscalls can be used with the OpenFileId
//      that this function returns.
//---------------------------------------------------------------------------

OpenFileId SyscallOpen(char *name)
{
  char *kernelName;
  OpenFile *openFile;
  Process *processPtr;
  SList *processFiles;
  int id;

  DEBUG('a', "SyscallOpen(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  if(currentThread->space)
    kernelName=UserToKernelString(name);
  else
    kernelName=name;
  if(!kernelName) // null name
    return -1;
  if(!(openFile=fileSystem->Open(kernelName))) // can't open file
    return -1;
  if(currentThread->space)
    delete kernelName;
  processPtr=(Process *)processes->SearchByThread(currentThread);
  processFiles=processPtr->files;
  id=processFiles->FreeId(2); // to get past 0, 1.
  processFiles->Add(new File(openFile), id, 0);
  return id;
}

#ifdef CHANGED
//---------------------------------------------------------------------------
// SyscallMmap
//      "Maps" the given file into the virtual address space; the program
//      can use load and store instructions directly on the file data.
//      Assumes that the programmer picked an address aligned on a page
//      boundary, and that it is in some unused part of the address space.
//
//      Will return -1 (error) if:
//        id is consoleinput or output
//        address isn't on a page bounday
//        address is below the break point
//        id isn't a valid opened file
//        area is in another already mmapped area
//        the id is already being mmaped
//---------------------------------------------------------------------------

int SyscallMmap(OpenFileId id, char *address) {
  Process *processPtr;
  File *filePtr;
  MmapEntry *mmapPtr;
  int length;
  int beginPage, endPage, lastPageLength;

  DEBUG('a', "SyscallMmap(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  if(id==ConsoleInput || id==ConsoleOutput) // invalid id
    return -1;
  if((unsigned)address%PageSize) // not a pagesize multiple
    return -1;
  if((unsigned)address/PageSize<currentThread->space->numPages)
    return -1; // not above user's space
  processPtr=(Process *)processes->SearchByThread(currentThread);
  if(!(filePtr=(File *)processPtr->files->SearchById(id))) // can't find id
    return -1;
  length=SyscallLength(id);
  beginPage=(unsigned)address/PageSize;
  endPage=beginPage+length/PageSize;
  lastPageLength=length%PageSize;
  if(!lastPageLength)
    lastPageLength=PageSize;
  mmapPtr=currentThread->space->mmapEntries;
  while(mmapPtr->next){
    mmapPtr=mmapPtr->next;
    if((beginPage>=mmapPtr->beginPage) && (endPage<=mmapPtr->endPage) ||
       id==mmapPtr->fileId)
      return -1; // overlapping, or using same id
  }
  filePtr->isMmap=TRUE;
  mmapPtr=currentThread->space->mmapEntries;
  while(mmapPtr->next)
    mmapPtr=mmapPtr->next;
  mmapPtr->next=new MmapEntry(id, filePtr->openFile, beginPage, endPage,
			      lastPageLength, mmapPtr);
  return 0;
}
#endif // CHANGED

//---------------------------------------------------------------------------
// SyscallRead
// 	Reads from the file.  Calls unix stubs for now.  Returns number of
//      bytes read.  Puts size bytes of data from OpenFileId to buffer.
//---------------------------------------------------------------------------

int SyscallRead(char *buffer, int size, OpenFileId id)
{
  char *kernelBuffer;
  int numBytes;

  DEBUG('a', "SyscallRead(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  kernelBuffer=new char[size];
  if(id==ConsoleInput)
    numBytes=synchConsole->Read(kernelBuffer, size); // do console stuff
  else
    if((numBytes=FileRead(kernelBuffer, size, id))==-1) // Read error
       return -1;
  KernelToUser(buffer, kernelBuffer, size);
  delete kernelBuffer;
  return numBytes;
}

//---------------------------------------------------------------------------
// FileRead
// 	Specific for files (not console).  Called by SyscallRead.
//---------------------------------------------------------------------------

int FileRead(char *kernelBuffer, int size, OpenFileId id)
{
  Process *processPtr;
  File *filePtr;

  processPtr=(Process *)processes->SearchByThread(currentThread);
  if(!(filePtr=(File *)processPtr->files->SearchById(id))) // can't find id
    return -1;
  if(filePtr->isMmap)
    return -1;
  return filePtr->openFile->Read(kernelBuffer, size);
}

//---------------------------------------------------------------------------
// SyscallWrite
// 	Writes to the file.  Calls unix stubs for now.  Returns nothing.
//      Puts size bytes from buffer to file OpenFileId.
//---------------------------------------------------------------------------

void SyscallWrite(char *buffer, int size, OpenFileId id)
{
  char *kernelBuffer;
  
  DEBUG('a', "SyscallWrite(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  kernelBuffer=UserToKernel(buffer, size);
  if(!kernelBuffer) // null pointer
    return;
  if(id==ConsoleOutput)
    synchConsole->Write(kernelBuffer, size); // do console stuff
  else
    FileWrite(kernelBuffer, size, id);
  delete kernelBuffer;
}

//---------------------------------------------------------------------------
// FileWrite
// 	Specific for files (not console).  Called by SyscallWrite.
//---------------------------------------------------------------------------

void FileWrite(char *kernelBuffer, int size, OpenFileId id)
{
  Process *processPtr;
  File *filePtr;

  processPtr=(Process *)processes->SearchByThread(currentThread);
  if(!(filePtr=(File *)processPtr->files->SearchById(id))) // not found
    return;
  if(filePtr->isMmap)
    return;
  filePtr->openFile->Write(kernelBuffer, size);
}

#ifdef CHANGED
//---------------------------------------------------------------------------
// SyscallLength
//     returns length of openFile id file...
//---------------------------------------------------------------------------

int SyscallLength(OpenFileId id)
{
  Process *processPtr;
  File *filePtr;

  DEBUG('a', "SyscallLength(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  processPtr=(Process *)processes->SearchByThread(currentThread);
  if(!(filePtr=(File *)processPtr->files->SearchById(id))) // not found
    return -1;
  return filePtr->openFile->Length(); // call wrapper
}
#endif

//---------------------------------------------------------------------------
// SyscallClose
// 	Closes files by id.  Note, if you don't explicitly call this, Exit()
//      will do it for you.
//---------------------------------------------------------------------------

void SyscallClose(OpenFileId id)
{
  Process *processPtr;
  File *filePtr;
  MmapEntry *mmapPtr;

  DEBUG('a', "SyscallClose(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);
  processPtr=(Process *)processes->SearchByThread(currentThread);
  if(!(filePtr=(File *)processPtr->files->SearchById(id))) // not found
    return;
  if(filePtr->isMmap){
    mmapPtr=currentThread->space->mmapEntries;
    while(mmapPtr->next){
      mmapPtr=mmapPtr->next;
      if(mmapPtr->fileId==id)
	break;
    }
    delete mmapPtr;
  }
  processPtr->files->Remove(filePtr);
}

/* Commented out because it's not done

void SyscallFork(void (*func)())
{
  DEBUG('a', "SyscallFork(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);

}

void SyscallYield(void)
{
  DEBUG('a', "SyscallYield(), initiated by user program %s #%i.\n",
	currentThread->getName(), currentThread->pid);

}*/

//--------------------------------------------------------------------------
// UserToKernelString
//      Copies a string from user virtual address to a kernel structure.
//      Considers the string to be null terminated.
//--------------------------------------------------------------------------

char *UserToKernelString(char *source)
{
  int i=0;
  char *temp1, *temp2;
  int phyAddr;
  char *dest;
  
  if(!source){
    return 0;
  }
  
  temp1=source;
  while(1){
    phyAddr=GetPhysAddrInKernel((int)temp1++, FALSE);
    if(!phyAddr){
      return 0;
    }
    
    if(!machine->mainMemory[phyAddr])
      break;
    i++;
  }
  

  temp2=dest=new char[i+1];
  while(*temp2++=machine->mainMemory[GetPhysAddrInKernel((int)source++,
							 FALSE)])
    ;
  
  return dest;
}

//--------------------------------------------------------------------------
// UserToKernel
//      Copies a buffer of length from user virtual address to a kernel
//      structure.
//--------------------------------------------------------------------------

char *UserToKernel(char *source, int length)
{
  int current=0;
  int phyAddr;
  char *dest;
  
  if(!source)
    return (int)0;
  dest=new char[length];
  while(current<length){
    phyAddr=GetPhysAddrInKernel((int)source++, FALSE);
    if(!phyAddr)
      return 0;
    dest[current++]=machine->mainMemory[phyAddr];
  }
  return dest;
}

//--------------------------------------------------------------------------
// KernelToUser
//      Copies a buffer of length from kernel space to user space
//--------------------------------------------------------------------------

void KernelToUser(char *dest, char *source, int length)
{
  int current=0;
  int phyAddr;
  
  while(current<length){
    phyAddr=GetPhysAddrInKernel((int)dest++, TRUE);
    // dest won't get deleted if address is invalid
    machine->mainMemory[phyAddr]=source[current++];
  }
}

//--------------------------------------------------------------------------
// GetPhysAddrInKernel
//--------------------------------------------------------------------------

int GetPhysAddrInKernel(int virtualAddr, int writing)
{
  ExceptionType exception;
  int phyAddr;

  exception=machine->Translate(virtualAddr, &phyAddr, 1, writing);
  if(exception==PageFaultException){
    UpdateTLB(virtualAddr);
    exception=machine->Translate(virtualAddr, &phyAddr, 1, writing);
  }
  if(exception!=NoException){
    ExceptionHandler(exception);
    return 0;
  }
  
  return phyAddr;
}

//--------------------------------------------------------------------------
// SynchConsole constructor
//      Makes semaphores (check exception.h for more details on this class)
//--------------------------------------------------------------------------

SynchConsole::SynchConsole(void)
{
  keyboard=new Semaphore("keyboard", 1);
  display=new Semaphore("display", 1);
  readAvail=new Semaphore("read avail", 0);
  writeDone=new Semaphore("write done", 0);
}

//--------------------------------------------------------------------------
// SynchConsole destructor
//      Deletes semaphores (check exception.h for more details on this class)
//--------------------------------------------------------------------------

SynchConsole::~SynchConsole(void)
{
  delete keyboard;
  delete display;
  delete readAvail;
  delete writeDone;
}

//--------------------------------------------------------------------------
// SynchConsole::Read
//      Read from console (check exception.h for more details on this class)
//--------------------------------------------------------------------------

int SynchConsole::Read(char *kernelBuffer, int size)
{
  int i=0;

  keyboard->P();
  while(i<size){
    readAvail->P();
    kernelBuffer[i++]=console->GetChar();
  }
  keyboard->V();
  return size;
}

//--------------------------------------------------------------------------
// SynchConsole::Write
//      Writes to console (check exception.h for more details on this class)
//--------------------------------------------------------------------------

void SynchConsole::Write(char *kernelBuffer, int size)
{
  int i=0;

  display->P();
  while(i<size){
    console->PutChar(kernelBuffer[i++]);
    writeDone->P();
  }
  display->V();
}

//--------------------------------------------------------------------------
// ReadConsoleAvail
//      Interrupt handler (check exception.h for more details on this class)
//--------------------------------------------------------------------------

void ReadConsoleAvail(int arg)
{
  synchConsole->readAvail->V();
}

//--------------------------------------------------------------------------
// WriteConsoleDone
//      Interrupt handler (check exception.h for more details on this class)
//--------------------------------------------------------------------------

void WriteConsoleDone(int arg)
{
  synchConsole->writeDone->V();
}

#endif
