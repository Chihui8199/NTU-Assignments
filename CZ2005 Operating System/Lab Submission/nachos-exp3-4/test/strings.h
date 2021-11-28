
inline int strlen(char *s) {
    int len = 0;

    while(*s++ != '\0' ) len++;
    return len;
}

inline void strcpy(char *to, char *from) {

    while (*to++ = *from++)
	;
}

inline char *itoa(int z, int base) {
    char a[10];
    static char b[10];
    int l=0;
    int i;
    int y;
    unsigned int x = (unsigned int) z;

    if ( x == 0 ) {
	strcpy(b,"0");
	return b;
    }
    while (x && l < 9) {
	y = x % base;
	if ( y < 10 ) 
	    a[l++] = '0' + y;
	else
	    a[l++] = 'a' + (y-10);
	x /= base;
    }
    for ( i = 0; i < l; i++ )
	b[i] = a[l-i-1];
    b[l] = 0;
    return b;
}

inline void printstr(char *s) {
    Write(s,strlen(s),ConsoleOutput);
}

inline void printint(int i) {
    char *s = itoa(i,10);
    Write(s,strlen(s),ConsoleOutput);
}
inline void printhex(int i) {
    char *s = itoa(i,16);
    Write(s,strlen(s),ConsoleOutput);
}
inline writeln() {
    Write("\n",1,ConsoleOutput);
}

