#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

// GCC Compilation, no canary stack protection or ASLR
// gcc -fno-stack-protector -no-pie ./escape1_static.c -o escape1_static

void escape(){
    char flag[512];
    // d is the function to deobfuscate the flag and store it within the flag variable
    // d(flag, "CZ4067{...}");
    printf("You successfully escaped!");
    printf("The flag is: %s\n", flag);
}


int main(){
    printf("You are trapped in the Escape Room!\n");
    printf("Are you able to escape?\n");
    printf("Please key in the secret code below:\n");
    char code[16];
    gets(code);
    return 0;
}