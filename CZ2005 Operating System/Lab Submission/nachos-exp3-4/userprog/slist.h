#ifdef CHANGED
// slist.h
//      The Super List!
//	I implemented a new list type that I call the Simple, Search, or
//	Super list.  I found the List class in the threads directory to be
//	lacking in a few features, and containing some features that I found
//	unnecessary, so that is why I created this.  It is used for processes,
//	and lists off of processes.  SLists are cool because you can search
//	on two independent keys.

#ifndef SLIST_H
#define SLIST_H

#include "copyright.h"
#include "thread.h"
#include "syscall.h"

// 	SListElement
//	The elements in an SList.

class SListElement {
 public:
  SListElement(void *itemArg, int key1Arg, Thread *key2Arg);
  ~SListElement(void);
  int key1;			// key to search on
  Thread *key2;			// 2nd key to search on
  void *item;			// actual item
  SListElement *next;
};

class SList {
 public:
  SList(void);
  ~SList(void);
  void Add(void *item, int key1, Thread *key2);	// adds an entry
  void Remove(void *item);			// removes an item
  bool IsEmpty(void);				// checks if empty
  void *SearchById(int key1);			// search by key1
  void *SearchByThread(Thread *key2);		// search by key2
  SpaceId FreeId(SpaceId id);			// gets a free id
  void *First(int *id);				// returns the first elem.

 private:
  SListElement *first;  	// Head of the list, NULL if list is empty
};

#endif // PROCESSLIST_H

#endif // CHANGED
