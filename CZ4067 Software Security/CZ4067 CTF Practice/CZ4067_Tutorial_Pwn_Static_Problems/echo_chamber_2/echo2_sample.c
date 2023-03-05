#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> 
#include <stdarg.h>

// gcc -fno-stack-protector -no-pie ./echo2_static.c -o ./echo2_static

char flag[512];

// NOT PART OF THE CHALLENGE - IGNORE char_list and d()
char char_list[] = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
void d(char *buf, ...)
{
    va_list args;
    va_start (args, buf);

    char arg = va_arg(args, int);
    
    while( arg ) {
        sprintf(buf, "%s%c", buf, arg);
        arg = va_arg(args, int);
    }

    va_end (args);

    int char_list_length = strlen(char_list);
    int old_index;
    int new_index;
    int temp_len = strlen(buf);
    char odd[128];
    char even[128];
    for (int i = 0; i < temp_len; i++){
        if (i < temp_len/2) odd[i] = buf[i];
        else even[i-temp_len/2] = buf[i];
    }
    for (int i = 0; i < temp_len; i++){
        if (i % 2 == 0) buf[i] = even[i/2];
        else buf[i] = odd[(i-1)/2];
    }
    for (int i = 0; i < strlen(buf); i++) {
        for (int j = 0; j < char_list_length; j++){
            if (buf[i] == char_list[j]){
                old_index = j;
                new_index = (old_index + char_list_length - 13) % char_list_length;
                buf[i] = char_list[new_index];
                break;
            } 
        }
    }
}

int main() {
    char buf[32];
    d(flag, 'g', '=', 'D', '{', 'l', '=', '{', '@', 'l', '=', '}', '=', 'y', 'z', 'P', 'A', 'C', '*', '=', '}', '>', 'D', '!', '{', 'l', '!', 'o', '@', ',', '\0');
    while(1) {
        printf("This cave is hollower than the last one ...\n");
        printf("Shout something:\n");
        fgets(buf,sizeof(buf),stdin);
        printf("The cave echoes back: ");
        printf(buf);
        printf("\n");
    }
    return 0;
}