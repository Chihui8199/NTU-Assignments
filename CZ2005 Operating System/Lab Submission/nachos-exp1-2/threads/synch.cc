// synch.cc 
//	Routines for synchronizing threads.  Three kinds of
//	synchronization routines are defined here: semaphores, locks 
//   	and condition variables (the implementation of the last two
//	are left to the reader).
//
// Any implementation of a synchronization routine needs some
// primitive atomic operation.  We assume Nachos is running on
// a uniprocessor, and thus atomicity can be provided by
// turning off interrupts.  While interrupts are disabled, no
// context switch can occur, and thus the current thread is guaranteed
// to hold the CPU throughout, until interrupts are reenabled.
//
// Because some of these routines might be called with interrupts
// already disabled (Semaphore::V for one), instead of turning
// on interrupts at the end of the atomic operation, we always simply
// re-set the interrupt state back to its original value (whether
// that be disabled or enabled).
//
// Copyright (c) 1992-1993 The Regents of the University of California.
// All rights reserved.  See copyright.h for copyright notice and limitation 
// of liability and disclaimer of warranty provisions.

#include "copyright.h"
#include "synch.h"
#include "system.h"

//----------------------------------------------------------------------
// Semaphore::Semaphore
// 	Initialize a semaphore, so that it can be used for synchronization.
//
//	"debugName" is an arbitrary name, useful for debugging.
//	"initialValue" is the initial value of the semaphore.
//----------------------------------------------------------------------

Semaphore::Semaphore(char* debugName, int initialValue)
{
    name = debugName;
    value = initialValue;
    queue = new List;
}

//----------------------------------------------------------------------
// Semaphore::Semaphore
// 	De-allocate semaphore, when no longer needed.  Assume no one
//	is still waiting on the semaphore!
//----------------------------------------------------------------------

Semaphore::~Semaphore()
{
    delete queue;
}

//----------------------------------------------------------------------
// Semaphore::P
// 	Wait until semaphore value > 0, then decrement.  Checking the
//	value and decrementing must be done atomically, so we
//	need to disable interrupts before checking the value.
//
//	Note that Thread::Sleep assumes that interrupts are disabled
//	when it is called.
//----------------------------------------------------------------------

void
Semaphore::P()
{
    IntStatus oldLevel = interrupt->SetLevel(IntOff);	// disable interrupts
    
    while (value == 0) { 			// semaphore not available
	queue->Append((void *)currentThread);	// so go to sleep
	currentThread->Sleep();
    } 
    value--; 					// semaphore available, 
						// consume its value
    
    DEBUG ('s', "thread %s acquires semaphore %s\n", currentThread->getName(),
	   this->getName());

    (void) interrupt->SetLevel(oldLevel);	// re-enable interrupts
}

//----------------------------------------------------------------------
// Semaphore::V
// 	Increment semaphore value, waking up a waiter if necessary.
//	As with P(), this operation must be atomic, so we need to disable
//	interrupts.  Scheduler::ReadyToRun() assumes that threads
//	are disabled when it is called.
//----------------------------------------------------------------------

void
Semaphore::V()
{
    Thread *thread;
    IntStatus oldLevel = interrupt->SetLevel(IntOff);

    thread = (Thread *)queue->Remove();
    if (thread != NULL)   // make thread ready, consuming the V immediately
	scheduler->ReadyToRun(thread);
    value++;

    DEBUG ('s', "thread %s releases semaphore %s\n", currentThread->getName(),
	   this->getName());

    (void) interrupt->SetLevel(oldLevel);
}

// Dummy functions -- so we can compile our later assignments 
// Note -- without a correct implementation of Condition::Wait(), 
// the test case in the network assignment won't work!



// ----------------------------------------------------------------------
#ifdef CHANGED
//-----------------------------------------------------------------------
// Lock :: Lock(char * debugName) , constuctor for Lock
// ----------------------------------------------------------------------
Lock::Lock(char* debugName)
{
  name = debugName;
  status = new Semaphore("locksem", 1);    // one imply free
  lock_owner = NULL;
  isLock = 0;
}

// ----------------------------------------------------------------------
// Lock :: ~Lock(), destructor for Lock
// ----------------------------------------------------------------------

Lock::~Lock()
{
  delete status;         // deallocate the semaphore
  delete lock_owner;
}

// ----------------------------------------------------------------------
// Lock :: Acquire();
// ----------------------------------------------------------------------

void Lock::Acquire()
{

  IntStatus oldLevel = interrupt->SetLevel(IntOff); //disable interrupt
  DEBUG ('s', "thread %s acquire lock %s\n", currentThread->getName(),
	 this->getName());
  status->P();                  // decrement from 1 to 0 to indicate busy 
  
  DEBUG ('s', "thread %s succeeds in acquiring lock %s \n",
	 currentThread->getName(), this->getName());
  lock_owner = currentThread;   // the locked has to be owned by the current thread for
                                // the released to happen
  isLock = 1;
  (void) interrupt->SetLevel(oldLevel);             // reenable interrupt
}
void Lock::Release()
{
  IntStatus oldLevel = interrupt->SetLevel(IntOff); //disable interrupt
  if (isLock && isHeldByCurrentThread()) 
  {
    status->V();
    isLock = 0;
    lock_owner = NULL;
  }
  (void) interrupt->SetLevel(oldLevel);             // reenable interrupt
}
bool Lock:: isHeldByCurrentThread()
{
  return(lock_owner == currentThread);
}
#endif

// --------------------------------------------------------------------------

#ifdef CHANGED
Condition::Condition(char* debugName)
{
  name = debugName;
  Conqueue = new List;
}

Condition::~Condition()
{
  delete Conqueue;
}

void Condition::Wait(Lock* conditionLock)
{
  ASSERT(conditionLock->isHeldByCurrentThread()); 
  IntStatus oldLevel = interrupt->SetLevel(IntOff);  // disable interrupts
  conditionLock->Release();
  Conqueue->Append((void *) currentThread);
  currentThread->Sleep();
  conditionLock->Acquire();
  (void) interrupt->SetLevel(oldLevel);             // reenable interrupts
}

void Condition::Signal(Lock* conditionLock)
{
  Thread * thread;

  ASSERT(conditionLock->isHeldByCurrentThread());
  IntStatus oldLevel = interrupt->SetLevel(IntOff);

  thread = (Thread *)Conqueue->Remove();
  if (thread != NULL)
    scheduler->ReadyToRun(thread);
  (void) interrupt->SetLevel(oldLevel);             // reenable interrupt
}

void Condition::Broadcast(Lock* conditionLock)
{
  Thread * thread;
  ASSERT(conditionLock->isHeldByCurrentThread());
  IntStatus oldLevel = interrupt->SetLevel(IntOff);

  while(!Conqueue->IsEmpty())
    {
      thread = (Thread *) Conqueue->Remove();
      scheduler->ReadyToRun(thread);
    }
  (void) interrupt->SetLevel(oldLevel);             // reenable interrupt
  
}
#endif
