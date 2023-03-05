#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

// GCC Compilation - Enable NX, PIE, no stack canary
// gcc ./lyrics_static.c -o lyrics_static  

int main(){
    struct {
    char buf[16];
    char lyric[16];
  } locals;

    printf("============================================\n");
    printf("WELCOME TO DON'T FORGET THE LYRICS!\n");
    printf("Today's song is a classic favourite ... 'NEVER GONNA GIVE YOU UP BY RICK ASTLEY!'\n");
    printf("Please fill in the blank correctly:\n");
    printf("============================================\n");
    printf("Never gonna give you up!\n");
    printf("Never gonna let you down!\n");
    printf("Never gonna run around and ______ you!\n");
    printf("> ");

    scanf("%s", locals.buf);
    printf("============================================\n");
    printf("You said: Never gonna run around and %s you!\n", locals.lyric);
    
    if (strcmp(locals.lyric,"desert") == 0){
        printf("Congratulations!\n");
        char flag[512];
        // d is the function to deobfuscate the flag and store it within the flag variable. Not part of the challenge.
        //d(flag, "CZ4067{...}");
        printf("The flag is: %s", flag);
    }
    else {
        printf("That doesn't look right ... Try again!\n");
        printf("Here's the Youtube link to the song for some revision:\n");
        printf("https://www.youtube.comlist/watch?v=dQw4w9WgXcQ\n");
    }

    return 0;
}