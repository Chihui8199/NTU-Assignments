//----------------------------------------------------------------------
// port.h -- Class definition for port.
//
//  - Send and Receive functions are embedded in a class called "Port".
//  - Beside send and receive functions, constructor and destructor are also
//    used for initialization and clean-up.
//  - A message is just an integer.
//  - A private integer, buffer, is used to hold the message being passed.
//  - One lock per port is used for mutual exclusion on the send/receive
//    operations.
//  - Three condition variables are used for synchronization.
//	cSender - put sender to wait if no receiver.
//	cReceiver - put receiver to wait if no sender.
//	cBuffer - put sender to wait if buffer is used by another sender
//		  who is sleeping.
//  - Complement with the three conditions variables, two integers are used
//    to keep track of numbers of senders and receivers: nSender and nReceiver.
//
//----------------------------------------------------------------------

#include "thread.h"
#include "list.h"
#include "synch.h"

class Port {
  public:
    Port();
    ~Port();

    void Send(int msg);	    // send message to this port
    void Receive(int *msg); // receive message from this port

  private:
    Condition *cSender;
    Condition *cReceiver;
    Condition *cBuffer;
    int nSender;	    // number of sender
    int nReceiver;          // number of receiver
    int buffer;		    // buffer for message
    Lock *plock;	    // lock for using port
};





