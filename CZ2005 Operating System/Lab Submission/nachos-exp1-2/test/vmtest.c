
#include "syscall.h"
#include "strings.h"

int
main()
{
    int s;
    int rc;

    s = Exec("../test/vm.noff");
    rc = Join(s);
    
    Halt();

    /* not reached */
}
