#ifdef CHANGED 

#include "copyright.h"
#include "slist.h"
#include "thread.h"

//---------------------------------------------------------------------
// SListElement contructor.
// Inits the item it points to and the keys.
//---------------------------------------------------------------------

SListElement::SListElement(void *itemArg, int key1Arg, Thread *key2Arg)
{
  item=itemArg;
  key1=key1Arg;
  key2=key2Arg;
  next=0;
}

//----------------------------------------------------------------------
// SListElement destructor
// Deletes the item
//----------------------------------------------------------------------

SListElement::~SListElement(void)
{
  delete item;
}

//----------------------------------------------------------------------
// SList constructor
// Inits first to NULL
//----------------------------------------------------------------------

SList::SList(void)
{ 
  first=NULL; 
}

//----------------------------------------------------------------------
// SList destructor
// Removes all items from the SList.
//----------------------------------------------------------------------

SList::~SList(void)
{
  while(first)
    Remove(first->item);
}

//----------------------------------------------------------------------
// Adds a new item to the SList.  This creates an SListElement auto-
// matically.
//----------------------------------------------------------------------

void SList::Add(void *item, int key1, Thread *key2)
{
  SListElement *element=new SListElement(item, key1, key2);
  SListElement *sListElementPtr;

  if(IsEmpty())		// list is empty
    first=element;
  else {			// else put it after last
    sListElementPtr=first;
    while(sListElementPtr->next)
      sListElementPtr=sListElementPtr->next;
    sListElementPtr->next=element;
  }
}

//----------------------------------------------------------------------
// Removes an element from the SList.  It takes a pointer to the item of
// what you want to delete.  It will search through the SListElements until
// it finds the item to delete.  If the item is not in the list, it does
// nothing.
//----------------------------------------------------------------------

void SList::Remove(void *item)
{
  SListElement *SListElementPtr;
  SListElement *temp;

  if(IsEmpty())
    return;
  SListElementPtr=first;
  if(SListElementPtr->item==item){
    first=SListElementPtr->next;
    delete SListElementPtr;
  } else
    while(SListElementPtr->next){
      if(SListElementPtr->next->item==item){
	temp=SListElementPtr->next->next;
	delete SListElementPtr->next;
	SListElementPtr->next=temp;
	break;
      }
      SListElementPtr=SListElementPtr->next;
    }
}

//----------------------------------------------------------------------
// Simply checks if the list is empty or not.
//----------------------------------------------------------------------

bool SList::IsEmpty(void)
{ 
  if(!first)
    return TRUE;
  else
    return FALSE; 
}

//----------------------------------------------------------------------
// Searches through the SList on the first key.
// Returns a pointer to the item.  If it's not found, it returns 0.
//----------------------------------------------------------------------

void *SList::SearchById(int key1)
{
  SListElement *SListElementPtr;

  if(IsEmpty())
    return 0;
  SListElementPtr=first;
  if(SListElementPtr->key1==key1)
    return SListElementPtr->item;
  while(SListElementPtr->next){
    SListElementPtr=SListElementPtr->next;
    if(SListElementPtr->key1==key1)
      return SListElementPtr->item;
  }
  return 0;
}

//----------------------------------------------------------------------
// Searches through the SList on the second key.
// Returns a pointer to the item.  If it's not found, it returns 0.
//----------------------------------------------------------------------

void *SList::SearchByThread(Thread *key2)
{
  SListElement *SListElementPtr;

  if(IsEmpty())
    return 0;
  SListElementPtr=first;
  if(SListElementPtr->key2==key2)
    return SListElementPtr->item;
  while(SListElementPtr->next){
    SListElementPtr=SListElementPtr->next;
    if(SListElementPtr->key2==key2)
      return SListElementPtr->item;
  }
  return 0;
}

//----------------------------------------------------------------------
// FreeId
// 	This is called by funcstions to find an unused id.  It
//	basically traverses the process list trying sequential numbers
//	until it finds one not in use.
//
//----------------------------------------------------------------------

SpaceId SList::FreeId(SpaceId id)
{
  while(SearchById(id))
    id++;
  return id;
}

//----------------------------------------------------------------------
// Returns a pointer to the first item on the list.
//----------------------------------------------------------------------

void *SList::First(int *id)
{
  *id=first->key1;
  return first->item;
}

#endif
