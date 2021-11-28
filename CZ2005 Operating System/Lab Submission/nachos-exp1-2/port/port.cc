//----------------------------------------------------------------------
// port.cc -- Send and Receive operations for port.
//
// Including two member functions:
//    Send (int message);
//    Receive (int *message);
//
//----------------------------------------------------------------------

#include "system.h"
#include "port.h"

//----------------------------------------------------------------------
// Port::Port
//    Initialization
//----------------------------------------------------------------------

Port::Port() {

    nSender = 0;        // no sender
    nReceiver = 0;      // no receiver
    cSender = new Condition("Port-cSender");
    cReceiver = new Condition("Port-cReceiver");
    cBuffer = new Condition("Port-cBuffer");
    plock = new Lock("Port-plock");             // lock for using port

}

//----------------------------------------------------------------------
// Port::~Port
//    Clean-up
//----------------------------------------------------------------------

Port::~Port() {

  delete cSender;
  delete cReceiver;
  delete cBuffer;
  delete plock;

}

//----------------------------------------------------------------------
// Port::Send
//    Send a message to a port.
//
//----------------------------------------------------------------------

void Port::Send(int msg) {
  //your code here to send a message to a port

}

//----------------------------------------------------------------------
// Port::Receive
//    Receive a message from a port.
//
//----------------------------------------------------------------------

void Port::Receive(int *msg) {
  //your code here to receive a message from a port

}
