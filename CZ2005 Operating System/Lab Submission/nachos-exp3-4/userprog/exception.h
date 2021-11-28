#ifdef CHANGED

// exception.h 
//      Function declarations for exceptions

#ifndef EXCEPTION_H
#define EXCEPTION_H

#define INITIAL_SIZE 5000 // initial file size. 
                          // not used until filesystem project anyway...

#include "copyright.h"
#include "syscall.h"
#include "console.h"
#include "synch.h"

// functions ExceptionHandler() calls to do system calls
// see comments in syscall.h for how they are supposed to work

void SyscallHalt(void);
void SyscallExit(int processStatus);
SpaceId SyscallExec(char *name, char *args);
void ExecProcess(int intSpace);
int SyscallJoin(SpaceId id);
void SyscallCreate(char *name);
OpenFileId SyscallOpen(char *name);
int SyscallRead(char *buffer, int size, OpenFileId id);
#ifdef CHANGED
int SyscallMmap(OpenFileId id, char *address);
int SyscallLength(OpenFileId id);
#endif // CHANGED
int FileRead(char *kernelBuffer, int size, OpenFileId id);
void SyscallWrite(char *buffer, int size, OpenFileId id);
void FileWrite(char *kernelBuffer, int size, OpenFileId id);
void SyscallClose(OpenFileId id);
// following functions commented out as they are not done
/*void SyscallFork(void (*func)());
void SyscallYield(void);*/

char *UserToKernelString(char *source); // Copies user string to kernel
char *UserToKernel(char *source, int length); // Copies user data to kernel
void KernelToUser(char *dest, char *source, int length); // Copies kernel data
							 // to user
int GetPhysAddrInKernel(int virtualAddr, int writing);

void InitArgs(char *args); // Inits args to user program (from Exec())

//-------------------------------------------------------------------------
// SynchConsole class
// Used for synchronized access (reads and writes) to the console.
// Works by using semaphores.  Two semaphores grab devices (like keyboard
// or display) while the other two are for waiting for the devices to be
// ready (readAvail and writeDone).  Basically, a user wanting to write 10
// bytes of data to the monitor will aquire the display semaphore and other
// processes will not be allowed to write to the display until it's done.
// While writing to the display, writeDone is used to ensure that the
// console can receive more data.  Analogeous operations occur for reading.
//-------------------------------------------------------------------------

class SynchConsole {
 public:
  SynchConsole(void);
  ~SynchConsole(void);
  int Read(char *kernelBuffer, int size); // Reads from keyboard
  void Write(char *kernelBuffer, int size); // Writes from keyboard
  Semaphore *keyboard; // Semaphore for keyboard access
  Semaphore *display; // Semaphore for display access
  Semaphore *readAvail; // Semaphore for seeing if keyboard has a character
  Semaphore *writeDone; // Semaphore for seeing if writing is done
};
  
// Interrupt routines for setting the semaphore for read and write operations.
// These should be in the above class, but c++ doesn't like pointers to
// member functions.

void ReadConsoleAvail(int arg);
void WriteConsoleDone(int arg);

#endif // EXCEPTION_H

#endif // CHANGED
