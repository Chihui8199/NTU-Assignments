// threadtest.cc 
//	Simple test case for the round-robin assignment (Experiment 2).
//
//	Create and execute 10 threads in all. 
//

#include "copyright.h"
#include "system.h"

//----------------------------------------------------------------------
// SimpleThread
// 	Loop 1000000 times in a for loop. Print upon completion.
//
//	"which" is simply a number identifying the thread, for debugging
//	purposes.
//----------------------------------------------------------------------

void
SimpleThread(_int which)
{
    int num;
    
    for (num = 0; num < 1000000; num++) {}
    printf("Thread %d Completed.\n",(int)which);
}

//----------------------------------------------------------------------
// ThreadTest
// 	Set up a ping-pong between 10 threads, by forking a thread 
//	to call SimpleThread, and then calling SimpleThread ourselves.
//----------------------------------------------------------------------

void
ThreadTest()
{
    DEBUG('t', "Entering SimpleTest");
    
    Thread *t1 = new Thread("child1");
    t1->Fork(SimpleThread, 1, 0);
    Thread *t2 = new Thread("child2");
    t2->Fork(SimpleThread, 2, 0);
    Thread *t3 = new Thread("child3");
    t3->Fork(SimpleThread, 3, 0);
    Thread *t4 = new Thread("child4");
    t4->Fork(SimpleThread, 4, 0);
    Thread *t5 = new Thread("child5");
    t5->Fork(SimpleThread, 5, 0);
    Thread *t6 = new Thread("child6");
    t6->Fork(SimpleThread, 6, 0);
    Thread *t7 = new Thread("child7");
    t7->Fork(SimpleThread, 7, 0);
    Thread *t8 = new Thread("child8");
    t8->Fork(SimpleThread, 8, 0);
    Thread *t9 = new Thread("child9");
    t9->Fork(SimpleThread, 9, 0);


    SimpleThread(0);
}

