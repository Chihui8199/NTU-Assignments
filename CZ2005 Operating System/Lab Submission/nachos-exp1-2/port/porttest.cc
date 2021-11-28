//-------------------------------------------------------------------------
// porttest.cc
//   -- Test cases for the Send() and Receive()
//-------------------------------------------------------------------------
#include "copyright.h"
#include "system.h"
#include "port.h"

Port port;

void Sender(int n) {

    printf("Sender #%d sending (%d).\n", n, n);
    port.Send(n);
    printf("Sender #%d finished.\n", n);
}

void Receiver(int n) {

    int result = 0;
    printf("Receiver #%d receiving.\n", n);
    port.Receive(&result);
    printf("Receiver #%d received (%d)\n", n, result);
}

//-------------------------------------------------------------------------
/*
  * Single/Multiple sender/receiver on the same port
1  - Sender1,   Receive1
2  - Receive1,  Sender1
3  - Sender1,   Sender2,   Receiver1, Receiver2
4  - Sender1,   Receiver1, Sender2,   Receiver2
5  - Sender1,   Receiver1, Receiver2, Sender2
6  - Receiver1, Receiver2, Sender1,   Sender2
7  - Receiver1, Sender1,   Receiver2, Sender2
8  - Receiver1, Sender1,   Sender2,   Receiver2
*/
//-------------------------------------------------------------------------

// Sender1, Receive1
void PortTest1()
{
  //your code here to test case 1
}

// Receive1,  Sender1
void PortTest2()
{
  //your code here to test case 2
}

// Sender1, Sender2, Receiver1, Receiver2
void PortTest3()
{
  //your code here to test case 3
}

// Sender1, Receiver1, Sender2, Receiver2
void PortTest4()
{
  //your code here to test case 4
}

// Sender1, Receiver1, Receiver2, Sender2
void PortTest5()
{
  //your code here to test case 5
}

// Receiver1, Receiver2, Sender1,   Sender2
void PortTest6()
{
  //your code here to test case 6
}

// Receiver1, Sender1, Receiver2, Sender2
void PortTest7()
{
  //your code here to test case 7
}

// Receiver1, Sender1, Sender2, Receiver2
void PortTest8()
{
  //your code here to test case 8
}

void PortTest()
{
//     PortTest1();
//     PortTest2();
//     PortTest3();
//     PortTest4();
//     PortTest5();
//     PortTest6();
//     PortTest7();
    PortTest8();

}
