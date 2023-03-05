#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

int main() {
    char buf[32];
    char flag[512];
    // d is the function to deobfuscate the flag and store it within the flag variable. Not part of the challenge.
    // d(flag, "CZ4067{...}");
    char *flag_ptr = flag;

    while(1) {
        printf("This cave is rather echo-y\n");
        printf("Shout something: ");
        fgets(buf,sizeof(buf),stdin);
        printf("\n The cave echoes back: ");
        printf(buf);
        printf("\n");
    }
    return 0;
}